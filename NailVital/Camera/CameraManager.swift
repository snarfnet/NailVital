import AVFoundation
import Vision
import UIKit

final class CameraManager: NSObject, ObservableObject {

    @Published var nailResults: [NailHealthResult] = []
    @Published var handDetected = false
    @Published var fingerDots: [(point: CGPoint, finger: Finger, status: NailStatus)] = []
    @Published var cameraAuthorized = false

    let session = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let processingQueue = DispatchQueue(label: "nail.camera", qos: .userInitiated)
    private var isConfigured = false

    private let handPoseRequest: VNDetectHumanHandPoseRequest = {
        let req = VNDetectHumanHandPoseRequest()
        req.maximumHandCount = 2
        return req
    }()

    // MARK: - Setup

    func requestAccessAndSetup() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setup()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted { self?.setup() }
                DispatchQueue.main.async { self?.cameraAuthorized = granted }
            }
        default:
            DispatchQueue.main.async { self.cameraAuthorized = false }
        }
    }

    private func setup() {
        guard !isConfigured else { return }
        session.sessionPreset = .hd1280x720
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input  = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else { return }

        session.addInput(input)
        videoOutput.setSampleBufferDelegate(self, queue: processingQueue)
        videoOutput.alwaysDiscardsLateVideoFrames = true
        if session.canAddOutput(videoOutput) { session.addOutput(videoOutput) }
        videoOutput.connection(with: .video)?.videoOrientation = .portrait
        isConfigured = true
        DispatchQueue.main.async { self.cameraAuthorized = true }
    }

    func start() { processingQueue.async { if !self.session.isRunning { self.session.startRunning() } } }
    func stop()  { processingQueue.async { if self.session.isRunning  { self.session.stopRunning()  } } }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let imageSize = CGSize(width:  CVPixelBufferGetWidth(pixelBuffer),
                               height: CVPixelBufferGetHeight(pixelBuffer))

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        try? handler.perform([handPoseRequest])

        guard let observations = handPoseRequest.results, !observations.isEmpty else {
            DispatchQueue.main.async {
                self.handDetected = false
                self.nailResults = []
                self.fingerDots = []
            }
            return
        }

        var allResults: [NailHealthResult] = []
        var allDots: [(CGPoint, Finger, NailStatus)] = []

        for observation in observations {
            let map: [(Finger, VNHumanHandPoseObservation.JointName, VNHumanHandPoseObservation.JointName)] = [
                (.thumb,  .thumbIP,   .thumbTip),
                (.index,  .indexDIP,  .indexTip),
                (.middle, .middleDIP, .middleTip),
                (.ring,   .ringDIP,   .ringTip),
                (.little, .littleDIP, .littleTip),
            ]

            for (finger, dipName, tipName) in map {
                guard let dip = try? observation.recognizedPoint(dipName),
                      let tip = try? observation.recognizedPoint(tipName),
                      dip.confidence > 0.5, tip.confidence > 0.5 else { continue }

                // 3 zone centers (Vision coords, bottom-left origin)
                let lunulaCenter = lerp(dip, tip, NailAnalyzer.lunulaFraction)
                let plateCenter  = lerp(dip, tip, NailAnalyzer.plateFraction)
                let tipCenter    = lerp(dip, tip, NailAnalyzer.tipFraction)

                let lunulaColor = NailAnalyzer.extractColor(from: pixelBuffer, center: lunulaCenter, imageSize: imageSize)
                let plateColor  = NailAnalyzer.extractColor(from: pixelBuffer, center: plateCenter,  imageSize: imageSize)
                let tipColor    = NailAnalyzer.extractColor(from: pixelBuffer, center: tipCenter,    imageSize: imageSize)

                let (overall, lunulaStatus, plateStatus, tipStatus) =
                    NailAnalyzer.analyzeZoned(lunulaColor: lunulaColor,
                                              plateColor:  plateColor,
                                              tipColor:    tipColor)

                var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
                (plateColor ?? .gray).getHue(&h, saturation: &s, brightness: &b, alpha: &a)

                let result = NailHealthResult(
                    finger:        finger,
                    overallStatus: overall,
                    zoneColors:    ZoneColors(lunula: lunulaColor, plate: plateColor, tip: tipColor),
                    lunulaStatus:  lunulaStatus,
                    plateStatus:   plateStatus,
                    tipStatus:     tipStatus,
                    hue:           h,
                    saturation:    s,
                    brightness:    b
                )
                allResults.append(result)

                // Dot position in UIKit coords (top-left origin)
                let uiPoint = CGPoint(x: plateCenter.x, y: 1.0 - plateCenter.y)
                allDots.append((uiPoint, finger, overall))
            }
        }

        DispatchQueue.main.async {
            self.handDetected = !allResults.isEmpty
            self.nailResults  = allResults
            self.fingerDots   = allDots
        }
    }

    // MARK: - Helpers

    private func lerp(_ a: VNRecognizedPoint, _ b: VNRecognizedPoint, _ t: CGFloat) -> CGPoint {
        CGPoint(x: a.x + (b.x - a.x) * t, y: a.y + (b.y - a.y) * t)
    }
}

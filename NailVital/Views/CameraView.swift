import SwiftUI
import AVFoundation

// MARK: - Camera Preview

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {}

    class PreviewView: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    }
}

// MARK: - Main Camera Screen

struct MainCameraView: View {
    @StateObject private var camera = CameraManager()
    @EnvironmentObject private var repository: NailRecordRepository

    @State private var showInstructions = true
    @State private var showResults = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            CameraPreview(session: camera.session)
                .ignoresSafeArea()

            NailVitalStyle.cameraGlass
                .ignoresSafeArea()
                .allowsHitTesting(false)

            ScanFrame()

            GeometryReader { geo in
                ForEach(camera.fingerDots.indices, id: \.self) { i in
                    let dot = camera.fingerDots[i]
                    FingerDotView(finger: dot.finger, status: dot.status)
                        .position(
                            x: dot.point.x * geo.size.width,
                            y: dot.point.y * geo.size.height
                        )
                }
            }

            VStack {
                HeaderBar(onHelp: { showInstructions = true })
                Spacer()
                BottomPanel(
                    handDetected: camera.handDetected,
                    resultCount: camera.nailResults.count,
                    onAnalyze: { showResults = true }
                )
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)

            if showInstructions {
                InstructionOverlayView(isVisible: $showInstructions)
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                    .animation(.easeInOut(duration: 0.2), value: showInstructions)
            }
        }
        .onAppear { camera.setup(); camera.start() }
        .onDisappear { camera.stop() }
        .sheet(isPresented: $showResults) {
            ResultDetailView(results: camera.nailResults) {
                repository.save(results: camera.nailResults)
            }
        }
    }
}

// MARK: - Header

private struct HeaderBar: View {
    let onHelp: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("Nail Vital")
                    .font(.system(.title3, design: .serif).weight(.bold))
                    .foregroundColor(.white)
                Text("爪を枠の中に入れてください")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.76))
            }

            Spacer()

            Button(action: onHelp) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white, .white.opacity(0.16))
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("使い方")
        }
    }
}

// MARK: - Scan Frame

private struct ScanFrame: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .strokeBorder(
                LinearGradient(
                    colors: [.white.opacity(0.78), NailVitalStyle.blush.opacity(0.74)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1.5
            )
            .frame(width: 250, height: 330)
            .overlay(alignment: .top) {
                Text("HAND AREA")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.5)
                    .foregroundColor(.white.opacity(0.72))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.black.opacity(0.28))
                    .clipShape(Capsule())
                    .offset(y: -12)
            }
            .opacity(0.72)
            .allowsHitTesting(false)
    }
}

// MARK: - Finger Dot

private struct FingerDotView: View {
    let finger: Finger
    let status: NailStatus

    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(Color(status.statusColor))
                .frame(width: 18, height: 18)
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                .shadow(color: Color(status.statusColor).opacity(0.42), radius: 8)
            Text(finger.shortJP)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.75), radius: 2)
        }
    }
}

// MARK: - Bottom Panel

private struct BottomPanel: View {
    let handDetected: Bool
    let resultCount: Int
    let onAnalyze: () -> Void

    var statusText: String {
        handDetected ? "\(resultCount)本の爪を検出中" : "手をカメラに向けてください"
    }

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 10) {
                Circle()
                    .fill(handDetected ? NailVitalStyle.moss : Color.white.opacity(0.45))
                    .frame(width: 10, height: 10)
                    .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 1))
                Text(statusText)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                Spacer()
                Text(handDetected ? "READY" : "SEARCHING")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.4)
                    .foregroundColor(.white.opacity(0.68))
            }

            Button(action: onAnalyze) {
                Label(handDetected ? "結果を見る" : "手を検出していません", systemImage: "waveform.path.ecg")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(handDetected ? NailVitalStyle.teal : Color.white.opacity(0.18))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .disabled(!handDetected)
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.white.opacity(0.20), lineWidth: 1)
        )
    }
}

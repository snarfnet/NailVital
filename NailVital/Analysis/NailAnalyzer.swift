import UIKit
import CoreImage

// MARK: - Color HSB helper

private struct HSB {
    let h: CGFloat  // 0-360
    let s: CGFloat  // 0-1
    let b: CGFloat  // 0-1

    init(_ color: UIColor) {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        self.h = h * 360
        self.s = s
        self.b = b
    }

    func isWhite()    -> Bool { s < 0.12 && b > 0.72 }
    func isPink()     -> Bool { (h >= 330 || h <= 30) && s >= 0.10 && s <= 0.60 && b >= 0.55 }
    func isRed()      -> Bool { (h <= 20 || h >= 340) && s > 0.45 }
    func isDeepRed()  -> Bool { (h <= 15 || h >= 345) && s > 0.60 && b > 0.35 }
    func isBlue()     -> Bool { h >= 180 && h <= 280 && s > 0.15 }
    func isYellow()   -> Bool { h >= 40 && h <= 85 && s > 0.22 }
    func isDark()     -> Bool { b < 0.28 }
    func isPale()     -> Bool { s < 0.12 && b >= 0.55 && b <= 0.80 }
    func isDarkBrown()-> Bool { h >= 10 && h <= 55 && s > 0.38 && b < 0.50 }
    func isDarkRed()  -> Bool { (h <= 20 || h >= 340) && s > 0.35 && b < 0.48 }
    func isTeal()     -> Bool { h >= 165 && h <= 200 && s > 0.20 }
    func isReddish()  -> Bool { (h <= 40 || h >= 320) && s > 0.20 }
}

// MARK: - NailAnalyzer

struct NailAnalyzer {

    // MARK: - Zone extraction positions (fraction from DIP toward Tip)

    static let lunulaFraction: CGFloat  = 0.15
    static let plateFraction:  CGFloat  = 0.50
    static let tipFraction:    CGFloat  = 0.82

    // MARK: - 3-zone analysis (main entry)

    static func analyzeZoned(
        lunulaColor: UIColor?,
        plateColor:  UIColor?,
        tipColor:    UIColor?
    ) -> (overall: NailStatus, lunula: NailStatus, plate: NailStatus, tip: NailStatus) {

        let lunulaHSB = lunulaColor.map { HSB($0) }
        let plateHSB  = plateColor.map  { HSB($0) }
        let tipHSB    = tipColor.map    { HSB($0) }

        // --- Zone-comparative conditions first ---

        if let p = plateHSB, let t = tipHSB,
           p.isWhite() && t.isPink() {
            return (.milkyWhite,
                    lunulaHSB.map { analyzeSingle($0) } ?? .unknown,
                    .milkyWhite,
                    .milkyWhite)
        }

        if let lu = lunulaHSB, let t = tipHSB,
           lu.isWhite() && t.isReddish() {
            return (.twoTone, .twoTone, .twoTone, .twoTone)
        }

        if let lu = lunulaHSB, let p = plateHSB,
           lu.isRed() && !p.isRed() {
            return (.redAccent, .redAccent,
                    analyzeSingle(p),
                    tipHSB.map { analyzeSingle($0) } ?? .unknown)
        }

        if let lu = lunulaHSB, lu.isTeal() {
            return (.blueAccent, .blueAccent,
                    plateHSB.map { analyzeSingle($0) } ?? .unknown,
                    tipHSB.map   { analyzeSingle($0) } ?? .unknown)
        }

        // --- Single-zone fallback ---

        let plateStatus  = plateHSB.map  { analyzeSingle($0) } ?? .unknown
        let lunulaStatus = lunulaHSB.map { analyzeSingle($0) } ?? plateStatus
        let tipStatus    = tipHSB.map    { analyzeSingle($0) } ?? plateStatus

        // Overall = plate status as primary (largest zone)
        let overall = plateStatus
        return (overall, lunulaStatus, plateStatus, tipStatus)
    }

    // MARK: - Single-color classification

    private static func analyzeSingle(_ hsb: HSB) -> NailStatus {
        if hsb.isDark()      { return .unknown }
        if hsb.isDarkBrown() { return .darkLine }
        if hsb.isDarkRed()   { return .deepRedLine }
        if hsb.isBlue()      { return .coolBlue }
        if hsb.isYellow()    { return .warmYellow }
        if hsb.isDeepRed()   { return .vividRed }
        if hsb.isPale()      { return .paleNeutral }
        if hsb.isWhite()     { return .clearWhite }
        if hsb.isPink()      { return .softPink }
        return .unknown
    }

    // MARK: - Pixel color extraction

    static func extractColor(
        from pixelBuffer: CVPixelBuffer,
        center: CGPoint,        // Vision coords (0-1, bottom-left origin)
        imageSize: CGSize,
        radiusFraction: CGFloat = 0.022
    ) -> UIColor? {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let radius  = imageSize.width * radiusFraction
        let cx      = center.x * imageSize.width
        let cy      = center.y * imageSize.height

        let cropRect = CGRect(x: cx - radius, y: cy - radius,
                              width: radius * 2, height: radius * 2)
        let cropped  = ciImage.cropped(to: cropRect)
        return averageColor(of: cropped)
    }

    // MARK: - CIAreaAverage

    static func averageColor(of ciImage: CIImage) -> UIColor? {
        guard !ciImage.extent.isEmpty,
              ciImage.extent.width > 0,
              ciImage.extent.height > 0 else { return nil }

        let extentVector = CIVector(
            x: ciImage.extent.origin.x, y: ciImage.extent.origin.y,
            z: ciImage.extent.size.width, w: ciImage.extent.size.height
        )
        guard let filter = CIFilter(
            name: "CIAreaAverage",
            parameters: [kCIInputImageKey: ciImage, kCIInputExtentKey: extentVector]
        ), let output = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: NSNull()])
        context.render(output, toBitmap: &bitmap, rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: CGColorSpaceCreateDeviceRGB())

        return UIColor(red:   CGFloat(bitmap[0]) / 255,
                       green: CGFloat(bitmap[1]) / 255,
                       blue:  CGFloat(bitmap[2]) / 255,
                       alpha: 1)
    }
}

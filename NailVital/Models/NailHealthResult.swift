import UIKit

// MARK: - Finger

enum Finger: String, CaseIterable, Codable {
    case thumb, index, middle, ring, little

    var nameJP: String {
        switch self {
        case .thumb:  return "親指"
        case .index:  return "人差し指"
        case .middle: return "中指"
        case .ring:   return "薬指"
        case .little: return "小指"
        }
    }

    var nameEN: String {
        switch self {
        case .thumb:  return "Thumb"
        case .index:  return "Index"
        case .middle: return "Middle"
        case .ring:   return "Ring"
        case .little: return "Little"
        }
    }

    var shortJP: String {
        switch self {
        case .thumb:  return "親"
        case .index:  return "人"
        case .middle: return "中"
        case .ring:   return "薬"
        case .little: return "小"
        }
    }
}

// MARK: - Nail Zone

enum NailZone: String, CaseIterable {
    case lunula
    case plate
    case tip

    var labelJP: String {
        switch self {
        case .lunula: return "半月"
        case .plate:  return "爪甲"
        case .tip:    return "先端"
        }
    }

    var labelEN: String {
        switch self {
        case .lunula: return "Lunula"
        case .plate:  return "Plate"
        case .tip:    return "Tip"
        }
    }
}

// MARK: - NailStatus

enum NailStatus: String, CaseIterable, Codable {
    case softPink
    case coolBlue
    case warmYellow
    case milkyWhite
    case twoTone
    case clearWhite
    case darkLine
    case deepRedLine
    case redAccent
    case blueAccent
    case paleNeutral
    case vividRed
    case unknown

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = NailStatus(rawValue: rawValue) ?? .unknown
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    var titleJP: String {
        switch self {
        case .softPink:     return "やわらかなピンク"
        case .coolBlue:     return "青みのあるトーン"
        case .warmYellow:   return "黄みのあるトーン"
        case .milkyWhite:   return "ミルキーな白"
        case .twoTone:      return "二色のトーン"
        case .clearWhite:   return "白が強いトーン"
        case .darkLine:     return "暗めの縦ライン"
        case .deepRedLine:  return "深い赤のライン"
        case .redAccent:    return "赤みのアクセント"
        case .blueAccent:   return "青みのアクセント"
        case .paleNeutral:  return "淡いニュートラル"
        case .vividRed:     return "鮮やかな赤"
        case .unknown:      return "色メモなし"
        }
    }

    var titleEN: String {
        switch self {
        case .softPink:     return "Soft Pink"
        case .coolBlue:     return "Cool Blue"
        case .warmYellow:   return "Warm Yellow"
        case .milkyWhite:   return "Milky White"
        case .twoTone:      return "Two-Tone"
        case .clearWhite:   return "Clear White"
        case .darkLine:     return "Dark Line"
        case .deepRedLine:  return "Deep Red Line"
        case .redAccent:    return "Red Accent"
        case .blueAccent:   return "Blue Accent"
        case .paleNeutral:  return "Pale Neutral"
        case .vividRed:     return "Vivid Red"
        case .unknown:      return "No Color Memo"
        }
    }

    var descriptionJP: String {
        switch self {
        case .softPink:
            return "自然なピンク系として記録しました。前回のネイル色と見比べやすいトーンです。"
        case .coolBlue:
            return "青みを感じるトーンとして記録しました。照明の色や影の入り方もメモしておくと便利です。"
        case .warmYellow:
            return "黄みを感じるトーンとして記録しました。カラー名や使ったポリッシュ名をメモできます。"
        case .milkyWhite:
            return "白っぽくミルキーな見え方として記録しました。仕上がりの印象を残しておけます。"
        case .twoTone:
            return "根元と先端で色の差があるメモとして記録しました。デザインメモとして見返せます。"
        case .clearWhite:
            return "白が強いトーンとして記録しました。ベースカラーや光の反射も一緒に見返せます。"
        case .darkLine:
            return "暗めのラインが見えるメモとして記録しました。写真と一緒に個人メモへ残せます。"
        case .deepRedLine:
            return "深い赤のラインが見えるメモとして記録しました。撮影時の光や角度も控えておけます。"
        case .redAccent:
            return "赤みのアクセントとして記録しました。ネイルデザインの色合わせに使えます。"
        case .blueAccent:
            return "青みのアクセントとして記録しました。クール系カラーの記録に向いています。"
        case .paleNeutral:
            return "淡いニュートラル系として記録しました。ナチュラルカラーの比較に使えます。"
        case .vividRed:
            return "鮮やかな赤系として記録しました。濃いカラーの履歴として見返せます。"
        case .unknown:
            return "色をうまく拾えませんでした。明るい場所で、爪を枠に入れて撮り直してください。"
        }
    }

    var descriptionEN: String {
        switch self {
        case .softPink:     return "Saved as a soft pink tone for your personal nail log."
        case .coolBlue:     return "Saved as a cool blue tone. Lighting can affect the color note."
        case .warmYellow:   return "Saved as a warm yellow tone for comparing colors later."
        case .milkyWhite:   return "Saved as a milky white tone."
        case .twoTone:      return "Saved as a two-tone color note."
        case .clearWhite:   return "Saved as a clear white tone."
        case .darkLine:     return "Saved as a dark line note."
        case .deepRedLine:  return "Saved as a deep red line note."
        case .redAccent:    return "Saved as a red accent."
        case .blueAccent:   return "Saved as a blue accent."
        case .paleNeutral:  return "Saved as a pale neutral tone."
        case .vividRed:     return "Saved as a vivid red tone."
        case .unknown:      return "The app could not capture a clear color note. Try again in brighter light."
        }
    }

    var icon: String {
        switch self {
        case .softPink:     return "paintpalette.fill"
        case .coolBlue:     return "circle.lefthalf.filled"
        case .warmYellow:   return "sun.max.fill"
        case .milkyWhite:   return "circle.fill"
        case .twoTone:      return "circle.righthalf.filled"
        case .clearWhite:   return "sparkles"
        case .darkLine:     return "line.diagonal"
        case .deepRedLine:  return "line.diagonal"
        case .redAccent:    return "circle.fill"
        case .blueAccent:   return "circle.fill"
        case .paleNeutral:  return "circle.dashed"
        case .vividRed:     return "circle.fill"
        case .unknown:      return "questionmark.circle"
        }
    }

    var statusColor: UIColor {
        switch self {
        case .softPink:     return UIColor(red: 0.93, green: 0.45, blue: 0.55, alpha: 1)
        case .coolBlue:     return .systemBlue
        case .warmYellow:   return UIColor(red: 0.82, green: 0.62, blue: 0.08, alpha: 1)
        case .milkyWhite:   return .systemGray
        case .twoTone:      return UIColor(red: 0.66, green: 0.25, blue: 0.23, alpha: 1)
        case .clearWhite:   return .systemGray2
        case .darkLine:     return UIColor(red: 0.25, green: 0.15, blue: 0.10, alpha: 1)
        case .deepRedLine:  return UIColor(red: 0.70, green: 0.10, blue: 0.10, alpha: 1)
        case .redAccent:    return .systemRed
        case .blueAccent:   return .systemTeal
        case .paleNeutral:  return .systemGray3
        case .vividRed:     return UIColor(red: 0.80, green: 0.10, blue: 0.10, alpha: 1)
        case .unknown:      return .systemGray
        }
    }
}

// MARK: - Zone Colors

struct ZoneColors {
    let lunula: UIColor?
    let plate: UIColor?
    let tip: UIColor?
}

// MARK: - Result

struct NailHealthResult: Identifiable {
    let id = UUID()
    let finger: Finger
    let overallStatus: NailStatus
    let zoneColors: ZoneColors
    let lunulaStatus: NailStatus
    let plateStatus: NailStatus
    let tipStatus: NailStatus
    let hue: CGFloat
    let saturation: CGFloat
    let brightness: CGFloat
}

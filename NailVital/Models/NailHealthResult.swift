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

// MARK: - Citation

struct NailCitation {
    let authors: String
    let year: Int
    let title: String
    let journal: String
    let detail: String
}

// MARK: - NailStatus

enum NailStatus: String, CaseIterable, Codable {
    case healthy
    case cyanosis
    case yellowNailSyndrome
    case terryNails
    case lindsaysNails
    case leukonychia
    case melanonychia
    case splinterHemorrhage
    case redLunula
    case azureLunula
    case pallidAnemia
    case polycythemia
    case unknown

    var titleJP: String {
        switch self {
        case .healthy:             return "健康的なピンク色"
        case .cyanosis:            return "青みがかった色合い"
        case .yellowNailSyndrome:  return "黄色みのある色合い"
        case .terryNails:          return "白っぽい爪甲"
        case .lindsaysNails:       return "二色に分かれた色合い"
        case .leukonychia:         return "白色が強い色合い"
        case .melanonychia:        return "暗い縦すじ"
        case .splinterHemorrhage:  return "暗赤色の線"
        case .redLunula:           return "赤みのある爪半月"
        case .azureLunula:         return "青みのある爪半月"
        case .pallidAnemia:        return "蒼白な色合い"
        case .polycythemia:        return "深い赤色"
        case .unknown:             return "判定できません"
        }
    }

    var titleEN: String {
        switch self {
        case .healthy:             return "Healthy Pink"
        case .cyanosis:            return "Bluish Tone"
        case .yellowNailSyndrome:  return "Yellowish Tone"
        case .terryNails:          return "Whitish Plate"
        case .lindsaysNails:       return "Two-Tone Pattern"
        case .leukonychia:         return "White Tone"
        case .melanonychia:        return "Dark Streak"
        case .splinterHemorrhage:  return "Dark Red Lines"
        case .redLunula:           return "Reddish Lunula"
        case .azureLunula:         return "Bluish Lunula"
        case .pallidAnemia:        return "Pale Tone"
        case .polycythemia:        return "Deep Red Tone"
        case .unknown:             return "Unknown"
        }
    }

    var descriptionJP: String {
        switch self {
        case .healthy:
            return "爪の色と見え方は健康的な範囲に見えます。"
        case .cyanosis:
            return "青紫色が強く見えます。医学文献では、このような色合いは酸素飽和度の変化と関連が報告されています。"
        case .yellowNailSyndrome:
            return "黄色みが強く見えます。医学文献では、このような色合いはリンパ系や呼吸器系の変化と関連が報告されています。"
        case .terryNails:
            return "爪甲が白っぽく、先端だけピンクに見える傾向です。医学文献では、このパターンは肝機能や循環器系の変化と関連が報告されています。"
        case .lindsaysNails:
            return "根元が白く、先端が赤茶色に見える傾向です。医学文献では、このパターンは腎機能の変化と関連が報告されています。"
        case .leukonychia:
            return "白っぽさが目立ちます。医学文献では、このような色合いは栄養状態や内臓機能の変化と関連が報告されています。"
        case .melanonychia:
            return "茶色から黒色の縦すじが見られます。医学文献では、このような色の変化にはさまざまな原因が報告されています。"
        case .splinterHemorrhage:
            return "暗赤色の細い縦線が見られます。医学文献では、このような線状パターンは循環器系の変化や外的要因と関連が報告されています。"
        case .redLunula:
            return "爪半月が赤く見える傾向です。医学文献では、このような色合いは循環器系や免疫系の変化と関連が報告されています。"
        case .azureLunula:
            return "爪半月が青く見える傾向です。医学文献では、このような色合いは微量元素の代謝変化と関連が報告されています。"
        case .pallidAnemia:
            return "全体的に蒼白に見えます。医学文献では、このような色合いは栄養状態や血液成分の変化と関連が報告されています。"
        case .polycythemia:
            return "深い赤色が強く見えます。医学文献では、このような色合いは血液成分の変化と関連が報告されています。"
        case .unknown:
            return "爪を正面に向け、明るい場所でもう一度スキャンしてください。"
        }
    }

    var descriptionEN: String {
        switch self {
        case .healthy:
            return "Nail color and appearance look within a healthy range."
        case .cyanosis:
            return "In medical literature, this bluish-purple color pattern has been associated with changes in oxygen saturation levels."
        case .yellowNailSyndrome:
            return "In medical literature, this yellowish color pattern has been associated with changes in lymphatic and respiratory function."
        case .terryNails:
            return "In medical literature, this whitish plate with a narrow pink distal band has been associated with changes in hepatic and circulatory function."
        case .lindsaysNails:
            return "In medical literature, this two-tone pattern (proximal white, distal red-brown) has been associated with changes in renal function."
        case .leukonychia:
            return "In medical literature, this whitish color pattern has been associated with changes in nutritional status and organ function."
        case .melanonychia:
            return "In medical literature, this dark longitudinal streak has been associated with various causes."
        case .splinterHemorrhage:
            return "In medical literature, this dark red line pattern has been associated with circulatory changes and external factors."
        case .redLunula:
            return "In medical literature, this reddish lunula color has been associated with circulatory and immune system changes."
        case .azureLunula:
            return "In medical literature, this bluish lunula color has been associated with trace element metabolism changes."
        case .pallidAnemia:
            return "In medical literature, this pale color pattern has been associated with changes in nutritional status and blood composition."
        case .polycythemia:
            return "In medical literature, this deep red color pattern has been associated with changes in blood composition."
        case .unknown:
            return "Face your nail toward the camera in good lighting and try again."
        }
    }

    var icon: String {
        switch self {
        case .healthy:             return "checkmark.seal.fill"
        case .cyanosis:            return "lungs.fill"
        case .yellowNailSyndrome:  return "exclamationmark.triangle.fill"
        case .terryNails:          return "waveform.path.ecg"
        case .lindsaysNails:       return "drop.fill"
        case .leukonychia:         return "circle.dashed"
        case .melanonychia:        return "exclamationmark.octagon.fill"
        case .splinterHemorrhage:  return "heart.slash.fill"
        case .redLunula:           return "heart.fill"
        case .azureLunula:         return "allergens"
        case .pallidAnemia:        return "drop.halffull"
        case .polycythemia:        return "drop.fill"
        case .unknown:             return "questionmark.circle"
        }
    }

    var statusColor: UIColor {
        switch self {
        case .healthy:             return .systemGreen
        case .cyanosis:            return .systemBlue
        case .yellowNailSyndrome:  return UIColor(red: 0.82, green: 0.62, blue: 0.08, alpha: 1)
        case .terryNails:          return .systemGray
        case .lindsaysNails:       return UIColor(red: 0.66, green: 0.25, blue: 0.23, alpha: 1)
        case .leukonychia:         return .systemGray2
        case .melanonychia:        return UIColor(red: 0.25, green: 0.15, blue: 0.10, alpha: 1)
        case .splinterHemorrhage:  return UIColor(red: 0.70, green: 0.10, blue: 0.10, alpha: 1)
        case .redLunula:           return .systemRed
        case .azureLunula:         return .systemTeal
        case .pallidAnemia:        return .systemGray3
        case .polycythemia:        return UIColor(red: 0.80, green: 0.10, blue: 0.10, alpha: 1)
        case .unknown:             return .systemGray
        }
    }

    var citations: [NailCitation] {
        switch self {
        case .healthy, .unknown:
            return []
        case .cyanosis:
            return [NailCitation(authors: "Fawcett RS, Linford S, Stulberg DL", year: 2004, title: "Nail abnormalities: clues to systemic disease", journal: "Am Fam Physician", detail: "69(6):1417-24")]
        case .yellowNailSyndrome:
            return [
                NailCitation(authors: "Hoque SR, Mansour S, Mortimer PS", year: 2007, title: "Yellow nail syndrome: not a genetic disorder?", journal: "Br J Dermatol", detail: "156(6):1230-4"),
                NailCitation(authors: "Fawcett RS et al.", year: 2004, title: "Nail abnormalities: clues to systemic disease", journal: "Am Fam Physician", detail: "69(6):1417-24")
            ]
        case .terryNails:
            return [
                NailCitation(authors: "Terry R", year: 1954, title: "White nails in hepatic cirrhosis", journal: "Lancet", detail: "266(6815):757-9"),
                NailCitation(authors: "Holzberg M", year: 2012, title: "The nail in systemic disease", journal: "Baran and Dawber's Diseases of the Nails (4th ed.)", detail: "Wiley-Blackwell")
            ]
        case .lindsaysNails:
            return [NailCitation(authors: "Lindsay PG", year: 1967, title: "The half-and-half nail", journal: "Arch Intern Med", detail: "119(6):583-7")]
        case .leukonychia:
            return [
                NailCitation(authors: "Cashman MW, Sloan SB", year: 2010, title: "Nutrition and nail disease", journal: "Clin Dermatol", detail: "28(4):420-5"),
                NailCitation(authors: "Fawcett RS et al.", year: 2004, title: "Nail abnormalities: clues to systemic disease", journal: "Am Fam Physician", detail: "69(6):1417-24")
            ]
        case .melanonychia:
            return [
                NailCitation(authors: "Levit EK et al.", year: 2000, title: "The ABC rule for clinical detection of subungual melanoma", journal: "J Am Acad Dermatol", detail: "42(2):269-74"),
                NailCitation(authors: "Finley RK 3rd et al.", year: 1994, title: "Subungual melanoma: an eighteen-year review", journal: "Surgery", detail: "116(1):96-100")
            ]
        case .splinterHemorrhage:
            return [
                NailCitation(authors: "Ling LH, Oh JK", year: 1996, title: "Cardiac diseases and the skin", journal: "Dermatol Clin", detail: "14(3):531-41"),
                NailCitation(authors: "Fawcett RS et al.", year: 2004, title: "Nail abnormalities: clues to systemic disease", journal: "Am Fam Physician", detail: "69(6):1417-24")
            ]
        case .redLunula:
            return [NailCitation(authors: "Wilkerson MG, Wilkin JK", year: 1989, title: "Red lunulae revisited: a clinical and histopathologic examination", journal: "J Am Acad Dermatol", detail: "20(3):453-7")]
        case .azureLunula:
            return [NailCitation(authors: "Bearn AG, McKusick VA", year: 1958, title: "Azure lunulae: an unusual change in the fingernails in two patients with hepatolenticular degeneration (Wilson's disease)", journal: "JAMA", detail: "166(8):904-6")]
        case .pallidAnemia:
            return [NailCitation(authors: "Cashman MW, Sloan SB", year: 2010, title: "Nutrition and nail disease", journal: "Clin Dermatol", detail: "28(4):420-5")]
        case .polycythemia:
            return [NailCitation(authors: "Fawcett RS et al.", year: 2004, title: "Nail abnormalities: clues to systemic disease", journal: "Am Fam Physician", detail: "69(6):1417-24")]
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

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
        case .healthy:             return "健康的"
        case .cyanosis:            return "チアノーゼの可能性"
        case .yellowNailSyndrome:  return "黄色爪症候群の可能性"
        case .terryNails:          return "テリー爪の可能性"
        case .lindsaysNails:       return "リンジー爪の可能性"
        case .leukonychia:         return "白色爪の可能性"
        case .melanonychia:        return "黒色線条の可能性"
        case .splinterHemorrhage:  return "線状出血の可能性"
        case .redLunula:           return "赤色爪半月の可能性"
        case .azureLunula:         return "青色爪半月の可能性"
        case .pallidAnemia:        return "蒼白爪の可能性"
        case .polycythemia:        return "深赤色爪の可能性"
        case .unknown:             return "判定できません"
        }
    }

    var titleEN: String {
        switch self {
        case .healthy:             return "Healthy"
        case .cyanosis:            return "Cyanosis"
        case .yellowNailSyndrome:  return "Yellow Nail Syndrome"
        case .terryNails:          return "Terry's Nails"
        case .lindsaysNails:       return "Lindsay's Nails"
        case .leukonychia:         return "Leukonychia"
        case .melanonychia:        return "Melanonychia"
        case .splinterHemorrhage:  return "Splinter Hemorrhage"
        case .redLunula:           return "Red Lunula"
        case .azureLunula:         return "Azure Lunula"
        case .pallidAnemia:        return "Pallid / Anemia"
        case .polycythemia:        return "Polycythemia"
        case .unknown:             return "Unknown"
        }
    }

    var descriptionJP: String {
        switch self {
        case .healthy:
            return "爪の色と見え方は健康的な範囲に見えます。"
        case .cyanosis:
            return "青紫色が強く見えます。酸素飽和度の低下や心肺の不調と関連することがあります。"
        case .yellowNailSyndrome:
            return "黄色みが強く見えます。黄色爪症候群やリンパ浮腫、呼吸器の不調と関連することがあります。"
        case .terryNails:
            return "爪甲が白っぽく、先端だけピンクに見える傾向です。肝疾患、心不全、糖尿病などで報告があります。"
        case .lindsaysNails:
            return "根元が白く、先端が赤茶色に見える傾向です。慢性腎不全との関連が知られています。"
        case .leukonychia:
            return "白っぽさが目立ちます。低アルブミン血症、貧血、肝臓や腎臓の不調と関連することがあります。"
        case .melanonychia:
            return "茶色から黒色の縦すじが疑われます。悪性黒色腫の確認が必要な場合があります。早めに皮膚科へ相談してください。"
        case .splinterHemorrhage:
            return "暗赤色の細い縦線が疑われます。感染性心内膜炎、血管炎、外傷などで見られることがあります。"
        case .redLunula:
            return "爪半月が赤く見える傾向です。心不全、関節リウマチ、COPDなどとの関連が報告されています。"
        case .azureLunula:
            return "爪半月が青く見える傾向です。ウィルソン病などとの関連が報告されています。医師への相談をおすすめします。"
        case .pallidAnemia:
            return "全体的に蒼白に見えます。鉄欠乏性貧血、低アルブミン血症、肝疾患などと関連することがあります。"
        case .polycythemia:
            return "深い赤色が強く見えます。多血症などと関連することがあります。"
        case .unknown:
            return "爪を正面に向け、明るい場所でもう一度スキャンしてください。"
        }
    }

    var descriptionEN: String {
        switch self {
        case .healthy:
            return "Nail color and appearance look healthy."
        case .cyanosis:
            return "Bluish-purple nails can be associated with low oxygen saturation or cardiopulmonary disease."
        case .yellowNailSyndrome:
            return "Yellow nails may be associated with yellow nail syndrome, lymphedema, pleural effusion, or respiratory disease."
        case .terryNails:
            return "White nail plate with a narrow pink distal band. Reported with liver cirrhosis, heart failure, and diabetes."
        case .lindsaysNails:
            return "Proximal white and distal red-brown half-and-half nails. Strongly associated with chronic renal failure."
        case .leukonychia:
            return "White nails may be associated with hypoalbuminemia, anemia, or hepatic and renal disease."
        case .melanonychia:
            return "Brown to black longitudinal streak. Subungual melanoma should be ruled out by a dermatologist."
        case .splinterHemorrhage:
            return "Dark red longitudinal lines. Reported with infective endocarditis, vasculitis, or trauma."
        case .redLunula:
            return "Red lunula has been reported with heart failure, rheumatoid arthritis, COPD, and Alport syndrome."
        case .azureLunula:
            return "Blue lunula may indicate Wilson's disease. Consult a physician."
        case .pallidAnemia:
            return "Pale nails may be associated with iron-deficiency anemia, hypoalbuminemia, and hepatic disease."
        case .polycythemia:
            return "Deep red nails may indicate polycythemia."
        case .unknown:
            return "Face your nail toward the camera in good lighting and try again."
        }
    }

    var urgency: UrgencyLevel {
        switch self {
        case .healthy, .unknown:           return .none
        case .pallidAnemia, .polycythemia,
             .redLunula, .azureLunula:     return .consult
        case .cyanosis, .terryNails,
             .lindsaysNails, .leukonychia,
             .yellowNailSyndrome,
             .splinterHemorrhage:          return .seeDoctor
        case .melanonychia:                return .urgent
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

// MARK: - Urgency

enum UrgencyLevel {
    case none
    case consult
    case seeDoctor
    case urgent

    var labelJP: String {
        switch self {
        case .none:      return ""
        case .consult:   return "気になる場合は相談"
        case .seeDoctor: return "受診をおすすめ"
        case .urgent:    return "早めに皮膚科へ"
        }
    }

    var color: UIColor {
        switch self {
        case .none:      return .systemGray3
        case .consult:   return .systemOrange
        case .seeDoctor: return UIColor(red: 0.90, green: 0.30, blue: 0.10, alpha: 1)
        case .urgent:    return .systemRed
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

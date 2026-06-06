import UIKit
import Foundation

// MARK: - Stored result (Codable for persistence)

struct StoredFingerResult: Codable, Identifiable {
    let id: UUID
    let fingerRaw: String
    let overallStatusRaw: String
    let hue: Double
    let saturation: Double
    let brightness: Double
    let nailColorHex: String

    var finger: Finger { Finger(rawValue: fingerRaw) ?? .index }
    var overallStatus: NailStatus { NailStatus(rawValue: overallStatusRaw) ?? .unknown }
}

// MARK: - Nail color record

struct NailRecord: Codable, Identifiable {
    let id: UUID
    let date: Date
    let results: [StoredFingerResult]
    var note: String

    var dominantStatus: NailStatus {
        let notable = results.map(\.overallStatus)
            .filter { $0 != .softPink && $0 != .unknown }
            .first
        return notable ?? (results.first?.overallStatus ?? .unknown)
    }
}

// MARK: - Repository

final class NailRecordRepository: ObservableObject {
    @Published private(set) var records: [NailRecord] = []

    private let key = "nailRecords_v1"
    private let maxRecords = 90

    init() { load() }

    func save(results: [NailHealthResult], note: String = "") {
        let stored = results.map { r -> StoredFingerResult in
            var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            let color = r.zoneColors.plate ?? UIColor.gray
            color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
            return StoredFingerResult(
                id: UUID(),
                fingerRaw: r.finger.rawValue,
                overallStatusRaw: r.overallStatus.rawValue,
                hue: Double(h),
                saturation: Double(s),
                brightness: Double(b),
                nailColorHex: color.hexString
            )
        }

        let record = NailRecord(id: UUID(), date: Date(), results: stored, note: note)
        records.insert(record, at: 0)
        if records.count > maxRecords { records = Array(records.prefix(maxRecords)) }
        persist()
    }

    func delete(_ record: NailRecord) {
        records.removeAll { $0.id == record.id }
        persist()
    }

    func deleteAll() {
        records = []
        persist()
    }

    // MARK: Private

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([NailRecord].self, from: data) else { return }
        records = decoded
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(records) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}

// MARK: - UIColor hex helper

extension UIColor {
    var hexString: String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X",
                      Int(r * 255), Int(g * 255), Int(b * 255))
    }

    convenience init?(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: h).scanHexInt64(&int)
        let r = CGFloat((int >> 16) & 0xFF) / 255
        let g = CGFloat((int >> 8) & 0xFF) / 255
        let b = CGFloat(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}

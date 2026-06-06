import SwiftUI

struct ResultDetailView: View {
    let results: [NailHealthResult]
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    SectionHeader(
                        title: "色メモ",
                        subtitle: "\(results.count)本のネイル色を記録しました"
                    )
                    ForEach(results) { result in
                        ResultCard(result: result)
                    }
                    PersonalNoteBanner()
                }
                .padding(18)
            }
            .background(NailVitalStyle.pageBackground)
            .navigationTitle("色メモ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        onSave()
                        dismiss()
                    } label: {
                        Label("保存", systemImage: "square.and.arrow.down")
                    }
                }
            }
        }
    }
}

// MARK: - Personal Note

private struct PersonalNoteBanner: View {
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(NailVitalStyle.teal)
                .font(.title3)
            VStack(alignment: .leading, spacing: 4) {
                Text("美容目的の個人メモです")
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(NailVitalStyle.ink)
                Text("ネイル写真、色、見た目の印象を保存して、あとから見返せます。")
                    .font(.caption)
                    .foregroundColor(NailVitalStyle.muted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(NailVitalStyle.teal.opacity(0.09))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

// MARK: - Result Card

struct ResultCard: View {
    let result: NailHealthResult

    var statusColor: Color { Color(result.overallStatus.statusColor) }

    var body: some View {
        VitalCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center, spacing: 12) {
                    NailSwatch(color: result.zoneColors.plate ?? .gray)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(result.finger.nameJP)
                            .font(.headline)
                            .foregroundColor(NailVitalStyle.ink)
                        Text(result.finger.nameEN)
                            .font(.caption)
                            .foregroundColor(NailVitalStyle.muted)
                    }
                    Spacer()
                    StatusPill(
                        text: result.overallStatus.titleJP,
                        icon: result.overallStatus.icon,
                        color: statusColor
                    )
                }

                ZoneStrip(result: result)

                VStack(alignment: .leading, spacing: 6) {
                    Text(result.overallStatus.descriptionJP)
                        .font(.subheadline)
                        .foregroundColor(NailVitalStyle.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(result.overallStatus.descriptionEN)
                        .font(.caption)
                        .foregroundColor(NailVitalStyle.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(spacing: 8) {
                    ColorChip(label: "H", value: Int(result.hue * 360))
                    ColorChip(label: "S", value: Int(result.saturation * 100))
                    ColorChip(label: "B", value: Int(result.brightness * 100))
                }
            }
        }
    }
}

private struct NailSwatch: View {
    let color: UIColor

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(color))
                .frame(width: 42, height: 52)
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.white.opacity(0.72), lineWidth: 2)
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(NailVitalStyle.line, lineWidth: 1)
        }
        .frame(width: 42, height: 52)
    }
}

// MARK: - Zone Strip

private struct ZoneStrip: View {
    let result: NailHealthResult

    var body: some View {
        HStack(spacing: 8) {
            ZoneChip(label: "半月", color: result.zoneColors.lunula ?? .gray, status: result.lunulaStatus)
            ZoneChip(label: "爪甲", color: result.zoneColors.plate ?? .gray, status: result.plateStatus)
            ZoneChip(label: "先端", color: result.zoneColors.tip ?? .gray, status: result.tipStatus)
        }
    }
}

private struct ZoneChip: View {
    let label: String
    let color: UIColor
    let status: NailStatus

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Color(color))
                    .frame(width: 24, height: 14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .stroke(NailVitalStyle.line, lineWidth: 1)
                    )
                Text(label)
                    .font(.caption.weight(.bold))
                    .foregroundColor(NailVitalStyle.ink)
            }
            Text(status.titleJP)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(Color(status.statusColor))
                .lineLimit(1)
                .minimumScaleFactor(0.55)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color.white.opacity(0.56))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(NailVitalStyle.line, lineWidth: 1)
        )
    }
}

// MARK: - Color Chip

private struct ColorChip: View {
    let label: String
    let value: Int

    var body: some View {
        Text("\(label) \(value)")
            .font(.caption2.weight(.semibold))
            .foregroundColor(NailVitalStyle.muted)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(Color.white.opacity(0.62))
            .clipShape(Capsule())
    }
}

import SwiftUI

struct HistoryView: View {
    @ObservedObject var repository: NailRecordRepository
    @State private var selectedRecord: NailRecord?
    @State private var showDeleteAll = false

    var body: some View {
        NavigationStack {
            Group {
                if repository.records.isEmpty {
                    EmptyHistoryView()
                } else {
                    ScrollView {
                        VStack(spacing: 14) {
                            SectionHeader(
                                title: "履歴",
                                subtitle: "保存したスキャンを時系列で確認できます"
                            )
                            ForEach(repository.records) { record in
                                HistoryRow(record: record)
                                    .onTapGesture { selectedRecord = record }
                            }
                        }
                        .padding(18)
                    }
                }
            }
            .background(NailVitalStyle.pageBackground.ignoresSafeArea())
            .navigationTitle("履歴")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !repository.records.isEmpty {
                    ToolbarItem(placement: .destructiveAction) {
                        Button("全削除") { showDeleteAll = true }
                            .foregroundColor(.red)
                    }
                }
            }
            .alert("すべての履歴を削除しますか？", isPresented: $showDeleteAll) {
                Button("削除", role: .destructive) { repository.deleteAll() }
                Button("キャンセル", role: .cancel) {}
            }
            .sheet(item: $selectedRecord) { record in
                RecordDetailView(record: record)
            }
        }
    }
}

// MARK: - Empty

private struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(NailVitalStyle.teal.opacity(0.10))
                    .frame(width: 112, height: 112)
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 48))
                    .foregroundColor(NailVitalStyle.teal)
            }
            Text("まだ履歴がありません")
                .font(.title3.weight(.bold))
                .foregroundColor(NailVitalStyle.ink)
            Text("スキャン結果を保存すると、ここで変化を見返せます。")
                .font(.subheadline)
                .foregroundColor(NailVitalStyle.muted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 34)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - History Row

private struct HistoryRow: View {
    let record: NailRecord

    var statusColor: Color { Color(record.dominantStatus.statusColor) }

    var body: some View {
        VitalCard {
            HStack(spacing: 14) {
                VStack(spacing: 2) {
                    Text(record.date, format: .dateTime.day())
                        .font(.title3.weight(.bold))
                        .foregroundColor(NailVitalStyle.ink)
                    Text(record.date, format: .dateTime.month())
                        .font(.caption.weight(.semibold))
                        .foregroundColor(NailVitalStyle.muted)
                }
                .frame(width: 42)

                Rectangle()
                    .fill(NailVitalStyle.line)
                    .frame(width: 1, height: 46)

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: record.dominantStatus.icon)
                            .foregroundColor(statusColor)
                        Text(record.dominantStatus.titleJP)
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(statusColor)
                    }
                    Text("\(record.results.count)本をスキャン")
                        .font(.caption)
                        .foregroundColor(NailVitalStyle.muted)
                    if !record.note.isEmpty {
                        Text(record.note)
                            .font(.caption2)
                            .foregroundColor(NailVitalStyle.muted)
                            .lineLimit(1)
                    }
                }

                Spacer()

                HStack(spacing: 4) {
                    ForEach(record.results.prefix(5), id: \.id) { r in
                        Circle()
                            .fill(Color(UIColor(hex: r.nailColorHex) ?? .gray))
                            .frame(width: 11, height: 11)
                            .overlay(Circle().stroke(NailVitalStyle.line, lineWidth: 1))
                    }
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(NailVitalStyle.muted)
            }
        }
    }
}

// MARK: - Record Detail

private struct RecordDetailView: View {
    let record: NailRecord
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    LabeledContent("日時") {
                        Text(record.date, format: .dateTime.year().month().day().hour().minute())
                    }
                    LabeledContent("スキャン数") {
                        Text("\(record.results.count)本")
                    }
                    if !record.note.isEmpty {
                        LabeledContent("メモ") { Text(record.note) }
                    }
                }

                Section("指ごとの結果") {
                    ForEach(record.results) { r in
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Color(UIColor(hex: r.nailColorHex) ?? .gray))
                                .frame(width: 22, height: 22)
                                .overlay(Circle().stroke(NailVitalStyle.line, lineWidth: 1))
                            Text(r.finger.nameJP)
                                .font(.subheadline)
                            Spacer()
                            Text(r.overallStatus.titleJP)
                                .font(.caption.weight(.semibold))
                                .foregroundColor(Color(r.overallStatus.statusColor))
                        }
                    }
                }
            }
            .navigationTitle(record.date.formatted(.dateTime.month().day()))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }
}

import SwiftUI

struct ReferencesView: View {

    private let allCitations: [(condition: String, citations: [NailCitation])] = {
        NailStatus.allCases.compactMap { status -> (String, [NailCitation])? in
            guard !status.citations.isEmpty else { return nil }
            return ("\(status.titleJP) / \(status.titleEN)", status.citations)
        }
    }()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    SectionHeader(
                        title: "参考文献",
                        subtitle: "判定の根拠として参照している医学文献です"
                    )

                    VitalCard {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "book.closed.fill")
                                .foregroundColor(NailVitalStyle.teal)
                            Text("各所見に関連する文献を一覧で確認できます。結果は診断ではなく、受診判断の参考として扱ってください。")
                                .font(.subheadline)
                                .foregroundColor(NailVitalStyle.muted)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    ForEach(allCitations.indices, id: \.self) { i in
                        let group = allCitations[i]
                        CitationGroup(condition: group.condition, citations: group.citations)
                    }
                }
                .padding(18)
            }
            .background(NailVitalStyle.pageBackground)
            .navigationTitle("文献")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct CitationGroup: View {
    let condition: String
    let citations: [NailCitation]

    var body: some View {
        VitalCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(condition)
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(NailVitalStyle.ink)
                    Spacer()
                    Text("\(citations.count)")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(NailVitalStyle.teal)
                        .clipShape(Capsule())
                }

                ForEach(citations.indices, id: \.self) { j in
                    FullCitationRow(citation: citations[j])
                    if j != citations.count - 1 {
                        Divider()
                    }
                }
            }
        }
    }
}

private struct FullCitationRow: View {
    let citation: NailCitation

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(citation.authors + " (\(citation.year))")
                .font(.caption.weight(.bold))
                .foregroundColor(NailVitalStyle.ink)
            Text(citation.title)
                .font(.caption)
                .foregroundColor(NailVitalStyle.ink)
            Text("\(citation.journal). \(citation.detail)")
                .font(.caption2)
                .foregroundColor(NailVitalStyle.muted)
                .italic()
        }
        .padding(.vertical, 2)
    }
}

import SwiftUI

@main
struct NailVitalApp: App {
    @AppStorage("disclaimerAccepted") private var disclaimerAccepted = false
    @StateObject private var repository = NailRecordRepository()

    var body: some Scene {
        WindowGroup {
            if disclaimerAccepted {
                RootTabView()
                    .environmentObject(repository)
                    .tint(NailVitalStyle.teal)
            } else {
                DisclaimerView(accepted: $disclaimerAccepted)
                    .tint(NailVitalStyle.teal)
            }
        }
    }
}

// MARK: - Root Tab

struct RootTabView: View {
    @EnvironmentObject var repository: NailRecordRepository

    var body: some View {
        TabView {
            MainCameraView()
                .tabItem {
                    Label("スキャン", systemImage: "camera.viewfinder")
                }

            HistoryView(repository: repository)
                .tabItem {
                    Label("履歴", systemImage: "clock.arrow.circlepath")
                }

            ReferencesView()
                .tabItem {
                    Label("文献", systemImage: "doc.text.magnifyingglass")
                }
        }
    }
}

// MARK: - Disclaimer

struct DisclaimerView: View {
    @Binding var accepted: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                    Spacer(minLength: 20)

                    ZStack {
                        Circle()
                            .fill(NailVitalStyle.blush.opacity(0.18))
                            .frame(width: 132, height: 132)
                        Image(systemName: "hand.raised.fingers.spread")
                            .font(.system(size: 66, weight: .light))
                            .foregroundStyle(NailVitalStyle.teal)
                    }

                    VStack(spacing: 8) {
                        Text("Nail Vital")
                            .font(.system(.largeTitle, design: .serif).weight(.bold))
                            .foregroundColor(NailVitalStyle.ink)
                        Text("爪の色を手がかりに、気づきを残す")
                            .font(.subheadline)
                            .foregroundColor(NailVitalStyle.muted)
                    }

                    VitalCard {
                        VStack(alignment: .leading, spacing: 18) {
                            DisclaimerRow(
                                icon: "exclamationmark.shield",
                                title: "診断アプリではありません",
                                text: "結果は参考情報です。気になる症状がある場合は医師に相談してください。"
                            )
                            DisclaimerRow(
                                icon: "book.closed",
                                title: "医学文献をもとに表示します",
                                text: "爪の色と見え方から、関連が報告されている状態を示します。"
                            )
                            DisclaimerRow(
                                icon: "lock.shield",
                                title: "履歴は端末内に保存します",
                                text: "日々の変化を見返せるよう、スキャン結果を端末に記録できます。"
                            )
                        }
                    }

                    Button {
                        accepted = true
                    } label: {
                        Label("同意してはじめる", systemImage: "arrow.right.circle.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(NailVitalStyle.teal)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                }
                .padding(24)
        }
        .background(NailVitalStyle.pageBackground.ignoresSafeArea())
    }
}

private struct DisclaimerRow: View {
    let icon: String
    let title: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(NailVitalStyle.teal)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(NailVitalStyle.ink)
                Text(text)
                    .font(.caption)
                    .foregroundColor(NailVitalStyle.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

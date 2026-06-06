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
                    Label("記録", systemImage: "camera.viewfinder")
                }

            HistoryView(repository: repository)
                .tabItem {
                    Label("履歴", systemImage: "clock.arrow.circlepath")
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
                        Text("Nailiro Log")
                            .font(.system(.largeTitle, design: .serif).weight(.bold))
                            .foregroundColor(NailVitalStyle.ink)
                        Text("ネイル写真と色のメモを残す")
                            .font(.subheadline)
                            .foregroundColor(NailVitalStyle.muted)
                    }

                    VitalCard {
                        VStack(alignment: .leading, spacing: 18) {
                            DisclaimerRow(
                                icon: "paintpalette",
                                title: "美容メモ用のアプリです",
                                text: "ネイル写真、色、見た目のメモを端末内に残せます。"
                            )
                            DisclaimerRow(
                                icon: "camera",
                                title: "色を自動でメモします",
                                text: "カメラ画像から色の傾向を拾い、あとで見返しやすい名前で保存します。"
                            )
                            DisclaimerRow(
                                icon: "lock.shield",
                                title: "履歴は端末内に保存します",
                                text: "お気に入りの色やデザインをあとから見返せます。"
                            )
                            DisclaimerRow(
                                icon: "info.circle",
                                title: "個人メモとして使えます",
                                text: "ネイルの色やデザインを見返すための記録アプリです。"
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

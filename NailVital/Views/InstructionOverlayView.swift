import SwiftUI

struct InstructionOverlayView: View {
    @Binding var isVisible: Bool

    var body: some View {
        ZStack {
            Color.black.opacity(0.62)
                .ignoresSafeArea()

            VitalCard(padding: 20) {
                VStack(spacing: 18) {
                    VStack(spacing: 6) {
                        Image(systemName: "hand.raised.fingers.spread")
                            .font(.largeTitle)
                            .foregroundColor(NailVitalStyle.teal)
                        Text("きれいに読み取るコツ")
                            .font(.title3.weight(.bold))
                            .foregroundColor(NailVitalStyle.ink)
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        TipRow(icon: "hand.raised", text: "手の甲をカメラに向けます。")
                        TipRow(icon: "ruler", text: "カメラから約15cm離してください。")
                        TipRow(icon: "sun.max", text: "明るい場所で、爪の反射を避けます。")
                        TipRow(icon: "paintpalette", text: "色メモは美容記録として保存できます。")
                    }

                    Button {
                        withAnimation { isVisible = false }
                    } label: {
                        Text("OK")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(NailVitalStyle.teal)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                }
            }
            .padding(24)
        }
    }
}

private struct TipRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(NailVitalStyle.teal)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
                .foregroundColor(NailVitalStyle.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

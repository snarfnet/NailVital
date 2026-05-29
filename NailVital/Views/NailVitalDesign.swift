import SwiftUI

enum NailVitalStyle {
    static let ink = Color(red: 0.10, green: 0.13, blue: 0.16)
    static let muted = Color(red: 0.43, green: 0.47, blue: 0.50)
    static let porcelain = Color(red: 0.98, green: 0.96, blue: 0.93)
    static let blush = Color(red: 0.95, green: 0.68, blue: 0.66)
    static let coral = Color(red: 0.86, green: 0.30, blue: 0.30)
    static let moss = Color(red: 0.18, green: 0.43, blue: 0.35)
    static let teal = Color(red: 0.10, green: 0.48, blue: 0.52)
    static let line = Color.black.opacity(0.08)

    static var pageBackground: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 1.00, green: 0.98, blue: 0.95),
                Color(red: 0.94, green: 0.98, blue: 0.97)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var cameraGlass: LinearGradient {
        LinearGradient(
            colors: [
                Color.black.opacity(0.02),
                Color.black.opacity(0.72)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

struct VitalCard<Content: View>: View {
    var padding: CGFloat = 16
    private let content: Content

    init(padding: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(NailVitalStyle.line, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 16, x: 0, y: 8)
    }
}

struct StatusPill: View {
    let text: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption.bold())
            Text(text)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        }
        .foregroundColor(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.11))
        .clipShape(Capsule())
    }
}

struct SectionHeader: View {
    let title: String
    var subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title2.weight(.bold))
                .foregroundColor(NailVitalStyle.ink)
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(NailVitalStyle.muted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

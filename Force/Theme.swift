import SwiftUI

enum Theme {
    // Brand
    static let primaryCTA = Color(red: 0.27, green: 0.34, blue: 0.94) // indigo-ish
    static let accent2 = Color(red: 0.09, green: 0.80, blue: 0.72) // mint-ish
    static let warning = Color(red: 0.98, green: 0.38, blue: 0.34)

    // Surfaces
    static let cardBackground = Color(.secondarySystemBackground)
    static let hairline = Color(.separator)

    // Layout
    static let corner: CGFloat = 18
    static let cornerSmall: CGFloat = 14
    static let pad: CGFloat = 16

    static var heroGradient: LinearGradient {
        LinearGradient(
            colors: [
                primaryCTA.opacity(0.18),
                accent2.opacity(0.12),
                Color.clear
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func cardStyle(_ content: some View) -> some View {
        content
            .padding(Theme.pad)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: Theme.corner, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.corner, style: .continuous)
                    .strokeBorder(Theme.hairline.opacity(0.6), lineWidth: 0.5)
            )
    }
}



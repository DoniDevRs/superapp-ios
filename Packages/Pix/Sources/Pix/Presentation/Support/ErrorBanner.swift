import SwiftUI
import SuperAppDesignSystem

/// Error banner reused across the flow's screens. Errors are never
/// communicated by color alone (WCAG 2.1 AA) — always with icon + text, and
/// the text is read as a single unit by VoiceOver via `accessibilityElement`.
struct ErrorBanner: View {
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(PixTheme.error)
                .accessibilityHidden(true)
            Text(message)
                .dsFont(DSFont.callout)
                .fontWeight(.medium)
                .foregroundStyle(PixTheme.error)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(PixTheme.error.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(PixTheme.error.opacity(0.4), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Erro: \(message)")
        .accessibilityAddTraits(.isStaticText)
    }
}

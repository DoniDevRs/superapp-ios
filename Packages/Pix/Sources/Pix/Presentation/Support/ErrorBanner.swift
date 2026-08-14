import SwiftUI
import SuperAppDesignSystem

/// Banner de erro reutilizado pelas telas do fluxo. Erros nunca são
/// comunicados apenas por cor (WCAG 2.1 AA) — sempre com ícone + texto, e o
/// texto é lido de uma vez só pelo VoiceOver via `accessibilityElement`.
struct ErrorBanner: View {
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(PixTheme.error)
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

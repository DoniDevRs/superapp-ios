import SwiftUI
import SuperAppDesignSystem

/// Círculo com as iniciais do destinatário, usado na lista de recentes e no
/// card de revisão.
struct RecipientAvatarView: View {
    let initials: String
    var color: Color = DSColor.primary

    var body: some View {
        Circle()
            .fill(color)
            .overlay(
                Text(initials)
                    .dsFont(DSFont.callout)
                    .fontWeight(.semibold)
                    .foregroundStyle(DSColor.textOnPrimary)
                    .minimumScaleFactor(0.7)
            )
            .frame(width: 44, height: 44)
            .accessibilityHidden(true)
    }
}

import SwiftUI

/// Círculo com as iniciais do destinatário, usado na lista de recentes e no
/// card de revisão.
struct RecipientAvatarView: View {
    let initials: String
    var color: Color = PixTheme.primary

    var body: some View {
        Circle()
            .fill(color)
            .overlay(
                Text(initials)
                    .font(.system(.callout, design: .rounded).weight(.semibold))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.7)
            )
            .frame(width: 44, height: 44)
            .accessibilityHidden(true)
    }
}

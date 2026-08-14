import SwiftUI

/// Tokens específicos do fluxo Pix sem equivalente no Design System
/// compartilhado (`SuperAppDesignSystem`). Cores e tipografia de marca vivem
/// em `DSColor`/`DSFont` (regra do CLAUDE.md: "Não duplicar componentes
/// visuais — sempre checar o Design System primeiro").
public enum PixTheme {
    /// Cor de estados de erro. Sem equivalente semântico no Design System.
    public static let error = Color(red: 0.71, green: 0.11, blue: 0.11)

    /// Alvo de toque mínimo recomendado (ver anotação do protótipo: "alvos ≥48px").
    public static let minimumTapTarget: CGFloat = 48
}

import SwiftUI

/// Tokens de cor/tipografia usados pelas telas do fluxo Pix, no espírito da
/// direção visual "Sereno — claro, institucional, azul da casa" do protótipo
/// (design/images/pix-depois.png).
///
/// Nota: hoje o repositório não tem um módulo `DesignSystem` compartilhado
/// (ver CLAUDE.md). Estes tokens vivem localmente no módulo Pix apenas para
/// viabilizar este scaffold inicial — quando o módulo DesignSystem existir,
/// eles devem migrar para lá para evitar duplicação entre features (regra do
/// CLAUDE.md: "Não duplicar componentes visuais — sempre checar o Design
/// System primeiro").
public enum PixTheme {
    /// Azul institucional usado em CTAs e na tela de confirmação.
    public static let primary = Color(red: 0.043, green: 0.157, blue: 0.357)
    public static let background = Color(uiColor: .systemBackground)
    public static let secondaryBackground = Color(uiColor: .secondarySystemBackground)
    public static let separator = Color(uiColor: .separator)
    public static let error = Color(red: 0.71, green: 0.11, blue: 0.11)

    /// Alvo de toque mínimo recomendado (ver anotação do protótipo: "alvos ≥48px").
    public static let minimumTapTarget: CGFloat = 48
}

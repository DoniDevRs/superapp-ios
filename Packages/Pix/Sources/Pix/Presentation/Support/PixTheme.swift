import SwiftUI
import UIKit

/// Tokens específicos do fluxo Pix sem equivalente no Design System
/// compartilhado (`SuperAppDesignSystem`). Cores e tipografia de marca vivem
/// em `DSColor`/`DSFont` (regra do CLAUDE.md: "Não duplicar componentes
/// visuais — sempre checar o Design System primeiro").
public enum PixTheme {
    /// Cor de estados de erro. Sem equivalente semântico no Design System.
    ///
    /// Adaptável a light/dark: a versão anterior era uma cor fixa
    /// (0.71, 0.11, 0.11) que, sobre `ErrorBanner`, media ~2.66:1 de
    /// contraste em modo escuro — abaixo do mínimo de 4.5:1 da WCAG 2.1 AA
    /// (achado da auditoria de acessibilidade de 2026-08-14). A variante de
    /// modo escuro abaixo foi calculada pela fórmula de luminância relativa
    /// da WCAG para manter ≥4.5:1 nos dois modos (~5.1:1 claro / ~5.7:1 escuro).
    public static let error = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 1.00, green: 0.41, blue: 0.38, alpha: 1) // #FF6961
            : UIColor(red: 0.71, green: 0.11, blue: 0.11, alpha: 1) // #B51C1C
    })

    /// Alvo de toque mínimo recomendado (ver anotação do protótipo: "alvos ≥48px").
    public static let minimumTapTarget: CGFloat = 48
}

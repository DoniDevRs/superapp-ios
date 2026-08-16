import SwiftUI
import UIKit

/// Tokens specific to the Pix flow with no equivalent in the shared Design
/// System (`SuperAppDesignSystem`). Brand colors and typography live in
/// `DSColor`/`DSFont` (CLAUDE.md rule: "Don't duplicate visual components —
/// always check the Design System first").
public enum PixTheme {
    /// Color for error states. No semantic equivalent in the Design System.
    ///
    /// Adaptive to light/dark: the previous version was a fixed color
    /// (0.71, 0.11, 0.11) that, over `ErrorBanner`, measured ~2.66:1
    /// contrast in dark mode — below the WCAG 2.1 AA minimum of 4.5:1
    /// (finding from the 2026-08-14 accessibility audit). The dark mode
    /// variant below was calculated using WCAG's relative luminance
    /// formula to keep ≥4.5:1 in both modes (~5.1:1 light / ~5.7:1 dark).
    public static let error = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 1.00, green: 0.41, blue: 0.38, alpha: 1) // #FF6961
            : UIColor(red: 0.71, green: 0.11, blue: 0.11, alpha: 1) // #B51C1C
    })

    /// Recommended minimum tap target (see prototype annotation: "alvos ≥48px").
    public static let minimumTapTarget: CGFloat = 48
}

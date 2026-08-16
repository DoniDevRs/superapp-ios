import SwiftUI
import SuperAppDesignSystem

/// Numeric keypad used on the amount screen, with ≥48pt tap targets
/// (see prototype annotation) and Dynamic Type support on the labels.
struct NumericKeypad: View {
    let onDigit: (String) -> Void
    let onDelete: () -> Void

    private let rows: [[String]] = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        [",", "0", "⌫"]
    ]

    var body: some View {
        VStack(spacing: 12) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.self) { key in
                        keyButton(key)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func keyButton(_ key: String) -> some View {
        Button {
            if key == "⌫" {
                onDelete()
            } else {
                onDigit(key)
            }
        } label: {
            Text(key)
                .dsFont(DSFont.title)
                .frame(maxWidth: .infinity)
                .frame(minHeight: PixTheme.minimumTapTarget)
        }
        .buttonStyle(.plain)
        .background(DSColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .accessibilityLabel(accessibilityLabel(for: key))
    }

    private func accessibilityLabel(for key: String) -> String {
        switch key {
        case "⌫": return "Apagar último dígito"
        case ",": return "Vírgula"
        default: return key
        }
    }
}

import SwiftUI
import SuperAppDesignSystem

/// "Label on the left / value on the right" row, reused by the review
/// screen (light background, e.g., "De", "Quando", "Tarifa") and by the
/// confirmation screen (blue success background, e.g., "Banco", "ID") —
/// avoids duplicating layout and accessibility between the two screens.
struct PixDetailRow: View {
    let label: String
    let value: String
    var labelColor: Color = DSColor.textSecondary
    var valueColor: Color = DSColor.textPrimary
    var valueWeight: Font.Weight = .regular

    var body: some View {
        HStack {
            Text(label)
                .dsFont(DSFont.body)
                .foregroundStyle(labelColor)
            Spacer()
            Text(value)
                .dsFont(DSFont.body)
                .foregroundStyle(valueColor)
                .fontWeight(valueWeight)
        }
        .padding(16)
        .frame(minHeight: PixTheme.minimumTapTarget)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}

import Foundation

/// Currency formatting shared between features (see plan.md: "add only what
/// is generic enough for other features, e.g., currency formatting"). Used
/// today by the Pix feature to display values in the "R$ 250,00" pattern.
public enum CurrencyFormatter {
    public static func string(from amount: Decimal, locale: Locale = Locale(identifier: "pt_BR")) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        formatter.currencyCode = "BRL"
        return formatter.string(from: amount as NSDecimalNumber) ?? "R$ 0,00"
    }

    /// Converts text typed on a numeric keypad (e.g., "25000" -> 250,00)
    /// to `Decimal`, in the same spirit as the Pix amount screen's keypad.
    public static func decimal(fromTypedDigits digits: String) -> Decimal {
        let onlyDigits = digits.filter(\.isNumber)
        guard !onlyDigits.isEmpty, let value = Decimal(string: onlyDigits) else {
            return 0
        }
        return value / 100
    }
}

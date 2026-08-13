import Foundation

/// Formatação de moeda compartilhada entre features (ver plan.md: "adicionar
/// apenas o que for genérico o suficiente para outras features, ex.:
/// formatação de moeda"). Usado hoje pela feature Pix para exibir valores no
/// padrão "R$ 250,00".
public enum CurrencyFormatter {
    public static func string(from amount: Decimal, locale: Locale = Locale(identifier: "pt_BR")) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        formatter.currencyCode = "BRL"
        return formatter.string(from: amount as NSDecimalNumber) ?? "R$ 0,00"
    }

    /// Converte texto digitado em um teclado numérico (ex.: "25000" -> 250,00)
    /// para `Decimal`, no mesmo espírito do teclado da tela de valor do Pix.
    public static func decimal(fromTypedDigits digits: String) -> Decimal {
        let onlyDigits = digits.filter(\.isNumber)
        guard !onlyDigits.isEmpty, let value = Decimal(string: onlyDigits) else {
            return 0
        }
        return value / 100
    }
}

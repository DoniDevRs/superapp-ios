import Foundation

/// Saldo disponível na conta de origem usada para a transferência.
public struct PixAccountBalance: Equatable {
    public let sourceAccountLabel: String
    public let amount: Decimal

    public init(sourceAccountLabel: String, amount: Decimal) {
        self.sourceAccountLabel = sourceAccountLabel
        self.amount = amount
    }
}

import Foundation

/// Available balance in the source account used for the transfer.
public struct PixAccountBalance: Equatable {
    public let sourceAccountLabel: String
    public let amount: Decimal

    public init(sourceAccountLabel: String, amount: Decimal) {
        self.sourceAccountLabel = sourceAccountLabel
        self.amount = amount
    }
}

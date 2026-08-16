import Foundation

/// Single business rule for transfer amount validation: the amount must be
/// greater than zero and less than or equal to the available balance (see
/// plan.md). This is the single source of truth for this rule — no other
/// layer should reimplement it.
public protocol ValidateTransferAmountUseCase {
    func validate(amount: Decimal, balance: Decimal) throws
}

public final class DefaultValidateTransferAmountUseCase: ValidateTransferAmountUseCase {
    public init() {}

    public func validate(amount: Decimal, balance: Decimal) throws {
        guard amount > 0 else {
            throw PixError.invalidAmount
        }
        guard amount <= balance else {
            throw PixError.insufficientBalance
        }
    }
}

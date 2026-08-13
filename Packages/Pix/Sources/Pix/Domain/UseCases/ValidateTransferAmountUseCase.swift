import Foundation

/// Regra de negócio única para validação de valor de transferência: o valor
/// deve ser maior que zero e menor ou igual ao saldo disponível (ver
/// plan.md). Esta é a única fonte de verdade dessa regra — nenhuma outra
/// camada deve reimplementá-la.
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

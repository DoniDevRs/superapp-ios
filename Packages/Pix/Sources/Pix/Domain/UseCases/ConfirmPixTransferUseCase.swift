import Foundation

public protocol ConfirmPixTransferUseCase {
    func execute(recipient: PixRecipient, amount: Decimal, message: String?) async throws -> PixTransferReceipt
}

public final class DefaultConfirmPixTransferUseCase: ConfirmPixTransferUseCase {
    private let repository: PixRepository

    public init(repository: PixRepository) {
        self.repository = repository
    }

    public func execute(recipient: PixRecipient, amount: Decimal, message: String?) async throws -> PixTransferReceipt {
        try await repository.confirmTransfer(recipient: recipient, amount: amount, message: message)
    }
}

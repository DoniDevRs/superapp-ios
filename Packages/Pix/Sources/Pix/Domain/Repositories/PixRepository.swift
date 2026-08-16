import Foundation

/// Data source for the Pix feature (recipients, balance, and transfer
/// confirmation). Presentation never talks to this protocol directly —
/// only through the Use Cases (see `Domain/UseCases`).
public protocol PixRepository {
    func fetchRecentRecipients() async throws -> [PixRecipient]
    func fetchAccountBalance() async throws -> PixAccountBalance
    func confirmTransfer(recipient: PixRecipient, amount: Decimal, message: String?) async throws -> PixTransferReceipt
}

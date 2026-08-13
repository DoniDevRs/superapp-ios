import Foundation

/// Fonte de dados da feature Pix (destinatários, saldo e confirmação de
/// transferência). A Presentation nunca fala com este protocolo diretamente
/// — apenas através dos Use Cases (ver `Domain/UseCases`).
public protocol PixRepository {
    func fetchRecentRecipients() async throws -> [PixRecipient]
    func fetchAccountBalance() async throws -> PixAccountBalance
    func confirmTransfer(recipient: PixRecipient, amount: Decimal, message: String?) async throws -> PixTransferReceipt
}

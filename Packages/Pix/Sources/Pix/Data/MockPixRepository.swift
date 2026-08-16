import Foundation

/// Mocked implementation of `PixRepository`, used while the integration
/// with the Java API (`superapp-api`) is not yet available (see tasks.md,
/// Phase 0, item 2 — API contracts still to be aligned with the backend).
/// The data here mirrors the prototype in design/images/pix-depois.png.
///
/// Once the API contracts are defined, this class is replaced by a
/// `PixRepositoryImpl` that uses `Core.NetworkClient` — the rest of the
/// feature (Use Cases, ViewModel, Views, Coordinator) doesn't change.
public final class MockPixRepository: PixRepository {
    public init() {}

    public func fetchRecentRecipients() async throws -> [PixRecipient] {
        try? await Task.sleep(nanoseconds: 300_000_000)
        return [
            PixRecipient(
                id: "1",
                name: "Ana Souza",
                initials: "AS",
                bankName: "Banco Exemplo",
                keyMasked: "***.456.789-**",
                lastTransactionLabel: "ontem"
            ),
            PixRecipient(
                id: "2",
                name: "Rafael Mota",
                initials: "RM",
                bankName: "Cooperativa",
                keyMasked: "***.321.654-**",
                lastTransactionLabel: "3 dias"
            ),
            PixRecipient(
                id: "3",
                name: "Padaria Lopes",
                initials: "PL",
                bankName: "CNPJ",
                keyMasked: "**.***.789/0001-**",
                lastTransactionLabel: "1 semana"
            )
        ]
    }

    public func fetchAccountBalance() async throws -> PixAccountBalance {
        try? await Task.sleep(nanoseconds: 200_000_000)
        return PixAccountBalance(sourceAccountLabel: "Conta corrente ·1234", amount: 4120.58)
    }

    public func confirmTransfer(recipient: PixRecipient, amount: Decimal, message: String?) async throws -> PixTransferReceipt {
        try? await Task.sleep(nanoseconds: 500_000_000)

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "d MMM yyyy, HH:mm"

        return PixTransferReceipt(
            recipient: recipient,
            amount: amount,
            sourceAccountLabel: "CC ·1234",
            bankName: recipient.bankName,
            transactionId: "E\(Int.random(in: 1000...9999))·\(Int.random(in: 1000...9999))",
            dateLabel: formatter.string(from: Date())
        )
    }
}

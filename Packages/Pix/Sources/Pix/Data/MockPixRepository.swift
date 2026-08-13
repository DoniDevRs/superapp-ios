import Foundation

/// Implementação mockada de `PixRepository`, usada enquanto a integração
/// com a API Java (`superapp-api`) não está disponível (ver tasks.md, Fase 0,
/// item 2 — contratos de API ainda a alinhar com o backend). Os dados aqui
/// espelham o protótipo em design/images/pix-depois.png.
///
/// Quando os contratos de API forem definidos, esta classe é substituída por
/// um `PixRepositoryImpl` que usa `Core.NetworkClient` — o restante da
/// feature (Use Cases, ViewModel, Views, Coordinator) não muda.
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

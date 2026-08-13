import Foundation
@testable import Pix

/// Dublê de teste para `PixRepository`. Não deve ser confundido com
/// `MockPixRepository` (em `Sources/Pix/Data`), que é o mock usado em tempo
/// de execução pelo app enquanto a API real não está disponível — este tipo
/// existe só para isolar o `PixViewModel` da rede/dados reais nos testes.
final class PixRepositoryStub: PixRepository {
    var recipientsResult: Result<[PixRecipient], Error> = .success([])
    var balanceResult: Result<PixAccountBalance, Error> = .success(
        PixAccountBalance(sourceAccountLabel: "Conta corrente ·1234", amount: 1000)
    )
    var confirmResult: Result<PixTransferReceipt, Error> = .failure(PixError.unknown)
    /// Atraso artificial antes de resolver `confirmResult`, usado para
    /// testar comportamento enquanto a chamada está "em voo" (ex.: guard de
    /// reentrância, `isLoading`/`canConfirmTransfer` durante o envio).
    var confirmDelayNanoseconds: UInt64 = 0

    private(set) var confirmTransferCallCount = 0

    func fetchRecentRecipients() async throws -> [PixRecipient] {
        try recipientsResult.get()
    }

    func fetchAccountBalance() async throws -> PixAccountBalance {
        try balanceResult.get()
    }

    func confirmTransfer(recipient: PixRecipient, amount: Decimal, message: String?) async throws -> PixTransferReceipt {
        confirmTransferCallCount += 1
        if confirmDelayNanoseconds > 0 {
            try? await Task.sleep(nanoseconds: confirmDelayNanoseconds)
        }
        return try confirmResult.get()
    }
}

extension PixRecipient {
    static func stub(id: String = "1", name: String = "Ana Souza") -> PixRecipient {
        PixRecipient(
            id: id,
            name: name,
            initials: "AS",
            bankName: "Banco Exemplo",
            keyMasked: "***.456.789-**",
            lastTransactionLabel: "ontem"
        )
    }
}

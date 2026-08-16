import Foundation
@testable import Pix

/// Test double for `PixRepository`. Not to be confused with
/// `MockPixRepository` (in `Sources/Pix/Data`), which is the mock used at
/// runtime by the app while the real API isn't available — this type
/// exists only to isolate `PixViewModel` from real network/data in tests.
final class PixRepositoryStub: PixRepository {
    var recipientsResult: Result<[PixRecipient], Error> = .success([])
    var balanceResult: Result<PixAccountBalance, Error> = .success(
        PixAccountBalance(sourceAccountLabel: "Conta corrente ·1234", amount: 1000)
    )
    var confirmResult: Result<PixTransferReceipt, Error> = .failure(PixError.unknown)
    /// Artificial delay before resolving `confirmResult`, used to test
    /// behavior while the call is "in flight" (e.g., reentrancy guard,
    /// `isLoading`/`canConfirmTransfer` during submission).
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

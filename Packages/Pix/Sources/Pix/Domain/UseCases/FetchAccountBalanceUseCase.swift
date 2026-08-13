import Foundation

public protocol FetchAccountBalanceUseCase {
    func execute() async throws -> PixAccountBalance
}

public final class DefaultFetchAccountBalanceUseCase: FetchAccountBalanceUseCase {
    private let repository: PixRepository

    public init(repository: PixRepository) {
        self.repository = repository
    }

    public func execute() async throws -> PixAccountBalance {
        try await repository.fetchAccountBalance()
    }
}

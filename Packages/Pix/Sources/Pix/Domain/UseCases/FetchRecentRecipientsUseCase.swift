import Foundation

public protocol FetchRecentRecipientsUseCase {
    func execute() async throws -> [PixRecipient]
}

public final class DefaultFetchRecentRecipientsUseCase: FetchRecentRecipientsUseCase {
    private let repository: PixRepository

    public init(repository: PixRepository) {
        self.repository = repository
    }

    public func execute() async throws -> [PixRecipient] {
        try await repository.fetchRecentRecipients()
    }
}

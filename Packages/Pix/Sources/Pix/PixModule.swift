import UIKit

/// Composition root of the Pix module.
///
/// Builds the `PixCoordinator` with all of its dependencies (Use Cases on
/// top of the mocked repository — see `MockPixRepository`), so that the App
/// module only needs to know this single entry point (see plan.md: "App —
/// register the PixTransferCoordinator and its dependencies in the
/// composition root/DI").
///
/// Once the integration with the Java API is ready, only the repository
/// injected here changes (from `MockPixRepository` to a `PixRepositoryImpl`
/// that uses `Core.NetworkClient`) — nothing else in the feature needs to change.
public enum PixModule {
    @MainActor
    public static func makeCoordinator(navigationController: UINavigationController) -> PixCoordinator {
        let repository = MockPixRepository()

        let viewModel = PixViewModel(
            fetchRecentRecipientsUseCase: DefaultFetchRecentRecipientsUseCase(repository: repository),
            fetchAccountBalanceUseCase: DefaultFetchAccountBalanceUseCase(repository: repository),
            validateTransferAmountUseCase: DefaultValidateTransferAmountUseCase(),
            confirmPixTransferUseCase: DefaultConfirmPixTransferUseCase(repository: repository)
        )

        return PixCoordinator(navigationController: navigationController, viewModel: viewModel)
    }
}

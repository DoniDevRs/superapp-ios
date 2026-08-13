import UIKit

/// Composition root do módulo Pix.
///
/// Monta o `PixCoordinator` com todas as suas dependências (Use Cases sobre
/// o repositório mockado — ver `MockPixRepository`), para que o módulo App
/// só precise conhecer este ponto de entrada único (ver plan.md: "App —
/// registrar o PixTransferCoordinator e suas dependências no composition
/// root/DI").
///
/// Quando a integração com a API Java estiver pronta, apenas o repositório
/// injetado aqui muda (de `MockPixRepository` para um `PixRepositoryImpl`
/// que usa `Core.NetworkClient`) — nada no restante da feature precisa mudar.
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

import UIKit
import SwiftUI
import Core

/// Coordinator (UIKit) do fluxo de Transferência via Pix.
///
/// Orquestra a navegação entre as 3 telas do fluxo — `SelectRecipientView`,
/// `ReviewPaymentView` e `ConfirmationView` — cada uma envolvida em um
/// `UIHostingController`. Nenhuma das Views/ViewModels navega diretamente:
/// elas comunicam intenção via closures, e é este tipo que decide para onde
/// ir (regra do CLAUDE.md: "Nunca criar navegação fora do Coordinator").
public final class PixCoordinator: Coordinator {
    public let navigationController: UINavigationController
    public var childCoordinators: [Coordinator] = []

    /// Chamado quando o fluxo termina (usuário volta ao início após sucesso
    /// ou erro), para que o coordinator pai possa reagir — ex.: remover este
    /// coordinator da lista de filhos, voltar para a home do super-app.
    public var onFinish: (() -> Void)?

    private let viewModel: PixViewModel

    public init(navigationController: UINavigationController, viewModel: PixViewModel) {
        self.navigationController = navigationController
        self.viewModel = viewModel
    }

    public func start() {
        showSelectRecipient()
    }

    // MARK: - Telas

    private func showSelectRecipient() {
        let view = SelectRecipientView(viewModel: viewModel) { [weak self] in
            self?.showReviewPayment()
        }
        let hosting = UIHostingController(rootView: view)
        navigationController.setViewControllers([hosting], animated: false)
    }

    private func showReviewPayment() {
        let view = ReviewPaymentView(
            viewModel: viewModel,
            onChangeRecipient: { [weak self] in
                self?.navigationController.popViewController(animated: true)
            },
            onTransferConfirmed: { [weak self] in
                self?.showConfirmation()
            }
        )
        let hosting = UIHostingController(rootView: view)
        navigationController.pushViewController(hosting, animated: true)
    }

    private func showConfirmation() {
        let view = ConfirmationView(
            viewModel: viewModel,
            onFinish: { [weak self] in
                self?.finish()
            },
            onRepeat: { [weak self] in
                self?.repeatTransfer()
            }
        )
        let hosting = UIHostingController(rootView: view)
        // A saída desta tela deve sempre passar por "Voltar ao início" ou
        // "Repetir", que resetam o estado do PixViewModel — desabilita o
        // gesto de swipe-back para que o usuário não contorne o Coordinator
        // e deixe a tela de revisão com o comprovante/erro obsoleto.
        navigationController.interactivePopGestureRecognizer?.isEnabled = false
        navigationController.pushViewController(hosting, animated: true)
    }

    // MARK: - Transições de estado

    /// "Repetir para {nome}" — mantém o destinatário, limpa valor/mensagem e
    /// volta para a tela de valor/revisão (já presente na pilha).
    private func repeatTransfer() {
        guard let recipient = viewModel.receipt?.recipient else { return }
        viewModel.startNewTransfer(keepingRecipient: recipient)
        navigationController.interactivePopGestureRecognizer?.isEnabled = true
        navigationController.popViewController(animated: true)
    }

    /// "Voltar ao início" — reseta o fluxo por completo e volta para a
    /// primeira tela, notificando o coordinator pai.
    private func finish() {
        viewModel.resetFlow()
        navigationController.interactivePopGestureRecognizer?.isEnabled = true
        navigationController.popToRootViewController(animated: true)
        onFinish?()
    }
}

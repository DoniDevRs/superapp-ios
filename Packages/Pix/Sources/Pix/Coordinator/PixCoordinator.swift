import UIKit
import SwiftUI
import Core

/// Coordinator (UIKit) for the Pix Transfer flow.
///
/// Orchestrates navigation between the flow's 3 screens — `SelectRecipientView`,
/// `ReviewPaymentView`, and `ConfirmationView` — each wrapped in a
/// `UIHostingController`. None of the Views/ViewModels navigate directly:
/// they communicate intent via closures, and this type decides where to
/// go (CLAUDE.md rule: "Never create navigation outside the Coordinator").
public final class PixCoordinator: Coordinator {
    public let navigationController: UINavigationController
    public var childCoordinators: [Coordinator] = []

    /// Called when the flow ends (user returns to the start after success
    /// or error), so the parent coordinator can react — e.g., remove this
    /// coordinator from the children list, return to the super-app's home.
    public var onFinish: (() -> Void)?

    private let viewModel: PixViewModel

    public init(navigationController: UINavigationController, viewModel: PixViewModel) {
        self.navigationController = navigationController
        self.viewModel = viewModel
    }

    public func start() {
        showSelectRecipient()
    }

    // MARK: - Screens

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
        // Exiting this screen must always go through "Voltar ao início" or
        // "Repetir", which reset the PixViewModel's state — disable the
        // swipe-back gesture so the user can't bypass the Coordinator and
        // leave the review screen with a stale receipt/error.
        navigationController.interactivePopGestureRecognizer?.isEnabled = false
        navigationController.pushViewController(hosting, animated: true)
    }

    // MARK: - State transitions

    /// "Repetir para {nome}" — keeps the recipient, clears amount/message,
    /// and returns to the amount/review screen (already on the stack).
    private func repeatTransfer() {
        guard let recipient = viewModel.receipt?.recipient else { return }
        viewModel.startNewTransfer(keepingRecipient: recipient)
        navigationController.interactivePopGestureRecognizer?.isEnabled = true
        navigationController.popViewController(animated: true)
    }

    /// "Voltar ao início" — fully resets the flow and returns to the
    /// first screen, notifying the parent coordinator.
    private func finish() {
        viewModel.resetFlow()
        navigationController.interactivePopGestureRecognizer?.isEnabled = true
        navigationController.popToRootViewController(animated: true)
        onFinish?()
    }
}

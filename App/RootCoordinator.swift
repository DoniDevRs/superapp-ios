import UIKit
import Core
import Pix

/// Root Coordinator of the app — the navigation composition root.
///
/// Today the super-app only has the Pix journey, so `RootCoordinator` starts
/// it directly. In an app with more journeys, this would be the place to
/// decide which feature to open (e.g., from a home/tab bar), always
/// delegating each flow's navigation to that module's Coordinator — never
/// navigating "midway" outside of a Coordinator.
@MainActor
final class RootCoordinator: ObservableObject, Coordinator {
    let navigationController = UINavigationController()
    var childCoordinators: [Coordinator] = []

    func start() {
        let pixCoordinator = PixModule.makeCoordinator(navigationController: navigationController)
        pixCoordinator.onFinish = { [weak self, weak pixCoordinator] in
            guard let self, let pixCoordinator else { return }
            self.removeChild(pixCoordinator)
        }
        addChild(pixCoordinator)
        pixCoordinator.start()
    }
}

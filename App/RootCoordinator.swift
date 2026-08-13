import UIKit
import Core
import Pix

/// Coordinator raiz do app — o composition root de navegação.
///
/// Hoje o super-app só tem a jornada de Pix, então o `RootCoordinator` a
/// inicia diretamente. Em um app com mais jornadas, este seria o lugar para
/// decidir qual feature abrir (ex.: a partir de uma home/tab bar), sempre
/// delegando a navegação de cada fluxo ao Coordinator daquele módulo — nunca
/// navegando "no meio do caminho" fora de um Coordinator.
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

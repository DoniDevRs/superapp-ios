import UIKit

/// Contrato base para qualquer Coordinator do app.
///
/// Regra do projeto (ver CLAUDE.md): nenhuma navegação deve ser criada fora de
/// um Coordinator. Views e ViewModels nunca devem instanciar ou empurrar
/// `UIViewController`s diretamente — elas comunicam intenção (via closures ou
/// delegates) e quem decide "para onde ir" é sempre um tipo que conforma a
/// este protocolo.
@MainActor
public protocol Coordinator: AnyObject {
    /// Navigation controller que este coordinator controla.
    var navigationController: UINavigationController { get }

    /// Coordinators filhos mantidos vivos enquanto seus fluxos estão ativos.
    var childCoordinators: [Coordinator] { get set }

    /// Inicia o fluxo deste coordinator.
    func start()
}

public extension Coordinator {
    /// Adiciona um coordinator filho à lista de filhos vivos.
    func addChild(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }

    /// Remove um coordinator filho, tipicamente ao final do fluxo dele.
    func removeChild(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
}

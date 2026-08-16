import UIKit

/// Base contract for any Coordinator in the app.
///
/// Project rule (see CLAUDE.md): no navigation should be created outside of
/// a Coordinator. Views and ViewModels should never instantiate or push
/// `UIViewController`s directly — they communicate intent (via closures or
/// delegates), and the type that decides "where to go" always conforms to
/// this protocol.
@MainActor
public protocol Coordinator: AnyObject {
    /// Navigation controller this coordinator controls.
    var navigationController: UINavigationController { get }

    /// Child coordinators kept alive while their flows are active.
    var childCoordinators: [Coordinator] { get set }

    /// Starts this coordinator's flow.
    func start()
}

public extension Coordinator {
    /// Adds a child coordinator to the list of live children.
    func addChild(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }

    /// Removes a child coordinator, typically at the end of its flow.
    func removeChild(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
}

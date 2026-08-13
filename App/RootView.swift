import SwiftUI
import UIKit

/// Ponte entre o SwiftUI `App` lifecycle e a navegação raiz em UIKit
/// controlada pelo `RootCoordinator`.
struct RootView: UIViewControllerRepresentable {
    let coordinator: RootCoordinator

    func makeUIViewController(context: Context) -> UINavigationController {
        coordinator.start()
        return coordinator.navigationController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // Toda navegação subsequente é responsabilidade dos Coordinators —
        // não há estado para sincronizar aqui.
    }
}

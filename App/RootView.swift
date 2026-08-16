import SwiftUI
import UIKit

/// Bridge between the SwiftUI `App` lifecycle and the root navigation in UIKit
/// controlled by `RootCoordinator`.
struct RootView: UIViewControllerRepresentable {
    let coordinator: RootCoordinator

    func makeUIViewController(context: Context) -> UINavigationController {
        coordinator.start()
        return coordinator.navigationController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // All subsequent navigation is the Coordinators' responsibility —
        // there is no state to sync here.
    }
}

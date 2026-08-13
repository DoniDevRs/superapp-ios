import SwiftUI

/// Ponto de entrada do app. Monta a navegação raiz via `RootCoordinator`
/// (UIKit) e a expõe ao SwiftUI através de `RootView`.
@main
struct SuperAppApp: App {
    @StateObject private var rootCoordinator = RootCoordinator()

    var body: some Scene {
        WindowGroup {
            RootView(coordinator: rootCoordinator)
                .ignoresSafeArea()
        }
    }
}

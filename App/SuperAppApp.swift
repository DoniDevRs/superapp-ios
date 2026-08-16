import SwiftUI

/// Entry point of the app. Builds the root navigation via `RootCoordinator`
/// (UIKit) and exposes it to SwiftUI through `RootView`.
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

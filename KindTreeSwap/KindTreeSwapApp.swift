import Core
import SwiftUI

@main
struct KindTreeSwapApp: App {
    @State private var container = AppContainer(environment: .fromBundle())

    var body: some Scene {
        WindowGroup {
            RootView(container: container)
        }
    }
}

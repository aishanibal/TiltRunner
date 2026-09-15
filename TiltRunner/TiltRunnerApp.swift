import SwiftUI
import FirebaseCore

@main
struct TiltRunnerApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            MainMenuView()
        }
    }
}

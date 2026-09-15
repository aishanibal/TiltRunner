import SwiftUI

@main
struct TiltRunnerApp: App {
    @ObservedObject private var authManager = AuthManager.shared

    var body: some Scene {
        WindowGroup {
            if authManager.isLoggedIn {
                MainMenuView()
            } else {
                LoginView()
            }
        }
    }
}

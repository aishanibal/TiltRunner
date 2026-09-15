import Foundation

/// Holds the current session, persisted in UserDefaults across launches.
/// Storing the token here (rather than Keychain) is a scope tradeoff for
/// this assignment, not something to carry into a production app.
@MainActor
final class AuthManager: ObservableObject {
    static let shared = AuthManager()

    @Published private(set) var username: String?
    @Published private(set) var token: String?

    private let tokenKey = "tiltrunner.authToken"
    private let usernameKey = "tiltrunner.username"

    private init() {
        token = UserDefaults.standard.string(forKey: tokenKey)
        username = UserDefaults.standard.string(forKey: usernameKey)
    }

    var isLoggedIn: Bool { token != nil }

    func setSession(token: String, username: String) {
        self.token = token
        self.username = username
        UserDefaults.standard.set(token, forKey: tokenKey)
        UserDefaults.standard.set(username, forKey: usernameKey)
    }

    func logOut() {
        token = nil
        username = nil
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: usernameKey)
    }
}

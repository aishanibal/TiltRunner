import Foundation

enum AuthService {
    private struct Credentials: Encodable {
        let username: String
        let password: String
    }

    private struct AuthResponse: Decodable {
        let token: String
        let username: String
    }

    static func register(username: String, password: String) async throws -> (token: String, username: String) {
        let response: AuthResponse = try await APIClient.post(
            "auth/register",
            body: Credentials(username: username, password: password)
        )
        return (response.token, response.username)
    }

    static func logIn(username: String, password: String) async throws -> (token: String, username: String) {
        let response: AuthResponse = try await APIClient.post(
            "auth/login",
            body: Credentials(username: username, password: password)
        )
        return (response.token, response.username)
    }
}

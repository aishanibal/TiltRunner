import Foundation

enum APIClient {
    // replace with the deployed server URL once it's hosted.
    static let baseURL = URL(string: "http://localhost:3001")!

    static func get<Response: Decodable>(
        _ path: String,
        queryItems: [URLQueryItem] = [],
        token: String? = nil
    ) async throws -> Response {
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        var request = URLRequest(url: components.url!)
        addAuth(token, to: &request)
        return try await send(request)
    }

    static func post<Body: Encodable, Response: Decodable>(
        _ path: String,
        body: Body,
        token: String? = nil
    ) async throws -> Response {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        addAuth(token, to: &request)
        return try await send(request)
    }

    private static func addAuth(_ token: String?, to request: inout URLRequest) {
        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }

    private static func send<Response: Decodable>(_ request: URLRequest) async throws -> Response {
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "unknown error"
            throw NSError(
                domain: "APIClient",
                code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: message]
            )
        }
        return try JSONDecoder().decode(Response.self, from: data)
    }
}

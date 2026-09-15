import Foundation

enum ScoreService {
    private struct SubmitScoreRequest: Encodable {
        let score: Int
    }

    private struct SubmitScoreResponse: Decodable {
        let id: String
    }

    private struct ScoreDTO: Decodable {
        let id: String
        let name: String
        let score: Int
        let timestamp: String?
    }

    static func submitScore(score: Int, token: String) async throws {
        let _: SubmitScoreResponse = try await APIClient.post(
            "scores",
            body: SubmitScoreRequest(score: score),
            token: token
        )
    }

    static func fetchTopScores(limit: Int = 10) async throws -> [Score] {
        let dtos: [ScoreDTO] = try await APIClient.get(
            "scores/top",
            queryItems: [URLQueryItem(name: "limit", value: String(limit))]
        )
        let formatter = ISO8601DateFormatter()
        return dtos.map { dto in
            Score(
                id: dto.id,
                name: dto.name,
                score: dto.score,
                timestamp: dto.timestamp.flatMap(formatter.date(from:)) ?? Date()
            )
        }
    }
}

import Foundation
import FirebaseFirestore

/// Reads/writes the open `scores` collection. No Firebase Auth is used —
/// this relies on permissive Firestore security rules, which is an
/// intentional scope decision for this assignment, not a production practice.
enum ScoreService {
    private static let collectionName = "scores"

    static func submitScore(name: String, score: Int) async throws {
        let db = Firestore.firestore()
        try await db.collection(collectionName).addDocument(data: [
            "name": name,
            "score": score,
            "timestamp": Timestamp(date: Date())
        ])
    }

    static func fetchTopScores(limit: Int = 10) async throws -> [Score] {
        let db = Firestore.firestore()
        let snapshot = try await db.collection(collectionName)
            .order(by: "score", descending: true)
            .limit(to: limit)
            .getDocuments()

        return snapshot.documents.map { document in
            let data = document.data()
            return Score(
                id: document.documentID,
                name: data["name"] as? String ?? "???",
                score: data["score"] as? Int ?? 0,
                timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
            )
        }
    }
}

import SwiftUI

struct LeaderboardView: View {
    let onClose: () -> Void

    @State private var scores: [Score] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                } else if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.secondary)
                } else if scores.isEmpty {
                    Text("No scores yet")
                        .foregroundStyle(.secondary)
                } else {
                    List {
                        ForEach(Array(scores.enumerated()), id: \.element.id) { index, entry in
                            HStack {
                                Text("\(index + 1).")
                                    .frame(width: 28, alignment: .leading)
                                    .foregroundStyle(.secondary)
                                Text(entry.name)
                                Spacer()
                                Text("\(entry.score)")
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Top 10")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Close", action: onClose)
                }
            }
            .task {
                await load()
            }
        }
    }

    private func load() async {
        isLoading = true
        errorMessage = nil
        do {
            scores = try await ScoreService.fetchTopScores(limit: 10)
        } catch {
            errorMessage = "Couldn't load leaderboard."
        }
        isLoading = false
    }
}

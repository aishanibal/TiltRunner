import SwiftUI

struct GameOverView: View {
    let score: Int
    let onPlayAgain: () -> Void
    let onShowLeaderboard: () -> Void
    let onExitToMenu: () -> Void

    @State private var isSubmitting = false
    @State private var didSubmit = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            Text("Game Over")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("Score: \(score)")
                .font(.title2)
                .foregroundStyle(.white.opacity(0.85))

            if isSubmitting {
                ProgressView()
            } else if didSubmit {
                Label("Score submitted", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            } else if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                Button("Retry Submit", action: submit)
                    .buttonStyle(.bordered)
                    .tint(.white)
            }

            HStack(spacing: 16) {
                Button("Play Again", action: onPlayAgain)
                    .buttonStyle(.bordered)
                Button("Leaderboard", action: onShowLeaderboard)
                    .buttonStyle(.bordered)
                Button("Menu", action: onExitToMenu)
                    .buttonStyle(.bordered)
            }
            .tint(.white)
        }
        .padding(32)
        .background(.black.opacity(0.75), in: RoundedRectangle(cornerRadius: 20))
        .padding()
        .task {
            submit()
        }
    }

    private func submit() {
        guard let token = AuthManager.shared.token else { return }
        isSubmitting = true
        errorMessage = nil
        Task {
            do {
                try await ScoreService.submitScore(score: score, token: token)
                isSubmitting = false
                didSubmit = true
            } catch {
                isSubmitting = false
                errorMessage = "Couldn't submit score. Try again."
            }
        }
    }
}

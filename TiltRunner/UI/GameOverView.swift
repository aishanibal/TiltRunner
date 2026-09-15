import SwiftUI

struct GameOverView: View {
    let score: Int
    let onPlayAgain: () -> Void
    let onShowLeaderboard: () -> Void
    let onExitToMenu: () -> Void

    @State private var name: String = ""
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

            if !didSubmit {
                TextField("Enter your name", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .frame(maxWidth: 240)

                Button {
                    submit()
                } label: {
                    if isSubmitting {
                        ProgressView()
                    } else {
                        Text("Submit Score")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || isSubmitting)

                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            } else {
                Label("Score submitted", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
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
    }

    private func submit() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        isSubmitting = true
        errorMessage = nil
        Task {
            do {
                try await ScoreService.submitScore(name: trimmed, score: score)
                isSubmitting = false
                didSubmit = true
            } catch {
                isSubmitting = false
                errorMessage = "Couldn't submit score. Try again."
            }
        }
    }
}

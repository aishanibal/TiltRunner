import SwiftUI

struct MainMenuView: View {
    @ObservedObject private var authManager = AuthManager.shared

    @State private var isPlaying = false
    @State private var showLeaderboard = false
    @State private var topScore: Int?

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Text("TiltRunner")
                    .font(.system(size: 44, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)

                if let username = authManager.username {
                    Text("Signed in as \(username)")
                        .foregroundStyle(.white.opacity(0.7))
                }

                if let topScore {
                    Text("Top score: \(topScore)")
                        .foregroundStyle(.white.opacity(0.7))
                }

                Spacer()

                Button {
                    isPlaying = true
                } label: {
                    Text("Start")
                        .font(.title2.bold())
                        .frame(maxWidth: 220)
                }
                .buttonStyle(.borderedProminent)

                Button("Leaderboard") {
                    showLeaderboard = true
                }
                .buttonStyle(.bordered)
                .tint(.white)

                Button("Log Out") {
                    authManager.logOut()
                }
                .buttonStyle(.bordered)
                .tint(.white.opacity(0.6))

                Spacer()
            }
            .padding()
        }
        .fullScreenCover(isPresented: $isPlaying) {
            GamePlayView(onExitToMenu: { isPlaying = false })
        }
        .sheet(isPresented: $showLeaderboard) {
            LeaderboardView(onClose: { showLeaderboard = false })
        }
        .task {
            topScore = try? await ScoreService.fetchTopScores(limit: 1).first?.score
        }
    }
}

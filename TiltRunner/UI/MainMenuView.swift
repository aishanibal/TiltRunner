import SwiftUI

struct MainMenuView: View {
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

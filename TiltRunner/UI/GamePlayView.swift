import SwiftUI

/// Hosts the SceneKit view plus HUD/game-over/leaderboard overlays for one play session.
struct GamePlayView: View {
    let onExitToMenu: () -> Void

    @StateObject private var controller = GameController()
    @State private var showLeaderboard = false

    var body: some View {
        ZStack {
            GameViewRepresentable(controller: controller)
                .ignoresSafeArea()

            HUDView(score: controller.score)

            if controller.isGameOver {
                GameOverView(
                    score: controller.score,
                    onPlayAgain: { controller.start() },
                    onShowLeaderboard: { showLeaderboard = true },
                    onExitToMenu: onExitToMenu
                )
            }
        }
        .statusBarHidden()
        .onAppear { controller.start() }
        .onDisappear { controller.stop() }
        .sheet(isPresented: $showLeaderboard) {
            LeaderboardView(onClose: { showLeaderboard = false })
        }
    }
}

import SwiftUI

/// Hosts the SceneKit view plus HUD/game-over/leaderboard overlays for one play session.
struct GamePlayView: View {
    let onExitToMenu: () -> Void

    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var controller = GameController()
    @State private var showLeaderboard = false

    var body: some View {
        ZStack {
            GameViewRepresentable(controller: controller)
                .ignoresSafeArea()

            HUDView(
                score: controller.score,
                showsPauseButton: !controller.isPaused && !controller.isGameOver,
                onPause: { controller.pause() }
            )

            if controller.isPaused && !controller.isGameOver {
                PauseView(
                    onResume: { controller.resume() },
                    onExitToMenu: onExitToMenu
                )
            }

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
        .onChange(of: scenePhase) { _, phase in
            if phase != .active {
                controller.pause()
            }
        }
        .sheet(isPresented: $showLeaderboard) {
            LeaderboardView(onClose: { showLeaderboard = false })
        }
    }
}

private struct PauseView: View {
    let onResume: () -> Void
    let onExitToMenu: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Paused")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Button("Resume", action: onResume)
                .buttonStyle(.borderedProminent)

            Button("Menu", action: onExitToMenu)
                .buttonStyle(.bordered)
                .tint(.white)
        }
        .padding(32)
        .background(.black.opacity(0.75), in: RoundedRectangle(cornerRadius: 20))
        .padding()
    }
}

import SpriteKit
import Combine

/// Owns the game scene and motion input, publishing score/game-over state for SwiftUI.
final class GameController: NSObject, ObservableObject, GameSceneDelegate {
    @Published var score: Int = 0
    @Published var isGameOver: Bool = false
    @Published var isPaused: Bool = false

    let scene: GameScene

    private let motionManager = MotionManager()
    private var rollCancellable: AnyCancellable?

    override init() {
        let scene = GameScene(size: UIScreen.main.bounds.size)
        scene.scaleMode = .resizeFill
        self.scene = scene
        super.init()

        scene.gameDelegate = self
        rollCancellable = motionManager.$roll.sink { [weak self] roll in
            self?.scene.currentRoll = roll
        }
    }

    func start() {
        isGameOver = false
        isPaused = false
        score = 0
        scene.reset()
        motionManager.start()
    }

    func pause() {
        guard !isGameOver, !isPaused else { return }
        isPaused = true
        scene.pauseGame()
        motionManager.stop()
    }

    func resume() {
        guard isPaused, !isGameOver else { return }
        isPaused = false
        scene.resumeGame()
        motionManager.start()
    }

    func stop() {
        motionManager.stop()
        isPaused = false
    }

    func gameScene(_ scene: GameScene, didUpdateScore score: Int) {
        DispatchQueue.main.async { [weak self] in
            self?.score = score
        }
    }

    func gameSceneDidEnd(_ scene: GameScene) {
        motionManager.stop()
        DispatchQueue.main.async { [weak self] in
            self?.isGameOver = true
        }
    }
}

import SpriteKit

protocol GameSceneDelegate: AnyObject {
    func gameScene(_ scene: GameScene, didUpdateScore score: Int)
    func gameSceneDidEnd(_ scene: GameScene)
}

/// Top-down 2D runner: obstacles fall from the top of the screen, player steers
/// left/right between 3 lanes near the bottom.
final class GameScene: SKScene {
    weak var gameDelegate: GameSceneDelegate?

    /// Tilt roll angle, updated externally every frame from CoreMotion.
    var currentRoll: Double = 0

    private let player = Player()
    private var obstacles: [Obstacle] = []

    private var lastUpdateTime: TimeInterval = 0
    private var scrollSpeed: CGFloat = 220
    private var elapsedTime: TimeInterval = 0
    private var timeSinceLastSpawn: TimeInterval = 0
    private var spawnInterval: TimeInterval = 1.2
    private var score: Int = 0
    private var isGameOver = false

    private let steeringThreshold: Double = 0.2
    private let laneFractions: [CGFloat] = [1.0 / 6, 0.5, 5.0 / 6]

    override func didMove(to view: SKView) {
        backgroundColor = .black
        setUpPlayer()
    }

    func reset() {
        removeAllChildren()
        obstacles.removeAll()
        isGameOver = false
        score = 0
        elapsedTime = 0
        lastUpdateTime = 0
        scrollSpeed = 220
        spawnInterval = 1.2
        timeSinceLastSpawn = 0
        setUpPlayer()
    }

    private func setUpPlayer() {
        player.resetLane()
        player.node.position = CGPoint(x: size.width * laneFractions[1], y: size.height * 0.15)
        addChild(player.node)
    }

    override func update(_ currentTime: TimeInterval) {
        guard !isGameOver else { return }
        guard lastUpdateTime != 0 else {
            lastUpdateTime = currentTime
            return
        }
        let dt = min(currentTime - lastUpdateTime, 1.0 / 30.0)
        lastUpdateTime = currentTime

        elapsedTime += dt
        scrollSpeed = 220 + CGFloat(elapsedTime) * 4
        spawnInterval = max(0.45, 1.2 - elapsedTime * 0.01)

        updateSteering()
        updateObstacles(dt: dt)

        timeSinceLastSpawn += dt
        if timeSinceLastSpawn > spawnInterval {
            timeSinceLastSpawn = 0
            spawnObstacle()
        }

        score += Int(scrollSpeed * CGFloat(dt) * 0.5)
        gameDelegate?.gameScene(self, didUpdateScore: score)

        checkCollisions()
    }

    private func updateSteering() {
        let targetLane: Int
        if currentRoll < -steeringThreshold {
            targetLane = 0
        } else if currentRoll > steeringThreshold {
            targetLane = 2
        } else {
            targetLane = 1
        }
        player.setLane(targetLane, targetX: size.width * laneFractions[targetLane])
    }

    private func updateObstacles(dt: TimeInterval) {
        for obstacle in obstacles {
            obstacle.node.position.y -= scrollSpeed * CGFloat(dt)
        }
        obstacles.removeAll { obstacle in
            guard obstacle.node.position.y < -obstacle.node.frame.height else { return false }
            obstacle.node.removeFromParent()
            return true
        }
    }

    private func spawnObstacle() {
        let lane = Int.random(in: 0..<laneFractions.count)
        let obstacle = Obstacle(lane: lane)
        obstacle.node.position = CGPoint(
            x: size.width * laneFractions[lane],
            y: size.height + obstacle.node.size.height
        )
        addChild(obstacle.node)
        obstacles.append(obstacle)
    }

    private func checkCollisions() {
        for obstacle in obstacles where obstacle.node.frame.intersects(player.node.frame) {
            triggerGameOver()
            return
        }
    }

    private func triggerGameOver() {
        isGameOver = true
        gameDelegate?.gameSceneDidEnd(self)
    }
}

import SpriteKit

/// Player node fixed bottom of the screen. Steers between 3 lanes.
final class Player {
    let node: SKSpriteNode
    private(set) var currentLane: Int = 1

    init() {
        node = SKSpriteNode(color: .systemOrange, size: CGSize(width: 44, height: 44))
    }

    func resetLane() {
        node.removeAllActions()
        currentLane = 1
    }

    func setLane(_ lane: Int, targetX: CGFloat) {
        guard lane != currentLane else { return }
        currentLane = lane
        let move = SKAction.moveTo(x: targetX, duration: 0.15)
        move.timingMode = .easeOut
        node.run(move)
    }
}

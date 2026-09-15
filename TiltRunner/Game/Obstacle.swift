import SpriteKit

/// A single obstacle that moves from top to bottom of screen
final class Obstacle {
    let node: SKSpriteNode
    let lane: Int

    init(lane: Int) {
        self.lane = lane
        node = SKSpriteNode(color: .systemRed, size: CGSize(width: 50, height: 50))
    }
}

import SwiftUI
import SpriteKit

struct GameViewRepresentable: UIViewRepresentable {
    let controller: GameController

    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        view.ignoresSiblingOrder = true
        view.showsFPS = false
        view.showsNodeCount = false
        view.presentScene(controller.scene)
        return view
    }

    func updateUIView(_ uiView: SKView, context: Context) {}
}

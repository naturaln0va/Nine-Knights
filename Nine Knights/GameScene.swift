
import SpriteKit

final class GameScene: SKScene {
    
    override init() {
        super.init(size: .zero)
        
        scaleMode = .resizeFill
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        setUpScene(in: view)
    }
    
    private func setUpScene(in view: SKView) {
        backgroundColor = .magenta
    }
    
}

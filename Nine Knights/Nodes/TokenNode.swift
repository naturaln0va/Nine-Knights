
import SpriteKit

final class TokenNode: SKSpriteNode {
    
    static let tokenNodeName = "token"
    
    init(type: GameModel.Player) {
        super.init(
            texture: nil,
            color: type == .knight ? .magenta : .green,
            size: CGSize(width: 28, height: 28)
        )
        
        name = TokenNode.tokenNodeName
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


import SpriteKit

final class TokenNode: SKSpriteNode {
    
    static let tokenNodeName = "token"

    enum TokenType {
        case player
        case opponent
    }
    
    init(type: TokenType) {
        super.init(
            texture: nil,
            color: type == .player ? .magenta : .green,
            size: CGSize(width: 28, height: 28)
        )
        
        name = TokenNode.tokenNodeName
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

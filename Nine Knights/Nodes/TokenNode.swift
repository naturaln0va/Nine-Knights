
import SpriteKit

final class TokenNode: SKSpriteNode {
    
    static let tokenNodeName = "token"
    
    private let rotateActionKey = "rotate"
    
    var isIndicated: Bool = false {
        didSet {
            if isIndicated {
                run(SKAction.repeatForever(SKAction.rotate(byAngle: 1, duration: 0.5)), withKey: rotateActionKey)
            }
            else {
                removeAction(forKey: rotateActionKey)
                run(SKAction.rotate(toAngle: 0, duration: 0.15))
            }
        }
    }
    
    let type: GameModel.Player
    
    init(type: GameModel.Player) {
        self.type = type
        
        let textureName = "\(type.rawValue)-token"
        let texture = SKTexture(imageNamed: textureName)
        
        super.init(
            texture: texture,
            color: .clear,
            size: texture.size()
        )
        
        name = TokenNode.tokenNodeName
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func remove() {
        run(SKAction.sequence([SKAction.scale(to: 0, duration: 0.15), SKAction.removeFromParent()]))
    }
    
}

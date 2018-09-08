
import SpriteKit

class ButtonNode: TouchNode {
    
    private let backgroundNode: BackgroundNode
    private let labelNode: SKLabelNode
    
    private let backgroundColor = UIColor(white: 0, alpha: 0.25)
    private let selectedBackgroundColor = UIColor(white: 0, alpha: 0.6)
    
    init(_ text: String, size: CGSize, actionBlock: ActionBlock?) {
        backgroundNode = BackgroundNode(kind: .recessed, size: size)
        backgroundNode.position = CGPoint(
            x: size.width / 2,
            y: size.height / 2
        )
        
        let buttonFont = UIFont.systemFont(ofSize: 24, weight: .semibold)
        
        labelNode = SKLabelNode(fontNamed: buttonFont.fontName)
        labelNode.fontSize = buttonFont.pointSize
        labelNode.fontColor = .white
        labelNode.text = text
        labelNode.position = CGPoint(
            x: size.width / 2,
            y: size.height / 2 - labelNode.frame.height / 2
        )
        
        let shadowNode = SKLabelNode(fontNamed: buttonFont.fontName)
        shadowNode.fontSize = buttonFont.pointSize
        shadowNode.fontColor = .black
        shadowNode.text = text
        shadowNode.alpha = 0.5
        shadowNode.position = CGPoint(
            x: labelNode.position.x + 2,
            y: labelNode.position.y - 2
        )
        
        super.init()
        
        addChild(backgroundNode)
        addChild(shadowNode)
        addChild(labelNode)
        
        self.actionBlock = actionBlock
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard isEnabled else {
            return
        }
        
        labelNode.run(SKAction.fadeAlpha(to: 0.8, duration: 0.2))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard isEnabled else {
            return
        }
        
        labelNode.run(SKAction.fadeAlpha(to: 1, duration: 0.2))
    }
    
}

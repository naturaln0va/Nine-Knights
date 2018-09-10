
import SpriteKit

final class InformationNode: TouchNode {
    
    private let backgroundNode: BackgroundNode
    private let labelNode: SKLabelNode
    
    var text: String? {
        get {
            return labelNode.text
        }
        set {
            labelNode.text = newValue
        }
    }

    init(_ text: String, size: CGSize, actionBlock: ActionBlock? = nil) {
        backgroundNode = BackgroundNode(kind: .pill, size: size)
        backgroundNode.position = CGPoint(
            x: size.width / 2,
            y: size.height / 2
        )
        
        let font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        labelNode = SKLabelNode(fontNamed: font.fontName)
        labelNode.fontSize = font.pointSize
        labelNode.fontColor = .black
        labelNode.text = text
        labelNode.position = CGPoint(
            x: size.width / 2,
            y: size.height / 2 - labelNode.frame.height / 2 + 2
        )
        
        super.init()
        
        addChild(backgroundNode)
        addChild(labelNode)
        
        self.actionBlock = actionBlock
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

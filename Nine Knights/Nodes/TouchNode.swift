
import SpriteKit

class TouchNode: SKNode {
    
    typealias ActionBlock = (() -> Void)
    
    var actionBlock: ActionBlock?
    
    var isEnabled: Bool = true {
        didSet {
            alpha = isEnabled ? 1 : 0.5
        }
    }
    
    override var isUserInteractionEnabled: Bool {
        get {
            return true
        }
        set {
            // intentionally blank
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let block = actionBlock, isEnabled {
            block()
        }
    }
    
}

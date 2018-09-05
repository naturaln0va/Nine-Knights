
import SpriteKit

final class GameScene: SKScene {
    
    // MARK: - Enums
    
    private enum NodeLayer: CGFloat {
        case board
        case tokens
    }
    
    // MARK: - Properties
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    private var viewWidth: CGFloat {
        return view?.frame.size.width ?? 0
    }
    
    private var viewHeight: CGFloat {
        return view?.frame.size.height ?? 0
    }
    
    // MARK: - Init
    
    override init() {
        super.init(size: .zero)
        
        scaleMode = .resizeFill
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        feedbackGenerator.prepare()
        setUpScene(in: view)
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        removeAllChildren()
        setUpScene(in: view)
    }
    
    // MARK: - Setup
    
    private func setUpScene(in view: SKView?) {
        guard viewWidth > 0 else {
            return
        }
        
        backgroundColor = .black

        let padding: CGFloat = 24
        let boardSide = min(viewWidth, viewHeight) - (padding * 2)
        let boardNode = BoardNode(size: CGSize(width: boardSide, height: boardSide))
        
        boardNode.zPosition = NodeLayer.board.rawValue
        boardNode.position = CGPoint(
            x: viewWidth / 2,
            y: viewHeight / 2
        )
        
        addChild(boardNode)
    }
    
    // MARK: - Touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            handleTouch(touch)
        }
    }
    
    private func handleTouch(_ touch: UITouch) {
        let location = touch.location(in: self)
        let node = atPoint(location)
        
        guard node.name == BoardNode.boardPointNodeName else {
            return
        }
        
        feedbackGenerator.impactOccurred()
        feedbackGenerator.prepare()
        
        spawnToken(at: location)
    }
    
    // MARK: - Spawning
    
    private func spawnToken(at point: CGPoint) {
        
    }

}

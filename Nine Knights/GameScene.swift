
import SpriteKit

final class GameScene: SKScene {
    
    // MARK: - Enums
    
    private enum NodeLayer: CGFloat {
        case board = 100
        case token = 101
    }
    
    // MARK: - Properties
    
    private var isPlayerTurn = true
    private var tokenNeighbors = [SKNode]()
    
    private var boardNode: BoardNode!
    private var selectedTokenNode: TokenNode?

    private let model = GameModel()
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
        boardNode = BoardNode(sideLength: min(viewWidth, viewHeight) - (padding * 2))
        
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
        
        switch node.name {
        case BoardNode.boardPointNodeName:
            if let token = selectedTokenNode {
                if tokenNeighbors.contains(node) {
                    token.run(SKAction.move(to: node.position, duration: 0.175))
                    
                    isPlayerTurn = !isPlayerTurn
                }
                
                deselectCurrentToken()
            }
            else {
                feedbackGenerator.impactOccurred()
                feedbackGenerator.prepare()
                
                spawnToken(at: node.position)
                
                isPlayerTurn = !isPlayerTurn
            }
            
        case TokenNode.tokenNodeName:
            deselectCurrentToken()
            
            guard let token = node as? TokenNode else {
                return
            }
            
            selectedTokenNode = token
            
            guard let boardPointNode = nodes(at: location).first(where: { $0.name == BoardNode.boardPointNodeName }) else {
                return
            }
            
            guard let coord = boardNode.gridCoordinate(for: boardPointNode) else {
                return
            }
            
            tokenNeighbors = model.neighbors(at: coord).compactMap { coord in
                return self.boardNode.boardPointNode(at: coord)
            }
            
            for neighborNode in tokenNeighbors {
                neighborNode.run(SKAction.scale(to: 1.25, duration: 0.15))
            }
            
        default:
            deselectCurrentToken()
        }
    }
    
    // MARK: - Spawning
    
    private func spawnToken(at point: CGPoint) {
        let tokenNode = TokenNode(type: isPlayerTurn ? .player : .opponent)
        
        tokenNode.zPosition = NodeLayer.token.rawValue
        tokenNode.position = point
        
        boardNode.addChild(tokenNode)
    }
    
    // MARK: - Helpers
    
    private func deselectCurrentToken() {
        guard !tokenNeighbors.isEmpty else {
            return
        }
        
        selectedTokenNode = nil
        
        tokenNeighbors.forEach { node in
            node.run(SKAction.scale(to: 1, duration: 0.15))
        }
        
        tokenNeighbors.removeAll()
    }

}

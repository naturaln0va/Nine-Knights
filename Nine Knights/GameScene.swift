
import SpriteKit

final class GameScene: SKScene {
    
    // MARK: - Enums
    
    private enum NodeLayer: CGFloat {
        case board = 100
        case token = 101
        case ui = 1000
    }
    
    // MARK: - Properties
    
    private var boardNode: BoardNode!
    private var messageNode: SKLabelNode!
    private var selectedTokenNode: TokenNode?
    
    private var selectedTokenNeighbors = [SKNode]()

    private var model = GameModel()
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    // MARK: Computed
    
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
        
        messageNode = SKLabelNode(fontNamed: "Chalkduster")
        messageNode.zPosition = NodeLayer.ui.rawValue
        messageNode.text = model.messageToDisplay
        messageNode.position = CGPoint(
            x: viewWidth / 2,
            y: 125
        )
        messageNode.fontColor = .white
        messageNode.fontSize = 20
        
        addChild(messageNode)
    }
    
    // MARK: - Touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            handleTouch(touch)
        }
    }
    
    private func handleTouch(_ touch: UITouch) {
        let location = touch.location(in: self)
        
        switch model.state {
        case .placement:
            handlePlacement(at: location)
            
        case .movement:
            handleMovement(at: location)
        }
    }
    
    // MARK: - Spawning
    
    private func spawnToken(at point: CGPoint) {
        let tokenNode = TokenNode(type: model.isKnightTurn ? .knight : .troll)
        
        tokenNode.zPosition = NodeLayer.token.rawValue
        tokenNode.position = point
        
        boardNode.addChild(tokenNode)
    }
    
    // MARK: - Helpers
    
    private func generateFeedback() {
        feedbackGenerator.impactOccurred()
        feedbackGenerator.prepare()
    }
    
    private func handlePlacement(at location: CGPoint) {
        let node = atPoint(location)
        
        guard node.name == BoardNode.boardPointNodeName else {
            return
        }
        
        guard let coord = boardNode.gridCoordinate(for: node) else {
            return
        }
        
        generateFeedback()
        
        spawnToken(at: node.position)
        
        model.placeToken(at: coord)
        updateDisplayForStateChange()
    }
    
    private func handleMovement(at location: CGPoint) {
//        let node = atPoint(location)
//
//        switch node.name {
//        case BoardNode.boardPointNodeName:
//            if let token = selectedTokenNode {
//                if selectedTokenNeighbors.contains(node) {
//                    token.run(SKAction.move(to: node.position, duration: 0.175))
//                }
//
//                deselectCurrentToken()
//            }
//            else {
//                feedbackGenerator.impactOccurred()
//                feedbackGenerator.prepare()
//
//                spawnToken(at: node.position)
//            }
//
//        case TokenNode.tokenNodeName:
//            deselectCurrentToken()
//
//            guard let token = node as? TokenNode else {
//                return
//            }
//
//            selectedTokenNode = token
//
//            guard let boardPointNode = nodes(at: location).first(where: { $0.name == BoardNode.boardPointNodeName }) else {
//                return
//            }
//
//            guard let coord = boardNode.gridCoordinate(for: boardPointNode) else {
//                return
//            }
//
//            selectedTokenNeighbors = model.neighbors(at: coord).compactMap { coord in
//                return self.boardNode.boardPointNode(at: coord)
//            }
//
//            for neighborNode in selectedTokenNeighbors {
//                neighborNode.run(SKAction.scale(to: 1.25, duration: 0.15))
//            }
//
//        default:
//            deselectCurrentToken()
//        }
    }
    
    private func deselectCurrentToken() {
        guard !selectedTokenNeighbors.isEmpty else {
            return
        }
        
        selectedTokenNode = nil
        
        selectedTokenNeighbors.forEach { node in
            node.run(SKAction.scale(to: 1, duration: 0.15))
        }
        
        selectedTokenNeighbors.removeAll()
    }
    
    private func updateDisplayForStateChange() {
        messageNode.text = model.messageToDisplay
    }

}

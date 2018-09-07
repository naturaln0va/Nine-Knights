
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
    
    private var removableNodes = [TokenNode]()
    private var selectedTokenNeighbors = [SKNode]()

    private var model = GameModel()
    private let successGenerator = UINotificationFeedbackGenerator()
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
        
        successGenerator.prepare()
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
        guard model.winner == nil else {
            return
        }
        
        let location = touch.location(in: self)
        
        if model.isCapturingPiece {
            handleRemoval(at: location)
            return
        }
        
        switch model.state {
        case .placement:
            handlePlacement(at: location)
            
        case .movement:
            handleMovement(at: location)
        }
    }
    
    // MARK: - Spawning
    
    private func spawnToken(at point: CGPoint) {
        let tokenNode = TokenNode(type: model.currentPlayer)
        
        tokenNode.zPosition = NodeLayer.token.rawValue
        tokenNode.position = point
        
        boardNode.addChild(tokenNode)
    }
    
    // MARK: - Helpers
    
    private func handlePlacement(at location: CGPoint) {
        let node = atPoint(location)
        
        guard node.name == BoardNode.boardPointNodeName else {
            return
        }
        
        guard let coord = boardNode.gridCoordinate(for: node) else {
            return
        }
        
        spawnToken(at: node.position)
        model.placeToken(at: coord)
        
        processGameUpdate()
    }
    
    private func handleMovement(at location: CGPoint) {
        let node = atPoint(location)
        
        if let selected = selectedTokenNode {
            if selectedTokenNeighbors.contains(node) {
                let selectedSceneLocation = convert(selected.position, from: boardNode)
                
                guard let fromCoord = gridCoordinate(at: selectedSceneLocation), let toCoord = boardNode.gridCoordinate(for: node) else {
                    return
                }
                
                model.move(from: fromCoord, to: toCoord)
                processGameUpdate()

                selected.run(SKAction.move(to: node.position, duration: 0.175))
            }
            
            deselectCurrentToken()
        }
        else {
            guard let token = node as? TokenNode, token.type == model.currentPlayer else {
                return
            }

            selectedTokenNode = token
            
            guard let coord = gridCoordinate(at: location) else {
                return
            }
            
            selectedTokenNeighbors = model.neighbors(at: coord).compactMap { coord in
                return self.boardNode.node(at: coord, named: BoardNode.boardPointNodeName)
            }

            for neighborNode in selectedTokenNeighbors {
                neighborNode.run(SKAction.scale(to: 1.25, duration: 0.15))
            }
        }
    }
    
    private func handleRemoval(at location: CGPoint) {
        let node = atPoint(location)
        
        guard let tokenNode = node as? TokenNode, tokenNode.type == model.currentOpponent else {
            return
        }
        
        guard let coord = gridCoordinate(at: location) else {
            return
        }
        
        guard model.removeToken(at: coord) else {
            return
        }
        
        tokenNode.remove()
        removableNodes.forEach { node in
            node.isIndicated = false
        }
        
        processGameUpdate()
    }
    
    private func gridCoordinate(at location: CGPoint) -> GameModel.GridCoordinate? {
        guard let boardPointNode = nodes(at: location).first(where: { $0.name == BoardNode.boardPointNodeName }) else {
            return nil
        }
        
        return boardNode.gridCoordinate(for: boardPointNode)
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
    
    private func processGameUpdate() {
        messageNode.text = model.messageToDisplay
        
        if model.isCapturingPiece {
            successGenerator.notificationOccurred(.success)
            successGenerator.prepare()
            
            let tokens = model.removableTokens(for: model.currentOpponent)
            
            let nodes = tokens.compactMap { token in
                boardNode.node(at: token.coord, named: TokenNode.tokenNodeName) as? TokenNode
            }
            
            removableNodes = nodes
            
            nodes.forEach { node in
                node.isIndicated = true
            }
        }
        else {
            feedbackGenerator.impactOccurred()
            feedbackGenerator.prepare()
        }
    }

}

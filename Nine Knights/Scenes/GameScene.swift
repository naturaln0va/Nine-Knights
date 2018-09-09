
import SpriteKit

final class GameScene: SKScene {
    
    // MARK: - Enums
    
    private enum NodeLayer: CGFloat {
        case board = 100
        case token = 101
        case ui = 1000
    }
    
    // MARK: - Properties
    
    private var model: GameModel
    
    private var boardNode: BoardNode!
    private var messageNode: SKLabelNode!
    private var selectedTokenNode: TokenNode?
    
    private var highlightedTokens = [SKNode]()
    private var removableNodes = [TokenNode]()
    
    private var isSendingTurn = false

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
    
    init(model: GameModel) {
        self.model = model
        
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
        
        let sceneMargin: CGFloat = 40
        let safeAreaTopInset = view?.window?.safeAreaInsets.top ?? 0
        let safeAreaBottomInset = view?.window?.safeAreaInsets.bottom ?? 0

        let padding: CGFloat = 24
        boardNode = BoardNode(sideLength: min(viewWidth, viewHeight) - (padding * 2))
        
        boardNode.zPosition = NodeLayer.board.rawValue
        boardNode.position = CGPoint(
            x: viewWidth / 2,
            y: viewHeight / 2
        )
        boardNode.alpha = GameCenterHelper.helper.canTakeTurnForCurrentMatch ? 1 : 0.35
        
        addChild(boardNode)
        
        messageNode = SKLabelNode(fontNamed: "Chalkduster")
        messageNode.zPosition = NodeLayer.ui.rawValue
        messageNode.text = model.messageToDisplay
        messageNode.position = CGPoint(
            x: viewWidth / 2,
            y: safeAreaBottomInset + sceneMargin
        )
        messageNode.fontColor = .white
        messageNode.fontSize = 20
        
        addChild(messageNode)
        
        let buttonSize = CGSize(width: 250, height: 50)
        let menuButton = ButtonNode("Return to Menu", size: buttonSize) {
            self.returnToMenu()
        }
        menuButton.position = CGPoint(
            x: (viewWidth - buttonSize.width) / 2,
            y: viewHeight - safeAreaTopInset - (sceneMargin * 2)
        )
        
        addChild(menuButton)
        
        loadTokens()
    }
    
    // MARK: - Touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            handleTouch(touch)
        }
    }
    
    private func handleTouch(_ touch: UITouch) {
        guard !isSendingTurn && GameCenterHelper.helper.canTakeTurnForCurrentMatch else {
            return
        }
        
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
    
    private func loadTokens() {
        for token in model.tokens {
            guard let boardPointNode = boardNode.node(at: token.coord, named: BoardNode.boardPointNodeName) else {
                return
            }
            
            spawnToken(at: boardPointNode.position, for: token.player)
        }
    }
    
    private func spawnToken(at point: CGPoint, for player: GameModel.Player) {
        let tokenNode = TokenNode(type: player)
        
        tokenNode.zPosition = NodeLayer.token.rawValue
        tokenNode.position = point
        
        boardNode.addChild(tokenNode)
    }
    
    // MARK: - Helpers
    
    private func returnToMenu() {
        view?.presentScene(MenuScene(), transition: SKTransition.moveIn(with: .left, duration: 0.3))
    }
    
    private func handlePlacement(at location: CGPoint) {
        let node = atPoint(location)
        
        guard node.name == BoardNode.boardPointNodeName else {
            return
        }
        
        guard let coord = boardNode.gridCoordinate(for: node) else {
            return
        }
        
        spawnToken(at: node.position, for: model.currentPlayer)
        model.placeToken(at: coord)
        
        processGameUpdate()
    }
    
    private func handleMovement(at location: CGPoint) {
        let node = atPoint(location)
        
        if let selected = selectedTokenNode {
            if highlightedTokens.contains(node) {
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
            
            if model.tokenCount(for: model.currentPlayer) == 3 {
                highlightTokens(at: model.emptyCoordinates)
                return
            }
            
            guard let coord = gridCoordinate(at: location) else {
                return
            }
            
            highlightTokens(at: model.neighbors(at: coord))
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
    
    private func highlightTokens(at coords: [GameModel.GridCoordinate]) {
        let tokensFromCoords = coords.compactMap { coord in
            return self.boardNode.node(at: coord, named: BoardNode.boardPointNodeName)
        }

        highlightedTokens = tokensFromCoords
        
        for neighborNode in highlightedTokens {
            neighborNode.run(SKAction.scale(to: 1.25, duration: 0.15))
        }
    }
    
    private func deselectCurrentToken() {
        guard !highlightedTokens.isEmpty else {
            return
        }
        
        selectedTokenNode = nil
        
        highlightedTokens.forEach { node in
            node.run(SKAction.scale(to: 1, duration: 0.15))
        }
        
        highlightedTokens.removeAll()
    }
    
    private func processGameUpdate() {
        messageNode.text = model.messageToDisplay
        
        if model.isCapturingPiece {
            successGenerator.notificationOccurred(.success)
            successGenerator.prepare()
            
            let tokens = model.removableTokens(for: model.currentOpponent)
            
            if tokens.isEmpty {
                model.advance()
                processGameUpdate()
                return
            }
            
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
            
            if model.winner != nil {
                GameCenterHelper.helper.win { error in
                    if let e = error {
                        print("Error winning match: \(e.localizedDescription)")
                        return
                    }
                    
                    self.returnToMenu()
                }
            }
            else {
                GameCenterHelper.helper.endTurn(model) { error in
                    if let e = error {
                        print("Error ending turn: \(e.localizedDescription)")
                        return
                    }
                    
                    self.returnToMenu()
                }
            }
        }
    }

}

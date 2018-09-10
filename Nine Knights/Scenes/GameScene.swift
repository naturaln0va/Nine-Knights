/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SpriteKit

final class GameScene: SKScene {
  
  // MARK: - Enums
  
  private enum NodeLayer: CGFloat {
    case background = 100
    case board = 101
    case token = 102
    case ui = 1000
  }
  
  // MARK: - Properties
  
  private var model: GameModel
  
  private var boardNode: BoardNode!
  private var messageNode: InformationNode!
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
    
    backgroundColor = .background
    
    var runningYOffset: CGFloat = 0
    
    let sceneMargin: CGFloat = 40
    let safeAreaTopInset = view?.window?.safeAreaInsets.top ?? 0
    let safeAreaBottomInset = view?.window?.safeAreaInsets.bottom ?? 0
    
    let padding: CGFloat = 24
    let boardSideLength = min(viewWidth, viewHeight) - (padding * 2)
    boardNode = BoardNode(sideLength: boardSideLength)
    boardNode.zPosition = NodeLayer.board.rawValue
    runningYOffset += safeAreaBottomInset + sceneMargin + (boardSideLength / 2)
    boardNode.position = CGPoint(
      x: viewWidth / 2,
      y: runningYOffset
    )
    
    addChild(boardNode)
    
    if !GameCenterHelper.helper.canTakeTurnForCurrentMatch {
      let coverSize = CGSize(
        width: boardSideLength + 50,
        height: boardSideLength + 50
      )
      let coverNode = SKSpriteNode(color: .background, size: coverSize)
      coverNode.zPosition = NodeLayer.ui.rawValue + 1
      coverNode.position = boardNode.position
      coverNode.alpha = 0.6
      addChild(coverNode)
    }
    
    let groundNode = SKSpriteNode(imageNamed: "ground")
    groundNode.zPosition = NodeLayer.background.rawValue
    runningYOffset += sceneMargin + (boardSideLength / 2) + (groundNode.size.height / 2)
    groundNode.position = CGPoint(
      x: viewWidth / 2,
      y: runningYOffset
    )
    addChild(groundNode)
    
    messageNode = InformationNode(model.messageToDisplay, size: CGSize(width: viewWidth - (sceneMargin * 2), height: 40))
    messageNode.zPosition = NodeLayer.ui.rawValue
    messageNode.position = CGPoint(
      x: sceneMargin,
      y: runningYOffset - (sceneMargin * 1.25)
    )
    
    addChild(messageNode)
    
    let skySize = CGSize(width: viewWidth, height: viewHeight - groundNode.position.y)
    let skyNode = SKSpriteNode(color: .sky, size: skySize)
    skyNode.zPosition = NodeLayer.background.rawValue - 1
    runningYOffset -= skyNode.size.height / 2
    skyNode.position = CGPoint(
      x: viewWidth / 2,
      y: viewHeight - (skySize.height / 2)
    )
    addChild(skyNode)
    
    let buttonSize = CGSize(width: 125, height: 50)
    let menuButton = ButtonNode("Menu", size: buttonSize) {
      self.returnToMenu()
    }
    menuButton.position = CGPoint(
      x: (viewWidth - buttonSize.width) / 2,
      y: viewHeight - safeAreaTopInset - (sceneMargin * 2)
    )
    menuButton.zPosition = NodeLayer.ui.rawValue
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
    view?.presentScene(MenuScene(), transition: SKTransition.push(with: .down, duration: 0.3))
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
    } else {
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
    selectedTokenNode = nil
    
    guard !highlightedTokens.isEmpty else {
      return
    }
    
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
    } else {
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
      } else {
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

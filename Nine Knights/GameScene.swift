
import SpriteKit

final class GameScene: SKScene {
    
    private enum NodeName: String {
        case boardPoint
        case token
    }
    
    private enum NodeLayer: CGFloat {
        case background
        case line
        case point
    }
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    private var viewWidth: CGFloat {
        return view?.frame.size.width ?? 0
    }
    
    private var viewHeight: CGFloat {
        return view?.frame.size.height ?? 0
    }
    
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
        resetScene()
    }
    
    private func resetScene() {
        removeAllChildren()
        setUpScene(in: view)
    }
    
    private func setUpScene(in view: SKView?) {
        guard viewWidth > 0 else {
            return
        }
        
        backgroundColor = .black

        let padding: CGFloat = 24
        
        let boardSide = min(viewWidth, viewHeight) - (padding * 2)
        createBoard(with: CGSize(width: boardSide, height: boardSide))
    }
    
    private func createBoard(with size: CGSize) {
        let innerPadding: CGFloat = 100
        
        for index in 0...2 {
            let containerNode = SKSpriteNode(
                color: .clear,
                size: CGSize(
                    width: size.width - (innerPadding * CGFloat(index)),
                    height: size.height - (innerPadding * CGFloat(index))
                )
            )
            
            containerNode.zPosition = NodeLayer.background.rawValue
            createBoardPoints(on: containerNode, shouldAddCenterLine: index < 2)
            containerNode.position = CGPoint(
                x: viewWidth / 2,
                y: viewHeight / 2
            )
            
            addChild(containerNode)
        }
    }
    
    private func createBoardPoints(on node: SKSpriteNode, shouldAddCenterLine: Bool) {
        let lineWidth: CGFloat = 3
        let centerLineLength: CGFloat = 50
        let halfBoardWidth = node.size.width / 2
        let halfBoardHeight = node.size.height / 2
        let boardPointSize = CGSize(width: 24, height: 24)
        
        let relativeBoardPositions: [CGPoint] = [
            CGPoint(x: -halfBoardWidth, y: halfBoardHeight),
            CGPoint(x: 0, y: halfBoardHeight),
            CGPoint(x: halfBoardWidth, y: halfBoardHeight),
            CGPoint(x: halfBoardWidth, y: 0),
            CGPoint(x: halfBoardWidth, y: -halfBoardHeight),
            CGPoint(x: 0, y: -halfBoardHeight),
            CGPoint(x: -halfBoardWidth, y: -halfBoardHeight),
            CGPoint(x: -halfBoardWidth, y: 0),
        ]

        for (index, position) in relativeBoardPositions.enumerated() {
            let boardPointNode = SKShapeNode(ellipseOf: boardPointSize)
            
            boardPointNode.zPosition = NodeLayer.point.rawValue
            boardPointNode.name = NodeName.boardPoint.rawValue
            boardPointNode.lineWidth = lineWidth
            boardPointNode.position = position
            boardPointNode.fillColor = .black
            boardPointNode.strokeColor = .red
            
            node.addChild(boardPointNode)
            
            if shouldAddCenterLine && (position.x == 0 || position.y == 0) {
                let path = CGMutablePath()
                path.move(to: position)
                
                let nextPosition: CGPoint
                if position.x == 0 {
                    let factor = position.y > 0 ? -centerLineLength : centerLineLength
                    nextPosition = CGPoint(x: 0, y: position.y + factor)
                }
                else {
                    let factor = position.x > 0 ? -centerLineLength : centerLineLength
                    nextPosition = CGPoint(x: position.x + factor, y: 0)
                }
                path.addLine(to: nextPosition)

                let lineNode = SKShapeNode(path: path, centered: true)
                lineNode.position = CGPoint(
                    x: (position.x + nextPosition.x) / 2,
                    y: (position.y + nextPosition.y) / 2
                )
                
                lineNode.zPosition = NodeLayer.line.rawValue
                lineNode.lineWidth = lineWidth
                lineNode.strokeColor = .red
                
                node.addChild(lineNode)
            }
            
            let lineIndex = index < relativeBoardPositions.count - 1 ? index + 1 : 0
            let nextPosition = relativeBoardPositions[lineIndex]
            
            let path = CGMutablePath()
            path.move(to: position)
            path.addLine(to: nextPosition)
            
            let lineNode = SKShapeNode(path: path, centered: true)
            lineNode.position = CGPoint(
                x: (position.x + nextPosition.x) / 2,
                y: (position.y + nextPosition.y) / 2
            )
            
            lineNode.zPosition = NodeLayer.line.rawValue
            lineNode.lineWidth = lineWidth
            lineNode.strokeColor = .red
            
            node.addChild(lineNode)
        }
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
        
        guard node.name == NodeName.boardPoint.rawValue else {
            return
        }
        
        feedbackGenerator.impactOccurred()
        feedbackGenerator.prepare()
        
        node.run(SKAction.sequence([SKAction.scale(to: 1.25, duration: 0.15), SKAction.scale(to: 1, duration: 0.15)]))
    }

}

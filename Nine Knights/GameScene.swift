
import SpriteKit

final class GameScene: SKScene {
    
    private enum NodeNames: String {
        case boardPoint
        case token
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
                color: .darkGray,
                size: CGSize(
                    width: size.width - (innerPadding * CGFloat(index)),
                    height: size.height - (innerPadding * CGFloat(index))
                )
            )
            
            createBoardPoints(on: containerNode)
            containerNode.position = CGPoint(
                x: viewWidth / 2,
                y: viewHeight / 2
            )
            
            addChild(containerNode)
        }
    }
    
    private func createBoardPoints(on node: SKSpriteNode) {
        let boardPointSize = CGSize(width: 20, height: 20)
        let halfBoardWidth = node.size.width / 2
        let halfBoardHeight = node.size.height / 2
        
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

        for position in relativeBoardPositions {
            let boardPointNode = SKSpriteNode(color: .red, size: boardPointSize)
            
            boardPointNode.name = NodeNames.boardPoint.rawValue
            boardPointNode.position = position
            
            node.addChild(boardPointNode)
        }
    }
}

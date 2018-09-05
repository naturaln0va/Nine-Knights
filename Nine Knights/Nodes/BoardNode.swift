
import SpriteKit

final class BoardNode: SKNode {
    
    static let boardPointNodeName = "boardPoint"
    
    private enum NodeLayer: CGFloat {
        case background
        case line
        case point
    }
    
    init(size: CGSize, innerPadding: CGFloat = 100) {
        super.init()
        
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
            
            addChild(containerNode)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            boardPointNode.name = BoardNode.boardPointNodeName
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
    
}

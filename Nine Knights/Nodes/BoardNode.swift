
import SpriteKit

final class BoardNode: SKNode {
    
    static let boardPointNodeName = "boardPoint"
    
    private enum NodeLayer: CGFloat {
        case background = 10
        case line = 20
        case point = 30
    }
    
    private let sideLength: CGFloat
    private let innerPadding: CGFloat
    
    init(sideLength: CGFloat, innerPadding: CGFloat = 100) {
        self.sideLength = sideLength
        self.innerPadding = innerPadding
        
        super.init()
        
        let size = CGSize(width: sideLength, height: sideLength)
        
        for index in 0...2 {
            let containerNode = SKSpriteNode(
                color: .clear,
                size: CGSize(
                    width: size.width - (innerPadding * CGFloat(index)),
                    height: size.height - (innerPadding * CGFloat(index))
                )
            )
            
            containerNode.zPosition = NodeLayer.background.rawValue + CGFloat(index)
            createBoardPoints(on: containerNode, shouldAddCenterLine: index < 2)
            
            addChild(containerNode)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func node(at gridCoordinate: GameModel.GridCoordinate, named nodeName: String) -> SKNode? {
        let layerPadding = innerPadding * CGFloat(gridCoordinate.layer.rawValue)
        let halfLayerSide = (sideLength - layerPadding) / 2
        let halfLayerPadding = layerPadding / 2
        let halfSide = sideLength / 2
        
        let adjustedXCoord = halfLayerPadding + (CGFloat(gridCoordinate.x.rawValue) * halfLayerSide)
        let adjustedYCoord = halfLayerPadding + (CGFloat(gridCoordinate.y.rawValue) * halfLayerSide)
        
        let relativeGridPoint = CGPoint(x: adjustedXCoord - halfSide, y: adjustedYCoord - halfSide)
        
        let node = atPoint(relativeGridPoint)
        return node.name == nodeName ? node : nil
    }
    
    func gridCoordinate(for node: SKNode) -> GameModel.GridCoordinate? {
        guard let parentZPosition = node.parent?.zPosition else {
            return nil
        }
        
        let adjustedParentZPosition = parentZPosition - NodeLayer.background.rawValue
        
        guard let layer = GameModel.GridLayer(rawValue: Int(adjustedParentZPosition)) else {
            return nil
        }
        
        let xGridPosition: GameModel.GridPosition
        if node.position.x == 0 {
            xGridPosition = .mid
        }
        else {
            xGridPosition = node.position.x > 0 ? .max : .min
        }
        
        let yGridPosition: GameModel.GridPosition
        if node.position.y == 0 {
            yGridPosition = .mid
        }
        else {
            yGridPosition = node.position.y > 0 ? .max : .min
        }
        
        return GameModel.GridCoordinate(x: xGridPosition, y: yGridPosition, layer: layer)
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

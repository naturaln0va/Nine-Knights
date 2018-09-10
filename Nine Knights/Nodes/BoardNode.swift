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
    } else {
      xGridPosition = node.position.x > 0 ? .max : .min
    }
    
    let yGridPosition: GameModel.GridPosition
    if node.position.y == 0 {
      yGridPosition = .mid
    } else {
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
    
    let relativeBoardPositions = [
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
      boardPointNode.fillColor = .background
      boardPointNode.strokeColor = .white
      
      node.addChild(boardPointNode)
      
      if shouldAddCenterLine && (position.x == 0 || position.y == 0) {
        let path = CGMutablePath()
        path.move(to: position)
        
        let nextPosition: CGPoint
        if position.x == 0 {
          let factor = position.y > 0 ? -centerLineLength : centerLineLength
          nextPosition = CGPoint(x: 0, y: position.y + factor)
        } else {
          let factor = position.x > 0 ? -centerLineLength : centerLineLength
          nextPosition = CGPoint(x: position.x + factor, y: 0)
        }
        path.addLine(to: nextPosition)
        
        let lineNode = SKShapeNode(path: path, centered: true)
        lineNode.position = CGPoint(
          x: (position.x + nextPosition.x) / 2,
          y: (position.y + nextPosition.y) / 2
        )
        
        lineNode.strokeColor = boardPointNode.strokeColor
        lineNode.zPosition = NodeLayer.line.rawValue
        lineNode.lineWidth = lineWidth
        
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
      
      lineNode.strokeColor = boardPointNode.strokeColor
      lineNode.zPosition = NodeLayer.line.rawValue
      lineNode.lineWidth = lineWidth
      
      node.addChild(lineNode)
    }
  }
  
}

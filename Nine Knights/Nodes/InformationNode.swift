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

final class InformationNode: TouchNode {
  
  private let backgroundNode: BackgroundNode
  private let labelNode: SKLabelNode
  
  var text: String? {
    get {
      return labelNode.text
    }
    set {
      labelNode.text = newValue
    }
  }
  
  init(_ text: String, size: CGSize, actionBlock: ActionBlock? = nil) {
    backgroundNode = BackgroundNode(kind: .pill, size: size)
    backgroundNode.position = CGPoint(
      x: size.width / 2,
      y: size.height / 2
    )
    
    let font = UIFont.systemFont(ofSize: 18, weight: .semibold)
    
    labelNode = SKLabelNode(fontNamed: font.fontName)
    labelNode.fontSize = font.pointSize
    labelNode.fontColor = .black
    labelNode.text = text
    labelNode.position = CGPoint(
      x: size.width / 2,
      y: size.height / 2 - labelNode.frame.height / 2 + 2
    )
    
    super.init()
    
    addChild(backgroundNode)
    addChild(labelNode)
    
    self.actionBlock = actionBlock
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

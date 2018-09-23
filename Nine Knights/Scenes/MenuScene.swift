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

import GameKit
import SpriteKit

final class MenuScene: SKScene {
  
  private let transition = SKTransition.push(with: .up, duration: 0.3)
  private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
  
  private var viewWidth: CGFloat {
    return view?.frame.size.width ?? 0
  }
  
  private var viewHeight: CGFloat {
    return view?.frame.size.height ?? 0
  }
  
  private var localButton: ButtonNode!
  
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
  
  private func setUpScene(in view: SKView?) {
    guard viewWidth > 0 else {
      return
    }
    
    backgroundColor = .sky
    
    var runningYOffset = viewHeight
    
    let sceneMargin: CGFloat = 40
    let buttonWidth: CGFloat = viewWidth - (sceneMargin * 2)
    let safeAreaTopInset = view?.window?.safeAreaInsets.top ?? 0
    let buttonSize = CGSize(width: buttonWidth, height: buttonWidth * 3 / 11)
    
    runningYOffset -= safeAreaTopInset + (sceneMargin * 3)
    
    let logoNode = SKSpriteNode(imageNamed: "title-logo")
    logoNode.position = CGPoint(
      x: viewWidth / 2,
      y: runningYOffset
    )
    addChild(logoNode)
    
    let groundNode = SKSpriteNode(imageNamed: "ground")
    let aspectRatio = groundNode.size.width / groundNode.size.height
    let adjustedGroundWidth = view?.bounds.width ?? 0
    groundNode.size = CGSize(
        width: adjustedGroundWidth,
        height: adjustedGroundWidth / aspectRatio
    )
    groundNode.position = CGPoint(
      x: viewWidth / 2,
      y: (groundNode.size.height / 2) - (sceneMargin * 1.375)
    )
    addChild(groundNode)
    
    let sunNode = SKSpriteNode(imageNamed: "sun")
    sunNode.position = CGPoint(
      x: viewWidth - (sceneMargin * 1.3),
      y: viewHeight - safeAreaTopInset - (sceneMargin * 1.25)
    )
    addChild(sunNode)
    
    localButton = ButtonNode("Local Game", size: buttonSize) {
      self.view?.presentScene(GameScene(model: GameModel()), transition: self.transition)
    }
    
    runningYOffset -= sceneMargin + logoNode.size.height
    localButton.position = CGPoint(x: sceneMargin, y: runningYOffset)
    addChild(localButton)
  }
  
}

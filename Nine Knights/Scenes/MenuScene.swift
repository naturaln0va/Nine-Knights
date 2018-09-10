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
  private var onlineButton: ButtonNode!
  private var updateNode: InformationNode!
  
  private var recentMatch: GKTurnBasedMatch?
  
  // MARK: - Init
  
  override init() {
    super.init(size: .zero)
    
    scaleMode = .resizeFill
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(authenticationChanged(_:)),
      name: .authenticationChanged,
      object: nil
    )
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(presentGame(_:)),
      name: .presentGame,
      object: nil
    )
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(receivedNewTurn(_:)),
      name: .receivedNewTurn,
      object: nil
    )
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func didMove(to view: SKView) {
    super.didMove(to: view)
    
    GameCenterHelper.helper.currentMatch = nil
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
    groundNode.position = CGPoint(
      x: viewWidth / 2,
      y: (groundNode.size.height / 2) - sceneMargin
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
    
    onlineButton = ButtonNode("Online Game", size: buttonSize) {
      GameCenterHelper.helper.presentMatchmaker()
    }
    onlineButton.isEnabled = GameCenterHelper.helper.isAuthenticated
    runningYOffset -= sceneMargin + buttonSize.height
    onlineButton.position = CGPoint(x: sceneMargin, y: runningYOffset)
    addChild(onlineButton)
    
    updateNode = InformationNode("Received a new turn!", size: CGSize(width: buttonSize.width, height: 40)) {
      guard let match = self.recentMatch else {
        return
      }
      
      self.loadAndDisplay(match: match)
    }
    updateNode.alpha = 0
    runningYOffset -= sceneMargin + 40
    updateNode.position = CGPoint(x: sceneMargin, y: runningYOffset)
    addChild(updateNode)
  }
  
  // MARK: - Notifications
  
  @objc private func authenticationChanged(_ notification: Notification) {
    onlineButton.isEnabled = notification.object as? Bool ?? false
  }
  
  @objc private func presentGame(_ notification: Notification) {
    guard let match = notification.object as? GKTurnBasedMatch else {
      return
    }
    
    loadAndDisplay(match: match)
  }
  
  @objc private func receivedNewTurn(_ notification: Notification) {
    guard let match = notification.object as? GKTurnBasedMatch else {
      return
    }
    
    recentMatch = match
    
    let flashActions = [
      SKAction.fadeIn(withDuration: 0.15),
      SKAction.wait(forDuration: 2),
      SKAction.fadeOut(withDuration: 0.15)
    ]
    
    updateNode.run(SKAction.sequence(flashActions))
  }
  
  // MARK: - Helpers
  
  private func loadAndDisplay(match: GKTurnBasedMatch) {
    match.loadMatchData { data, error in
      let model: GameModel
      
      if let data = data {
        do {
          model = try JSONDecoder().decode(GameModel.self, from: data)
        } catch {
          model = GameModel()
        }
      } else {
        model = GameModel()
      }
      
      GameCenterHelper.helper.currentMatch = match
      
      self.view?.presentScene(GameScene(model: model), transition: self.transition)
    }
  }
  
}

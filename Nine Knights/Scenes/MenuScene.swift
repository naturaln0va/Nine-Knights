
import SpriteKit

final class MenuScene: SKScene {
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    private var viewWidth: CGFloat {
        return view?.frame.size.width ?? 0
    }
    
    private var viewHeight: CGFloat {
        return view?.frame.size.height ?? 0
    }
    
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
        
        var runningYOffset = viewHeight
        
        let sceneMargin: CGFloat = 40
        let buttonWidth: CGFloat = viewWidth - (sceneMargin * 2)
        let buttonSize = CGSize(width: buttonWidth, height: buttonWidth * 3 / 11)
        
        let localPlayButton = ButtonNode("Local Play", size: buttonSize) {
            self.view?.presentScene(GameScene(), transition: SKTransition.crossFade(withDuration: 0.3))
        }
        runningYOffset -= (sceneMargin * 2) + buttonSize.height
        localPlayButton.position = CGPoint(x: sceneMargin, y: runningYOffset)
        addChild(localPlayButton)
        
        let onlineButton = ButtonNode("Online Play", size: buttonSize) {
            
        }
        onlineButton.isEnabled = false
        runningYOffset -= sceneMargin + buttonSize.height
        onlineButton.position = CGPoint(x: sceneMargin, y: runningYOffset)
        addChild(onlineButton)
    }

}

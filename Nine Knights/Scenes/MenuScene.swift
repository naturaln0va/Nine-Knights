
import GameKit
import SpriteKit

final class MenuScene: SKScene {
    
    private let transition = SKTransition.moveIn(with: .right, duration: 0.3)
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    private var viewWidth: CGFloat {
        return view?.frame.size.width ?? 0
    }
    
    private var viewHeight: CGFloat {
        return view?.frame.size.height ?? 0
    }
    
    private var localButton: ButtonNode!
    private var onlineButton: ButtonNode!
    
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
        
        var runningYOffset = viewHeight
        
        let sceneMargin: CGFloat = 40
        let buttonWidth: CGFloat = viewWidth - (sceneMargin * 2)
        let safeAreaTopInset = view?.window?.safeAreaInsets.top ?? 0
        let buttonSize = CGSize(width: buttonWidth, height: buttonWidth * 3 / 11)
        
        localButton = ButtonNode("Local Game", size: buttonSize) {
            self.view?.presentScene(GameScene(model: GameModel()), transition: self.transition)
        }

        runningYOffset -= safeAreaTopInset + sceneMargin + buttonSize.height
        localButton.position = CGPoint(x: sceneMargin, y: runningYOffset)
        addChild(localButton)
        
        onlineButton = ButtonNode("Online Game", size: buttonSize) {
            GameCenterHelper.helper.presentMatchmaker()
        }
        onlineButton.isEnabled = GameCenterHelper.helper.isAuthenticated
        runningYOffset -= sceneMargin + buttonSize.height
        onlineButton.position = CGPoint(x: sceneMargin, y: runningYOffset)
        addChild(onlineButton)
    }
    
    // MARK: - Notifications
    
    @objc private func authenticationChanged(_ notification: Notification) {
        onlineButton.isEnabled = notification.object as? Bool ?? false
    }
    
    @objc private func presentGame(_ notification: Notification) {
        guard let match = notification.object as? GKTurnBasedMatch else {
            return
        }
        
        match.loadMatchData { data, error in
            let model: GameModel
            
            if let data = data {
                do {
                    model = try JSONDecoder().decode(GameModel.self, from: data)
                }
                catch {
                    model = GameModel()
                }
            }
            else {
                model = GameModel()
            }
            
            self.view?.presentScene(GameScene(model: model), transition: self.transition)
        }
    }

}

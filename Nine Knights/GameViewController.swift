
import UIKit
import SpriteKit

final class GameViewController: UIViewController {
    
    var skView: SKView {
        return view as! SKView
    }
    
    var statusBarStyle: UIStatusBarStyle = .lightContent {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override func loadView() {
        view = SKView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        skView.presentScene(MenuScene())
        setNeedsUpdateOfHomeIndicatorAutoHidden()
        
        GameCenterHelper.helper.viewController = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        statusBarStyle = .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        statusBarStyle = .default
    }
    
}

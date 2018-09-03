
import UIKit
import SpriteKit

final class GameViewController: UIViewController {
    
    var skView: SKView {
        return view as! SKView
    }
    
    override func loadView() {
        view = SKView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        skView.presentScene(GameScene())
    }
    
}


import GameKit

final class GameCenterHelper: NSObject {
    
    static let helper = GameCenterHelper()
    
    var currentMatches = [GKTurnBasedMatch]()
    
    var viewController: UIViewController!
    var currentMatchmakerVC: GKTurnBasedMatchmakerViewController?
    
    override init() {
        super.init()
        
        GKLocalPlayer.local.authenticateHandler = { gcAuthVC, error in
            NotificationCenter.default.post(name: .authenticationChanged, object: GKLocalPlayer.local.isAuthenticated)
            
            if GKLocalPlayer.local.isAuthenticated {
                GKLocalPlayer.local.register(self)
                
                GKTurnBasedMatch.loadMatches { matches, error in
                    guard let matches = matches else {
                        print("Error loading matches: \"\(error?.localizedDescription ?? "unknown")\"")
                        return
                    }
                    
                    print("Loaded \(matches.count) matches.")
                    self.currentMatches = matches
                }
            }
            else if let vc = gcAuthVC {
                self.viewController?.present(vc, animated: true, completion: nil)
            }
        }
    }
    
}

extension GameCenterHelper: GKTurnBasedMatchmakerViewControllerDelegate {
    
    func turnBasedMatchmakerViewControllerWasCancelled(_ viewController: GKTurnBasedMatchmakerViewController) {
        viewController.dismiss(animated: true)
    }

    func turnBasedMatchmakerViewController(_ viewController: GKTurnBasedMatchmakerViewController, didFailWithError error: Error) {
        print("Matchmaker vc did fail with error: \(error.localizedDescription).")

        viewController.dismiss(animated: true)
    }
    
}

extension GameCenterHelper: GKLocalPlayerListener {
    
    func player(_ player: GKPlayer, didAccept invite: GKInvite) {
        print("\(player.displayName): accepted invite from: \(invite.sender.displayName).")
    }
    
    func player(_ player: GKPlayer, matchEnded match: GKTurnBasedMatch) {
        print("\(player.displayName): match ended: \(match.matchID).")
    }
    
    func player(_ player: GKPlayer, wantsToQuitMatch match: GKTurnBasedMatch) {
        print("\(player.displayName): wants to quit match: \(match.matchID).")
    }
    
    func player(_ player: GKPlayer, receivedTurnEventFor match: GKTurnBasedMatch, didBecomeActive: Bool) {
        print("\(player.displayName): received a turn event for match: \(match.matchID).")
        
        if let index = currentMatches.index(of: match) {
            currentMatches[index] = match
        }
        else {
            currentMatches.append(match)
            currentMatchmakerVC?.dismiss(animated: true)
        }
    }

}

extension Notification.Name {
    
    static let authenticationChanged = Notification.Name(rawValue: "authenticationChanged")
    
}

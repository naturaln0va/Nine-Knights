
import GameKit

final class GameCenterHelper: NSObject {
    
    typealias CompletionBlock = (Error?) -> Void
    
    enum GameCenterHelperError: Error {
        case matchNotFound
    }
    
    static let helper = GameCenterHelper()
    
    var currentMatch: GKTurnBasedMatch?
    var viewController: UIViewController?
    var currentMatchmakerVC: GKTurnBasedMatchmakerViewController?
    
    var isAuthenticated: Bool {
        return GKLocalPlayer.local.isAuthenticated
    }
    
    var canTakeTurnForCurrentMatch: Bool {
        guard let match = currentMatch else {
            return true
        }
        
        return match.isLocalPlayersTurn
    }
    
    override init() {
        super.init()
        
        GKLocalPlayer.local.authenticateHandler = { gcAuthVC, error in
            NotificationCenter.default.post(name: .authenticationChanged, object: GKLocalPlayer.local.isAuthenticated)
            
            if GKLocalPlayer.local.isAuthenticated {
                GKLocalPlayer.local.register(self)                
            }
            else if let vc = gcAuthVC {
                self.viewController?.present(vc, animated: true)
            }
        }
    }
    
    func presentMatchmaker() {
        guard GKLocalPlayer.local.isAuthenticated else {
            return
        }
        
        let request = GKMatchRequest()
        
        request.minPlayers = 2
        request.maxPlayers = 2
        request.inviteMessage = "Would you like to play Nine Knights?"
        
        let vc = GKTurnBasedMatchmakerViewController(matchRequest: request)
        vc.turnBasedMatchmakerDelegate = self
        
        currentMatchmakerVC = vc
        viewController?.present(vc, animated: true)
    }
    
    func endTurn(_ model: GameModel, completion: @escaping CompletionBlock) {
        guard let match = currentMatch else {
            completion(GameCenterHelperError.matchNotFound)
            return
        }
        
        do {
            match.message = model.messageToDisplay
            
            match.endTurn(
                withNextParticipants: match.others,
                turnTimeout: GKExchangeTimeoutDefault,
                match: try JSONEncoder().encode(model),
                completionHandler: completion
            )
        }
        catch {
            completion(error)
        }
    }
    
    func win(completion: @escaping CompletionBlock) {
        guard let match = currentMatch else {
            completion(GameCenterHelperError.matchNotFound)
            return
        }
        
        match.currentParticipant?.matchOutcome = .won
        match.others.forEach { other in
            other.matchOutcome = .lost
        }
        
        match.endMatchInTurn(withMatch: Data(), completionHandler: completion)
    }
    
}

extension GameCenterHelper: GKTurnBasedMatchmakerViewControllerDelegate {
    
    func turnBasedMatchmakerViewControllerWasCancelled(_ viewController: GKTurnBasedMatchmakerViewController) {
        viewController.dismiss(animated: true)
    }

    func turnBasedMatchmakerViewController(_ viewController: GKTurnBasedMatchmakerViewController, didFailWithError error: Error) {
        print("Matchmaker vc did fail with error: \(error.localizedDescription).")
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
        
        let activeOthers = match.others.filter { participant in
            return participant.status == .active
        }
        let matchData = match.matchData ?? Data()
        
        if activeOthers.isEmpty {
            match.currentParticipant?.matchOutcome = .won
            match.endMatchInTurn(withMatch: matchData) { error in
                print("\(player.displayName) ended the match in turn with error: \(error?.localizedDescription ?? "none")")
            }
        }
        else {
            match.participantQuitInTurn(with: .lost, nextParticipants: activeOthers, turnTimeout: GKTurnTimeoutDefault, match: matchData) { error in
                print("\(player.displayName) quit in turn with error: \(error?.localizedDescription ?? "none")")
            }
        }
    }
    
    func player(_ player: GKPlayer, receivedTurnEventFor match: GKTurnBasedMatch, didBecomeActive: Bool) {
        print("\(player.displayName): received a turn event for match: \(match.matchID). Did become active: \(didBecomeActive)")

        guard didBecomeActive else {
            return
        }
        
        currentMatch = match
        
        viewController?.dismiss(animated: true) {
            NotificationCenter.default.post(name: .presentGame, object: match)
        }        
    }

}

extension Notification.Name {
    
    static let presentGame = Notification.Name(rawValue: "presentGame")
    static let authenticationChanged = Notification.Name(rawValue: "authenticationChanged")

}

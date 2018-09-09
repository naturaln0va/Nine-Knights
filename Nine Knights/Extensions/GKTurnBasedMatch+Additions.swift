
import GameKit

extension GKTurnBasedMatch {
    
    var isLocalPlayersTurn: Bool {
        return currentParticipant?.player == GKLocalPlayer.local
    }
    
    var others: [GKTurnBasedParticipant] {
        return participants.filter {
            return $0.player != GKLocalPlayer.local
        }
    }
    
}

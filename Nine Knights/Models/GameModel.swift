
import Foundation

struct GameModel {
    
    var turn: Int
    var state: State
    var tokens: [Token]
    var winner: Player?
    var tokensPlaced: Int
    var millTokens: [Token]
    var removedToken: Token?
    var currentMill: [Token]?
    var lastMove: (start: GridCoordinate, end: GridCoordinate)?
    
    var currentPlayer: Player {
        return isKnightTurn ? .knight : .troll
    }
    
    var currentOpponent: Player {
        return isKnightTurn ? .troll : .knight
    }
    
    var messageToDisplay: String {
        let playerName = isKnightTurn ? "Knight" : "Troll"
        
        if isCapturingPiece {
            return "Take an opponent's piece!"
        }
        
        let stateAction: String
        switch state {
        case .placement:
            stateAction = "place"
            
        case .movement:
            if tokenCount(for: .knight) < minPlayerTokenCount {
                return "Troll's win!"
            }
            else if tokenCount(for: .troll) < minPlayerTokenCount {
                return "Knight's win!"
            }
            else {
                stateAction = "move"
            }
        }
        
        return "\(playerName)'s turn to \(stateAction)"
    }
    
    var isCapturingPiece: Bool {
        return currentMill != nil
    }
    
    var emptyCoordinates: [GridCoordinate] {
        let tokenCoords = tokens.map({ $0.coord })
        
        return positions.filter { coord in
            return !tokenCoords.contains(coord)
        }
    }
    
    private(set) var isKnightTurn: Bool
    private let positions: [GridCoordinate]
    
    private let maxTokenCount = 18
    private let minPlayerTokenCount = 3
    
    init(isKnightTurn: Bool = true) {
        self.isKnightTurn = isKnightTurn
        
        turn = 0
        tokensPlaced = 0
        state = .placement
        tokens = [Token]()
        millTokens = [Token]()

        positions = [
            GridCoordinate(x: .min, y: .max, layer: .outer),
            GridCoordinate(x: .mid, y: .max, layer: .outer),
            GridCoordinate(x: .max, y: .max, layer: .outer),
            GridCoordinate(x: .max, y: .mid, layer: .outer),
            GridCoordinate(x: .max, y: .min, layer: .outer),
            GridCoordinate(x: .mid, y: .min, layer: .outer),
            GridCoordinate(x: .min, y: .min, layer: .outer),
            GridCoordinate(x: .min, y: .mid, layer: .outer),
            GridCoordinate(x: .min, y: .max, layer: .middle),
            GridCoordinate(x: .mid, y: .max, layer: .middle),
            GridCoordinate(x: .max, y: .max, layer: .middle),
            GridCoordinate(x: .max, y: .mid, layer: .middle),
            GridCoordinate(x: .max, y: .min, layer: .middle),
            GridCoordinate(x: .mid, y: .min, layer: .middle),
            GridCoordinate(x: .min, y: .min, layer: .middle),
            GridCoordinate(x: .min, y: .mid, layer: .middle),
            GridCoordinate(x: .min, y: .max, layer: .center),
            GridCoordinate(x: .mid, y: .max, layer: .center),
            GridCoordinate(x: .max, y: .max, layer: .center),
            GridCoordinate(x: .max, y: .mid, layer: .center),
            GridCoordinate(x: .max, y: .min, layer: .center),
            GridCoordinate(x: .mid, y: .min, layer: .center),
            GridCoordinate(x: .min, y: .min, layer: .center),
            GridCoordinate(x: .min, y: .mid, layer: .center),
        ]
    }
    
    func neighbors(at coord: GridCoordinate) -> [GridCoordinate] {
        var neighbors = [GridCoordinate]()
        
        switch coord.x {
        case .mid:
            neighbors.append(GridCoordinate(x: .min, y: coord.y, layer: coord.layer))
            neighbors.append(GridCoordinate(x: .max, y: coord.y, layer: coord.layer))
            
        case .min, .max:
            if coord.y == .mid {
                switch coord.layer {
                case .middle:
                    neighbors.append(GridCoordinate(x: coord.x, y: coord.y, layer: .outer))
                    neighbors.append(GridCoordinate(x: coord.x, y: coord.y, layer: .center))
                case .center, .outer:
                    neighbors.append(GridCoordinate(x: coord.x, y: coord.y, layer: .middle))
                }
            }
            else {
                neighbors.append(GridCoordinate(x: .mid, y: coord.y, layer: coord.layer))
            }
        }
        
        switch coord.y {
        case .mid:
            neighbors.append(GridCoordinate(x: coord.x, y: .min, layer: coord.layer))
            neighbors.append(GridCoordinate(x: coord.x, y: .max, layer: coord.layer))

        case .min, .max:
            if coord.x == .mid {
                switch coord.layer {
                case .middle:
                    neighbors.append(GridCoordinate(x: coord.x, y: coord.y, layer: .outer))
                    neighbors.append(GridCoordinate(x: coord.x, y: coord.y, layer: .center))
                case .center, .outer:
                    neighbors.append(GridCoordinate(x: coord.x, y: coord.y, layer: .middle))
                }
            }
            else {
                neighbors.append(GridCoordinate(x: coord.x, y: .mid, layer: coord.layer))
            }
        }
        
        return neighbors
    }
    
    func removableTokens(for player: Player) -> [Token] {
        let playerTokens = tokens.filter { token in
            return token.playerID == player.rawValue
        }
        
        if playerTokens.count == 3 {
            return playerTokens
        }
        
        return playerTokens.filter { token in
            return !millTokens.contains(token)
        }
    }
    
    func mill(containing token: Token) -> [Token]? {
        var coordsToCheck = [token.coord]
        
        var xPositionsToCheck: [GridPosition] = [.min, .mid, .max]
        xPositionsToCheck.remove(at: token.coord.x.rawValue)
        
        guard let firstXPosition = xPositionsToCheck.first, let lastXPosition = xPositionsToCheck.last else {
            return nil
        }
        
        var yPositionsToCheck: [GridPosition] = [.min, .mid, .max]
        yPositionsToCheck.remove(at: token.coord.y.rawValue)
        
        guard let firstYPosition = yPositionsToCheck.first, let lastYPosition = yPositionsToCheck.last else {
            return nil
        }
        
        var layersToCheck: [GridLayer] = [.outer, .middle, .center]
        layersToCheck.remove(at: token.coord.layer.rawValue)
        
        guard let firstLayer = layersToCheck.first, let lastLayer = layersToCheck.last else {
            return nil
        }

        switch token.coord.x {
        case .mid:
            coordsToCheck.append(GridCoordinate(x: token.coord.x, y: token.coord.y, layer: firstLayer))
            coordsToCheck.append(GridCoordinate(x: token.coord.x, y: token.coord.y, layer: lastLayer))
            
        case .min, .max:
            coordsToCheck.append(GridCoordinate(x: token.coord.x, y: firstYPosition, layer: token.coord.layer))
            coordsToCheck.append(GridCoordinate(x: token.coord.x, y: lastYPosition, layer: token.coord.layer))
        }
        
        let validHorizontalMillTokens = tokens.filter {
            return $0.playerID == token.playerID && coordsToCheck.contains($0.coord)
        }
        
        if validHorizontalMillTokens.count == 3 {
            return validHorizontalMillTokens
        }
        
        coordsToCheck = [token.coord]
        
        switch token.coord.y {
        case .mid:
            coordsToCheck.append(GridCoordinate(x: token.coord.x, y: token.coord.y, layer: firstLayer))
            coordsToCheck.append(GridCoordinate(x: token.coord.x, y: token.coord.y, layer: lastLayer))

        case .min, .max:
            coordsToCheck.append(GridCoordinate(x: firstXPosition, y: token.coord.y, layer: token.coord.layer))
            coordsToCheck.append(GridCoordinate(x: lastXPosition, y: token.coord.y, layer: token.coord.layer))
        }

        let validVerticalMillTokens = tokens.filter {
            return $0.playerID == token.playerID && coordsToCheck.contains($0.coord)
        }
        
        if validVerticalMillTokens.count == 3 {
            return validVerticalMillTokens
        }

        return nil
    }
    
    mutating func placeToken(at coord: GridCoordinate) {
        guard state == .placement else {
            return
        }
        
        let playerID = isKnightTurn ? Player.knight.rawValue : Player.troll.rawValue
        
        let newToken = Token(playerID: playerID, coord: coord)
        tokens.append(newToken)
        tokensPlaced += 1
        
        guard let newMill = mill(containing: newToken) else {
            advance()
            return
        }
        
        millTokens.append(contentsOf: newMill)
        currentMill = newMill
    }
    
    mutating func removeToken(at coord: GridCoordinate) -> Bool {
        guard isCapturingPiece else {
            return false
        }
        
        guard let index = tokens.firstIndex(where: { $0.coord == coord }) else {
            return false
        }
        
        let tokenToRemove = tokens[index]
        
        guard tokenCount(for: currentOpponent) == 3 || !millTokens.contains(tokenToRemove) else {
            return false
        }
        
        tokens.remove(at: index)
        advance()
        
        return true
    }
    
    mutating func move(from: GridCoordinate, to: GridCoordinate) {
        guard let index = tokens.firstIndex(where: { $0.coord == from }) else {
            return
        }

        let previousToken = tokens[index]
        let movedToken = Token(playerID: previousToken.playerID, coord: to)
        
        let millToRemove = mill(containing: previousToken) ?? []
        
        if !millToRemove.isEmpty {
            millToRemove.forEach { tokenToRemove in
                guard let index = millTokens.index(of: tokenToRemove) else {
                    return
                }
                
                self.millTokens.remove(at: index)
            }
        }

        tokens[index] = movedToken
        
        if !millToRemove.isEmpty {
            for removedToken in millToRemove where removedToken != previousToken && mill(containing: removedToken) != nil {
                millTokens.append(removedToken)
            }
        }
        
        guard let newMill = mill(containing: movedToken) else {
            advance()
            return
        }
        
        millTokens.append(contentsOf: newMill)
        currentMill = newMill
    }
    
    mutating func advance() {
        if tokensPlaced == maxTokenCount && state == .placement {
            state = .movement
        }
        
        turn += 1
        currentMill = nil

        if state == .movement {
            if tokenCount(for: .knight) == 2 {
                winner = Player.troll
            }
            else if tokenCount(for: .troll) == 2 {
                winner = Player.knight
            }
            else {
                isKnightTurn = !isKnightTurn
            }
        }
        else {
            isKnightTurn = !isKnightTurn
        }
    }
    
    func tokenCount(for player: Player) -> Int {
        return tokens.filter { token in
            return token.playerID == player.rawValue
        }.count
    }
    
}

// MARK: - Types

extension GameModel {
    
    enum Player: String {
        case knight, troll
    }
    
    enum State {
        case placement
        case movement
    }

    enum GridPosition: Int {
        case min, mid, max
    }
    
    enum GridLayer: Int {
        case outer, middle, center
    }
    
    struct GridCoordinate: Equatable {
        let x, y: GridPosition
        let layer: GridLayer
    }
    
    struct Token: Equatable {
        let playerID: String
        let coord: GridCoordinate
    }

}

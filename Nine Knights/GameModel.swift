
import Foundation

struct GameModel {
    
    var turn: Int
    var state: State
    var tokens: [Token]
    var tokensPlaced: Int
    var removedToken: Token?
    var lastMove: (start: GridCoordinate, end: GridCoordinate)?
    
    private(set) var isKnightTurn: Bool
    private let positions: [GridCoordinate]
    
    private let maxTokenCount = 18
    private let minPlayerTokenCount = 3
    
    init(isKnightTurn: Bool = true) {
        self.isKnightTurn = isKnightTurn
        
        turn = 0
        tokensPlaced = 0
        state = .movement
        tokens = [Token]()

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
    
    struct GridCoordinate {
        let x, y: GridPosition
        let layer: GridLayer
    }
    
    struct Token {
        let playerID: String
        let coord: GridCoordinate
    }

}

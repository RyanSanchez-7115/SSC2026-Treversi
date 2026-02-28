import Foundation

/**
 * @class GameState
 * @brief Game state management class, responsible for board, player, legal moves, animation, history, and core logic.
 */
class GameState: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Current board state, key is coordinate, value is piece type
    @Published private(set) var board: [TriangleCoordinate: Piece]
    
    /// Current player
    @Published private(set) var currentPlayer: Player
    
    /// Whether the game is over
    @Published private(set) var isGameOver: Bool = false
    
    /// Set of all current legal moves
    @Published private(set) var legalMoves: Set<TriangleCoordinate> = []
    
    /// Whether animation is in progress
    @Published var isAnimating = false
    
    /// Skip turn message
    @Published var skipMessage: String?
    
    /**
     * @brief Game over info (winner, black/white piece count)
     * @details Setting this will automatically show the game over modal
     */
    @Published var gameOverInfo: (winner: Player?, blackCount: Int, whiteCount: Int)? {
        didSet { showGameOverModal = gameOverInfo != nil }
    }
    
    /// Whether to show the game over modal
    @Published var showGameOverModal = false
    
    // MARK: - Internal State & Configuration
    
    /// Board geometry
    let geometry: BoardGeometry
    
    /// Move history (for undo)
    var moveHistory: [(move: TriangleCoordinate, flipped: [TriangleCoordinate], player: Player)] = []
    
    /// Selected initial layout
    private let selectedLayout: [TriangleCoordinate: Piece]
    
    /// Animation duration
    private let animationDuration: Double = 0.6
    
    /// Reference to animation task
    private var pendingAnimationWorkItem: DispatchWorkItem?
    
    // MARK: - Initialization
    
    /**
     * @brief Initialize game state
     * @param geometry Board geometry
     * @param initialOccupation Initial piece layout (optional)
     */
    init(geometry: BoardGeometry, initialOccupation: [TriangleCoordinate: Piece]? = nil) {
        self.geometry = geometry
        self.selectedLayout = initialOccupation ?? geometry.initialOccupation
        
        var initialBoard: [TriangleCoordinate: Piece] = [:]
        for coord in geometry.allCoordinates {
            initialBoard[coord] = .empty
        }
        for (coord, piece) in selectedLayout {
            if geometry.allCoordinates.contains(coord) {
                initialBoard[coord] = piece
            }
        }
        self.board = initialBoard
        
        self.currentPlayer = .black
        recalculateLegalMoves()
        checkGameOver()
    }
    
    // MARK: - Game Actions
    
    /**
     * @brief Make a move
     * @param coordinate Move coordinate
     * @return Whether the move was successful
     */
    func makeMove(at coordinate: TriangleCoordinate) -> Bool {
        guard legalMoves.contains(coordinate) else { return false }
        
        let flipped = flippedCoordinatesIfPlace(at: coordinate, by: currentPlayer)
        guard !flipped.isEmpty else { return false }
        
        moveHistory.append((move: coordinate, flipped: flipped, player: currentPlayer))
        
        board[coordinate] = Piece.piece(for: currentPlayer)
        for f in flipped {
            board[f] = Piece.piece(for: currentPlayer)
        }
        
        pendingAnimationWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.currentPlayer = self.currentPlayer.opponent
            self.recalculateLegalMoves()
            self.checkGameOver()
            self.isAnimating = false
            self.pendingAnimationWorkItem = nil
        }
        pendingAnimationWorkItem = workItem
        isAnimating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration, execute: workItem)
        return true
    }
    
    /**
     * @brief Undo the last move
     * @return Whether undo was successful
     */
    func undoMove() -> Bool {
        guard let last = moveHistory.popLast() else { return false }
        board[last.move] = .empty
        for f in last.flipped {
            board[f] = Piece.piece(for: last.player.opponent)
        }
        currentPlayer = last.player
        recalculateLegalMoves()
        isGameOver = false
        gameOverInfo = nil
        return true
    }
    
    /**
     * @brief Restart the game, reset board and state
     */
    func restart() {
        var newBoard: [TriangleCoordinate: Piece] = [:]
        for coord in geometry.allCoordinates { newBoard[coord] = .empty }
        for (coord, piece) in selectedLayout { newBoard[coord] = piece }
        board = newBoard
        currentPlayer = .black
        moveHistory.removeAll()
        isGameOver = false
        recalculateLegalMoves()
    }
    
    /**
     * @brief Clear the skip turn message
     */
    func clearSkipMessage() { skipMessage = nil }
    
    // MARK: - Game Logic & Checks
    
    /**
     * @brief Recalculate all legal moves for the current player
     */
    private func recalculateLegalMoves() {
        var moves = Set<TriangleCoordinate>()
        for coord in geometry.allCoordinates where board[coord] == .empty {
            if !flippedCoordinatesIfPlace(at: coord, by: currentPlayer).isEmpty {
                moves.insert(coord)
            }
        }
        legalMoves = moves
    }
    
    /**
     * @brief Check if the game is over, and set related info if so
     */
    private func checkGameOver() {
        guard legalMoves.isEmpty else { return }
        
        let opponent = currentPlayer.opponent
        
        let opponentHasMoves = geometry.allCoordinates.contains {
            board[$0] == .empty && !flippedCoordinatesIfPlace(at: $0, by: opponent).isEmpty
        }
        
        if !opponentHasMoves {
            let counts = countPieces()
            gameOverInfo = (winner: winner(), blackCount: counts.black, whiteCount: counts.white)
            isGameOver = true
        } else {
            skipMessage = "You have no valid moves, turn skipped automatically"
            currentPlayer = opponent
            recalculateLegalMoves()
        }
    }
    
    /**
     * @brief Calculate the coordinates of pieces that can be flipped after a move
     * @param coordinate Move coordinate
     * @param player Current player
     * @return Array of coordinates that can be flipped
     */
    private func flippedCoordinatesIfPlace(at coordinate: TriangleCoordinate, by player: Player) -> [TriangleCoordinate] {
        var flipped: [TriangleCoordinate] = []
        let opponent = player.opponent
        // Six search directions, clockwise
        let directions: [(Int, Int, Bool) -> (Int, Int, Bool)] = [
            { (q, r, isUp) in return (q-1, r, !isUp) }, // Horizontal left
            { (q, r, isUp) in isUp ? (q-1, r, !isUp) : (q, r+1, !isUp) }, // Upper left
            { (q, r, isUp) in isUp ? (q+1, r, !isUp) : (q, r+1, !isUp) }, // Upper right
            { (q, r, isUp) in return (q+1, r, !isUp) }, // Horizontal right
            { (q, r, isUp) in isUp ? (q, r-1, !isUp) : (q+1, r, !isUp) }, // Lower right
            { (q, r, isUp) in isUp ? (q, r-1, !isUp) : (q-1, r, !isUp) }  // Lower left
        ]
        
        for (dirIndex, direction) in directions.enumerated() {
            var toFlip: [TriangleCoordinate] = []
            var currentQ = coordinate.q
            var currentR = coordinate.r
            var currentIsUp = coordinate.isPointingUp
            var stepCount = 0
            let maxSteps = geometry.allCoordinates.count / 4 + 10
            
            while stepCount < maxSteps {
                stepCount += 1
                let (nextQ, nextR, nextIsUp) = direction(currentQ, currentR, currentIsUp)
                let nextCoord = TriangleCoordinate(q: nextQ, r: nextR, isPointingUp: nextIsUp)
                guard geometry.allCoordinates.contains(nextCoord) else { break }
                
                let nextPiece = board[nextCoord] ?? .empty
                
                switch nextPiece {
                case .black, .white:
                    if nextPiece.owner == opponent {
                        toFlip.append(nextCoord)
                        currentQ = nextQ
                        currentR = nextR
                        currentIsUp = nextIsUp
                    } else if nextPiece.owner == player && !toFlip.isEmpty {
                        flipped.append(contentsOf: toFlip)
                        break
                    } else {
                        break
                    }
                case .neutral, .directional:
                    if nextPiece.allowsTraversal(fromSearchDirIndex: dirIndex) {
                        currentQ = nextQ
                        currentR = nextR
                        currentIsUp = nextIsUp
                    } else {
                        break
                    }
                case .empty:
                    break
                }
            }
        }
        return Array(Set(flipped))
    }
    
    // MARK: - Queries & Helpers
    
    /**
     * @brief Count the number of black and white pieces
     * @return (black: black count, white: white count)
     */
    func countPieces() -> (black: Int, white: Int) {
        var black = 0, white = 0
        for piece in board.values {
            switch piece {
            case .black: black += 1
            case .white: white += 1
            default: break
            }
        }
        return (black, white)
    }
    
    /**
     * @brief Get the current winner
     * @return Winner player (nil if draw)
     */
    func winner() -> Player? {
        let counts = countPieces()
        if counts.black > counts.white { return .black }
        if counts.white > counts.black { return .white }
        return nil
    }
    
    /**
     * @brief Preview the pieces that can be flipped after a move
     * @param coordinate Move coordinate
     * @return Array of coordinates that can be flipped
     */
    func previewFlipped(at coordinate: TriangleCoordinate) -> [TriangleCoordinate] {
        flippedCoordinatesIfPlace(at: coordinate, by: currentPlayer)
    }
}

// MARK: - Static Utilities

/**
 * @extension GameState
 * @brief Static utility methods for external use
 */
extension GameState {
    /**
     * @brief Calculate the coordinates of pieces that can be flipped after a move (static method)
     * @param coordinate Move coordinate
     * @param board Current board
     * @param geometry Board geometry
     * @param player Current player
     * @return Array of coordinates that can be flipped
     */
    static func flippedCoordinatesIfPlace(at coordinate: TriangleCoordinate,
                                          board: [TriangleCoordinate: Piece],
                                          geometry: BoardGeometry,
                                          player: Player) -> [TriangleCoordinate] {
        var flipped: [TriangleCoordinate] = []
        let opponent = player.opponent
        
        let directions: [(Int, Int, Bool) -> (Int, Int, Bool)] = [
            { (q, r, isUp) in return (q-1, r, !isUp) },
            { (q, r, isUp) in isUp ? (q-1, r, !isUp) : (q, r+1, !isUp) },
            { (q, r, isUp) in isUp ? (q+1, r, !isUp) : (q, r+1, !isUp) },
            { (q, r, isUp) in return (q+1, r, !isUp) },
            { (q, r, isUp) in isUp ? (q, r-1, !isUp) : (q+1, r, !isUp) },
            { (q, r, isUp) in isUp ? (q, r-1, !isUp) : (q-1, r, !isUp) }
        ]
        
        for (dirIndex, direction) in directions.enumerated() {
            var toFlip: [TriangleCoordinate] = []
            var currentQ = coordinate.q
            var currentR = coordinate.r
            var currentIsUp = coordinate.isPointingUp
            var stepCount = 0
            let maxSteps = geometry.allCoordinates.count / 4 + 10
            
            while stepCount < maxSteps {
                stepCount += 1
                let (nextQ, nextR, nextIsUp) = direction(currentQ, currentR, currentIsUp)
                let nextCoord = TriangleCoordinate(q: nextQ, r: nextR, isPointingUp: nextIsUp)
                guard geometry.allCoordinates.contains(nextCoord) else { break }
                
                let nextPiece = board[nextCoord] ?? .empty
                
                switch nextPiece {
                case .black, .white:
                    if nextPiece.owner == opponent {
                        toFlip.append(nextCoord)
                        currentQ = nextQ
                        currentR = nextR
                        currentIsUp = nextIsUp
                    } else if nextPiece.owner == player && !toFlip.isEmpty {
                        flipped.append(contentsOf: toFlip)
                        break
                    } else {
                        break
                    }
                case .neutral, .directional:
                    if nextPiece.allowsTraversal(fromSearchDirIndex: dirIndex) {
                        currentQ = nextQ
                        currentR = nextR
                        currentIsUp = nextIsUp
                    } else {
                        break
                    }
                case .empty:
                    break
                }
            }
        }
        return Array(Set(flipped))
    }
    
    /**
     * @brief Calculate all legal moves for the specified player (static method)
     * @param player Player
     * @param board Current board
     * @param geometry Board geometry
     * @return Set of legal moves
     */
    static func legalMoves(for player: Player, board: [TriangleCoordinate: Piece], geometry: BoardGeometry) -> Set<TriangleCoordinate> {
        var moves = Set<TriangleCoordinate>()
        for coord in geometry.allCoordinates where board[coord] == .empty {
            if !flippedCoordinatesIfPlace(at: coord, board: board, geometry: geometry, player: player).isEmpty {
                moves.insert(coord)
            }
        }
        return moves
    }
}

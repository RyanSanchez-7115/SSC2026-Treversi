import Foundation

class GameState: ObservableObject {
    
    @Published private(set) var board: [TriangleCoordinate: Piece]
    @Published private(set) var currentPlayer: Player
    @Published private(set) var isGameOver: Bool = false
    @Published private(set) var legalMoves: Set<TriangleCoordinate> = []
    @Published var isAnimating = false
    private let animationDuration: Double = 0.6
    private var pendingAnimationWorkItem: DispatchWorkItem?
    
    @Published var skipMessage: String?
    @Published var gameOverInfo: (winner: Player?, blackCount: Int, whiteCount: Int)? {
        didSet { showGameOverModal = gameOverInfo != nil }
    }
    @Published var showGameOverModal = false

    let geometry: BoardGeometry
    var moveHistory: [(move: TriangleCoordinate, flipped: [TriangleCoordinate], player: Player)] = []
    private let selectedLayout: [TriangleCoordinate: Piece]

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

    private func recalculateLegalMoves() {
        var moves = Set<TriangleCoordinate>()
        for coord in geometry.allCoordinates where board[coord] == .empty {
            if !flippedCoordinatesIfPlace(at: coord, by: currentPlayer).isEmpty {
                moves.insert(coord)
            }
        }
        legalMoves = moves
    }

    private func flippedCoordinatesIfPlace(at coordinate: TriangleCoordinate, by player: Player) -> [TriangleCoordinate] {
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

            while true {
                let (nextQ, nextR, nextIsUp) = direction(currentQ, currentR, currentIsUp)
                let nextCoord = TriangleCoordinate(q: nextQ, r: nextR, isPointingUp: nextIsUp)
                guard geometry.allCoordinates.contains(nextCoord) else { break }

                let nextPiece = board[nextCoord] ?? .empty

                // 可翻转的对手棋子（黑/白 或 方向子）
                let isOpponent = (nextPiece.owner == opponent) || (nextPiece.directionalDirection != nil)
                if isOpponent {
                    if let dir = nextPiece.directionalDirection, dir != dirIndex {
                        break
                    }
                    toFlip.append(nextCoord)
                    currentQ = nextQ
                    currentR = nextR
                    currentIsUp = nextIsUp
                } else if nextPiece.owner == player && !toFlip.isEmpty {
                    flipped.append(contentsOf: toFlip)
                    break
                } else if nextPiece == .neutral {
                    currentQ = nextQ
                    currentR = nextR
                    currentIsUp = nextIsUp
                } else {
                    break
                }
            }
        }
        return Array(Set(flipped))
    }

    func previewFlipped(at coordinate: TriangleCoordinate) -> [TriangleCoordinate] {
        flippedCoordinatesIfPlace(at: coordinate, by: currentPlayer)
    }

    private func checkGameOver() {
        if legalMoves.isEmpty {
            let opponent = currentPlayer.opponent
            var opponentHasMoves = false
            for coord in geometry.allCoordinates where board[coord] == .empty {
                if !flippedCoordinatesIfPlace(at: coord, by: opponent).isEmpty {
                    opponentHasMoves = true
                    break
                }
            }
            if !opponentHasMoves {
                let counts = countPieces()
                gameOverInfo = (winner: winner(), blackCount: counts.black, whiteCount: counts.white)
                isGameOver = true
            } else {
                skipMessage = "\(currentPlayer.name) 无法落子，跳过本回合"
                currentPlayer = opponent
                recalculateLegalMoves()
            }
        }
    }

    func winner() -> Player? {
        let counts = countPieces()
        if counts.black > counts.white { return .black }
        if counts.white > counts.black { return .white }
        return nil
    }

    func clearSkipMessage() { skipMessage = nil }

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
}

extension GameState {
    static func flippedCoordinatesIfPlace(at coordinate: TriangleCoordinate,
                                          board: [TriangleCoordinate: Piece],
                                          geometry: BoardGeometry,
                                          player: Player) -> [TriangleCoordinate] {
        // 与上面 flippedCoordinatesIfPlace 完全相同的逻辑
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

            while true {
                let (nextQ, nextR, nextIsUp) = direction(currentQ, currentR, currentIsUp)
                let nextCoord = TriangleCoordinate(q: nextQ, r: nextR, isPointingUp: nextIsUp)
                guard geometry.allCoordinates.contains(nextCoord) else { break }

                let nextPiece = board[nextCoord] ?? .empty

                let isOpponent = (nextPiece.owner == opponent) || (nextPiece.directionalDirection != nil)
                if isOpponent {
                    if let dir = nextPiece.directionalDirection, dir != dirIndex { break }
                    toFlip.append(nextCoord)
                    currentQ = nextQ
                    currentR = nextR
                    currentIsUp = nextIsUp
                } else if nextPiece.owner == player && !toFlip.isEmpty {
                    flipped.append(contentsOf: toFlip)
                    break
                } else if nextPiece == .neutral {
                    currentQ = nextQ
                    currentR = nextR
                    currentIsUp = nextIsUp
                } else {
                    break
                }
            }
        }
        return Array(Set(flipped))
    }

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

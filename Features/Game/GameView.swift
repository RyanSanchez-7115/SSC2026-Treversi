import SwiftUI

/**
 * @struct GameView
 * @brief Main game view.
 * @details Responsible for rendering the game board, player panels, game over modal, and handling turn skip messages.
 */
struct GameView: View {
    
    // MARK: - Behaviours & Configuration
    
    /// Game state object, responsible for core logic
    @StateObject private var gameState: GameState
    
    /// Game configuration parameters
    private let config: GameConfig
    
    /// Callback closure for returning to the previous screen
    private let onBack: (() -> Void)?

    // MARK: - UI State
    
    /// Local state controlling the game over modal display (mainly for sheet binding)
    /// @note Actually depends on gameState.showGameOverModal
    @State private var showGameOverSheet = false
    
    /// Task for managing the auto-dismissal of the skip turn message
    @State private var skipMessageWorkItem: DispatchWorkItem?

    // MARK: - Initialization
    
    /**
     * @brief Initialize game view.
     * @param config Game configuration object, containing board type, rule switches, etc.
     * @param onBack Callback when the back button is clicked.
     */
    init(config: GameConfig, onBack: (() -> Void)? = nil) {
        self.config = config
        self.onBack = onBack

        // Generate corresponding board geometry based on configuration
        let geometry: BoardGeometry
        switch config.boardType {
        case .hexagon: geometry = HexagonBoard(radius: config.radius)
        case .diamond: geometry = DiamondBoard(radius: config.radius)
        case .triangle: geometry = TriangleBoard(radius: config.radius)
        }

        // Get initial layout
        let layout = config.boardType.getLayout(at: config.layoutIndex)
        
        // Filter special pieces (e.g., neutral, directional) from the layout based on configuration
        var filteredLayout = layout
        for (coord, piece) in filteredLayout {
            var finalPiece = piece
            if !config.enableNeutral && piece == .neutral {
                finalPiece = .empty
            }
            if !config.enableDirectional && piece.directionalDirection != nil {
                finalPiece = .empty
            }
            filteredLayout[coord] = finalPiece
        }

        // Initialize GameState
        _gameState = StateObject(wrappedValue: GameState(geometry: geometry, initialOccupation: filteredLayout))
    }

    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                // Skip turn message overlay
                if let message = gameState.skipMessage {
                    Text(message)
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(16)
                        .rotationEffect(gameState.currentPlayer == .white ? .degrees(0) : .degrees(180))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .background(Color.black.opacity(0.2))
                        .zIndex(10)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                gameState.clearSkipMessage()
                            }
                        }
                }
                
                // Main game area layout
                VStack(spacing: 0) {
                    
                    // Top panel (White/Opponent)
                    playerPanel(for: .white, isTop: true)
                        .frame(height: 100)

                    // Middle board area
                    ZStack {
                        Color.clear
                        
                        if geometry.size.width > 10 && geometry.size.height > 10 {
                            // Safety threshold to avoid crashes due to small geometry size
                            BoardView(
                                gameState: gameState,
                                geometry: gameState.geometry,
                                showLegalMoves: config.showLegalMoves,
                                showPreview: config.showPreview,
                                isEnabled: !gameState.isGameOver && !gameState.isAnimating
                            )
                            .aspectRatio(1, contentMode: .fit)
                            .frame(
                                maxWidth: min(geometry.size.width, geometry.size.height),
                                maxHeight: min(geometry.size.width, geometry.size.height)
                            )
                        } else {
                            // Placeholder view to avoid layout calculation errors
                            ProgressView()
                                .frame(width: 50, height: 50)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    // Bottom panel (Black/Current Player)
                    playerPanel(for: .black, isTop: false)
                        .frame(height: 100)
                }

                // Overlay: Skip turn message
                skipTurnOverlay
            }
        }
        .background(Color(.systemBackground))
        .ignoresSafeArea(edges: .horizontal)
        // Game over modal
        .sheet(isPresented: $gameState.showGameOverModal) {
            if let info = gameState.gameOverInfo {
                GameOverView(
                    winner: info.winner,
                    blackCount: info.blackCount,
                    whiteCount: info.whiteCount,
                    onRestart: {
                        gameState.restart()
                        gameState.showGameOverModal = false
                    },
                    onBack: {
                        onBack?()
                    }
                )
            }
        }
    }
    
    // MARK: - Subviews
    
    /**
     * @brief Build player panel.
     * @param player The player represented by this panel.
     * @param isTop Whether it is displayed at the top of the screen (affects layout direction).
     */
    private func playerPanel(for player: Player, isTop: Bool) -> some View {
        PlayerPanel(
            player: player,
            opponent: player.opponent,
            isCurrentPlayer: gameState.currentPlayer == player,
            counts: gameState.countPieces(),
            enableUndo: config.enableUndo,
            isTop: isTop,
            onUndo: { _ = gameState.undoMove() },
            onRestart: { gameState.restart() },
            onBack: { onBack?() }
        )
    }
    
    /**
     * @brief Overlay view for skip turn message.
     */
    private var skipTurnOverlay: some View {
        Group {
            if let message = gameState.skipMessage {
                VStack {
                    Text(message)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                }
                .transition(.opacity)
                .onAppear {
                    // Automatically clear message after 2 seconds
                    let workItem = DispatchWorkItem {
                        withAnimation {
                            gameState.clearSkipMessage()
                        }
                    }
                    skipMessageWorkItem = workItem
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: workItem)
                }
                .onDisappear {
                    skipMessageWorkItem?.cancel()
                }
            }
        }
    }
}

/**
 * @struct GameOverView
 * @brief Game over display view.
 * @details Shows the winner, piece counts for both sides, and provides options to restart or go back.
 */
struct GameOverView: View {
    
    /// The winning player (nil indicates a draw)
    let winner: Player?
    /// Total count of black pieces
    let blackCount: Int
    /// Total count of white pieces
    let whiteCount: Int
    /// Restart callback
    let onRestart: () -> Void
    /// Return to settings callback
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Game Over")
                .font(.largeTitle)
                .fontWeight(.bold)

            if let winner = winner {
                Text("\(winner == .black ? "Black" : "White") Wins!")
                    .font(.title2)
            } else {
                Text("Draw")
                    .font(.title2)
            }

            // Score statistics
            HStack(spacing: 40) {
                VStack {
                    Text("Black")
                        .font(.headline)
                    Text("\(blackCount)")
                        .font(.title)
                }
                VStack {
                    Text("White")
                        .font(.headline)
                    Text("\(whiteCount)")
                        .font(.title)
                }
            }
            .padding()

            // Action buttons
            HStack(spacing: 20) {
                Button("Restart") {
                    onRestart()
                }
                .buttonStyle(.borderedProminent)

                Button("Back to settings") {
                    onBack()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(20)
        .cornerRadius(20)
        .shadow(radius: 20)
    }
}

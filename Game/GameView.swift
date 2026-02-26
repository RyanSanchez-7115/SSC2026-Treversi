import SwiftUI

struct GameView: View {
    @StateObject private var gameState: GameState
    let config: GameConfig
    let onBack: (() -> Void)?

    @State private var showGameOverSheet = false
    @State private var skipMessageWorkItem: DispatchWorkItem?

    init(config: GameConfig, onBack: (() -> Void)? = nil) {
        self.config = config
        self.onBack = onBack

        let geometry: BoardGeometry
        switch config.boardType {
        case .hexagon: geometry = HexagonBoard(radius: config.radius)
        case .diamond: geometry = DiamondBoard(radius: config.radius)
        case .triangle: geometry = TriangleBoard(radius: config.radius)
        }

        let layout = config.boardType.getLayout(at: config.layoutIndex)   // 现在返回 Piece
        _gameState = StateObject(wrappedValue: GameState(geometry: geometry, initialOccupation: layout))
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 0) {
                    // 顶部面板（对手）
                    PlayerPanel(
                        player: .white,
                        opponent: .black,
                        isCurrentPlayer: gameState.currentPlayer == .white, counts: gameState.countPieces(),
                        enableUndo: config.enableUndo,
                        isTop: true,
                        onUndo: { _ = gameState.undoMove() },
                        onRestart: { gameState.restart() },
                        onBack: { onBack?() }
                    )
                    .frame(height: 100)

                    // 棋盘区域
                    ZStack {
                        Color.clear
                        BoardView(
                            gameState: gameState,
                            geometry: gameState.geometry,
                            showLegalMoves: config.showLegalMoves,
                            showPreview: config.showPreview,
                            isEnabled: !gameState.isGameOver && !gameState.isAnimating
                        )
                        .aspectRatio(1, contentMode: .fit)
                        .frame(
                            maxWidth: min(geometry.size.width, geometry.size.height - 200),
                            maxHeight: min(geometry.size.width, geometry.size.height - 200)
                        )
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    // 底部面板（本方）
                    PlayerPanel(
                        player: .black,
                        opponent: .white,
                        isCurrentPlayer: gameState.currentPlayer == .black, counts: gameState.countPieces(),
                        enableUndo: config.enableUndo,
                        isTop: false,
                        onUndo: { _ = gameState.undoMove() },
                        onRestart: { gameState.restart() },
                        onBack: { onBack?() }
                    )
                    .frame(height: 100)
                }

                // 跳过回合提示浮层
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
                        // 2秒后自动清除
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
        .background(Color(.systemBackground))
        .ignoresSafeArea(edges: .horizontal)
        // 游戏结束弹窗
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
}

// 游戏结束视图
struct GameOverView: View {
    let winner: Player?
    let blackCount: Int
    let whiteCount: Int
    let onRestart: () -> Void
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("游戏结束")
                .font(.largeTitle)
                .fontWeight(.bold)

            if let winner = winner {
                Text("获胜方：\(winner == .black ? "黑方" : "白方")")
                    .font(.title2)
            } else {
                Text("平局")
                    .font(.title2)
            }

            HStack(spacing: 40) {
                VStack {
                    Text("黑棋")
                        .font(.headline)
                    Text("\(blackCount)")
                        .font(.title)
                }
                VStack {
                    Text("白棋")
                        .font(.headline)
                    Text("\(whiteCount)")
                        .font(.title)
                }
            }
            .padding()

            HStack(spacing: 20) {
                Button("重新开始") {
                    onRestart()
                }
                .buttonStyle(.borderedProminent)

                Button("返回设置") {
                    onBack()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(40)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 20)
    }
}

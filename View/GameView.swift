import SwiftUI

struct GameView: View {
    @StateObject private var gameState: GameState
    let config: GameConfig
    let onBack: (() -> Void)?
    
    init(config: GameConfig, onBack: (() -> Void)? = nil) {
        self.config = config
        self.onBack = onBack
        
        // 根据配置创建棋盘几何体
        let geometry: BoardGeometry
        switch config.boardType {
        case .hexagon:
            geometry = HexagonBoard(radius: config.radius)
        case .diamond:
            geometry = HexagonBoard(radius: 3) // 占位
        case .irregular:
            geometry = HexagonBoard(radius: 3) // 占位
        }
        
        // 获取对应布局
        let layout: [TriangleCoordinate: Player]
        switch config.boardType {
        case .hexagon:
            if config.layoutIndex < HexagonBoard.layouts.count {
                layout = HexagonBoard.layouts[config.layoutIndex]
            } else {
                layout = [:]
            }
        default:
            layout = [:]
        }
        
        _gameState = StateObject(wrappedValue: GameState(geometry: geometry, initialOccupation: layout))
    }
    
    var body: some View {
        VStack {
            // 顶部信息栏
            HStack {
                PlayerIndicator(player: .black, count: gameState.countPieces().black)
                Spacer()
                Text("当前回合")
                    .font(.headline)
                Spacer()
                PlayerIndicator(player: .white, count: gameState.countPieces().white)
            }
            .padding(.horizontal)
            
            // 棋盘视图（传递配置中的开关）
            BoardView(
                gameState: gameState,
                geometry: gameState.geometry,
                showLegalMoves: config.showLegalMoves,
                showPreview: config.showPreview
            )
            .aspectRatio(1, contentMode: .fit)
            .padding()
            
            // 控制按钮
            HStack(spacing: 30) {
                if config.enableUndo {
                    Button(action: { _ = gameState.undoMove() }) {
                        Label("撤销", systemImage: "arrow.uturn.backward")
                    }
                    .disabled(gameState.moveHistory.isEmpty || gameState.isAnimating)
                }
                
                Button(action: { gameState.restart() }) {
                    Label("重新开始", systemImage: "arrow.counterclockwise")
                }
                .disabled(gameState.isAnimating)
            }
            .padding()
        }
        .background(
            Color(.systemBackground)
                .ignoresSafeArea()
        )
        .toolbar {
            if onBack != nil {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        onBack?()
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("设置")
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(onBack != nil)
    }
}
// 玩家指示器组件保持不变
struct PlayerIndicator: View {
    let player: Player
    let count: Int
    
    var body: some View {
        HStack {
            Circle()
                .fill(player == .black ? Color.black : Color.white)
                .frame(width: 24, height: 24)
                .overlay(Circle().stroke(Color.gray, lineWidth: 1))
            Text("\(count)")
                .font(.title2)
                .bold()
        }
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

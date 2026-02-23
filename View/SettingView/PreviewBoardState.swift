import SwiftUI
import Combine

class PreviewBoardState: ObservableObject {
    // 用户可调节的配置
    @Published var radius: Int = 3 {
        didSet { updateLegalMoves() }
    }
    @Published var layoutIndex: Int = 0 {
        didSet { updateLegalMoves() }
    }
    @Published var showLegalMoves: Bool = true
    
    // 固定最大半径（用于生成所有坐标，保持视图稳定）
    let maxRadius = 5
    let allCoordinates: Set<TriangleCoordinate>
    let hexagonBoard: HexagonBoard  // 用于调用范围判断
    
    // 当前棋盘类型（预览只支持六边形）
    let boardType: BoardType = .hexagon
    
    // 当前布局字典（从 HexagonBoard 获取）
    var currentLayout: [TriangleCoordinate: Player] {
        guard layoutIndex < HexagonBoard.layouts.count else { return [:] }
        return HexagonBoard.layouts[layoutIndex]
    }
    
    // 缓存当前半径内的合法移动
    @Published private(set) var legalMoves: Set<TriangleCoordinate> = []
    
    init() {
        self.hexagonBoard = HexagonBoard(radius: maxRadius)
        self.allCoordinates = hexagonBoard.allCoordinates
        updateLegalMoves()
    }
    
    // 判断坐标是否在当前半径内（委托给 HexagonBoard）
    func isWithinRadius(_ coord: TriangleCoordinate) -> Bool {
        hexagonBoard.isCoordinate(coord, withinRadius: radius)
    }
    
    // 更新合法移动（当半径或布局改变时调用）
    private func updateLegalMoves() {
        // 构建当前半径的几何体和棋盘状态
        let geometry = HexagonBoard(radius: radius)
        var boardState: [TriangleCoordinate: Player] = [:]
        for coord in geometry.allCoordinates {
            boardState[coord] = currentLayout[coord] ?? .empty
        }
        
        // 计算合法移动（假设当前玩家为黑方，预览中只关心空位是否能翻转）
        legalMoves = GameState.legalMoves(for: .black, board: boardState, geometry: geometry)
    }
}

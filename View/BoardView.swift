import SwiftUI

struct BoardView: View {
    // 游戏状态（驱动UI更新）
    @ObservedObject var gameState: GameState
    // 棋盘几何信息（提供所有坐标）
    let geometry: BoardGeometry
    // 三角形边长（可根据需要调整，或作为参数传入）
    let side: CGFloat = 100
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(Array(geometry.allCoordinates), id: \.self) { coord in
                    TriangleView(
                        coordinate: coord,
                        player: gameState.board[coord] ?? .empty,
                        isLegalMove: gameState.legalMoves.contains(coord),
                        isHovered: false, // 悬停预览稍后实现
                        side: side
                    )
                    .position(position(for: coord, in: proxy.size))
                    .onTapGesture {
                        _ = gameState.makeMove(at: coord)
                    }
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }
    
    // 根据新的定位算法计算每个三角形的中心在视图中的位置
    private func position(for coord: TriangleCoordinate, in size: CGSize) -> CGPoint {
        // 1. 基础几何常数
        let height = side * sqrt(3) / 2               // 三角形的高
        let horizontalSpacing = side / 2               // 左右相邻三角形中心距
        let verticalSpacing = height                    // 上下相邻三角形中心距
        
        // 2. 该三角形中心相对于 (0,0,false) 中心的偏移
        let centerX = horizontalSpacing * CGFloat(coord.q)
        let centerY = -verticalSpacing * CGFloat(coord.r)
        
        // 3. (0,0,false) 中心相对于其下顶点的偏移（朝下三角形中心在下顶点上方 height/2 处）
        let anchorOffsetY = height / 2
        
        // 4. 最终位置：视图中心 + 中心偏移 - 锚点偏移
        let x = size.width / 2 + centerX
        let y = size.height / 2 + centerY - anchorOffsetY
        
        return CGPoint(x: x, y: y)
    }
}

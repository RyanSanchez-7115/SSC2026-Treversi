import SwiftUI

struct BoardView: View {
    // 游戏状态（驱动UI更新）
    @ObservedObject var gameState: GameState
    // 棋盘几何信息（提供所有坐标）
    let geometry: BoardGeometry
    // 三角形边长（可根据需要调整，或作为参数传入）
    let side: CGFloat = 100
    // 新增：三角形之间的间距
    let spacing: CGFloat = 7.0
    //实际的三角形棋子的边长
    var realside: CGFloat {side - spacing}
    // 用于悬停预览的状态
    @State private var previewCoord: TriangleCoordinate?
    @State private var previewFlippedCoords: Set<TriangleCoordinate> = []
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(Array(geometry.allCoordinates), id: \.self) { coord in
                    let isLegal = !gameState.isAnimating && gameState.legalMoves.contains(coord)
                    TriangleView(
                        coordinate: coord,
                        player: gameState.board[coord] ?? .empty,
                        isLegalMove:  isLegal,
                        isHovered: false, // for apple pencil hover, currently not used
                        side: realside
                    )
                    .position(position(for: coord, in: proxy.size))
                    .onTapGesture {
                        guard !gameState.isAnimating else { return }
                        _ = gameState.makeMove(at: coord)
                    }
                }
            // 动画期间屏蔽点击的透明层
                            if gameState.isAnimating {
                                Color.clear
                                    .contentShape(Rectangle())
                                    .allowsHitTesting(true)
                                    .onTapGesture {} // 空手势消耗点击
                            }
                        }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }
    
    // 根据新的定位算法计算每个三角形的中心在视图中的位置
    private func position(for coord: TriangleCoordinate, in size: CGSize) -> CGPoint {
        // 1. 基础几何常数
        let height = side * sqrt(2.8) / 2        // 三角形的高
        
        // 2. 调整间距计算
        // 增加一个额外的水平和垂直距离来产生间距
        let horizontalSpacing = side / 2 // 水平间距（考虑到三角形的宽度和间距）
        let verticalSpacing = height // 垂直间距（考虑到三角形的高度和间距）
        
        // 3. 该三角形中心相对于 (0,0,false) 中心的偏移
        let centerX = horizontalSpacing * CGFloat(coord.q)
        let centerY = -verticalSpacing * CGFloat(coord.r)
        
        // 4. (0,0,false) 中心相对于其下顶点的偏移（朝下三角形中心在下顶点上方 height/2 处）
        let anchorOffsetY = height / 2
        
        // 5. 最终位置：视图中心 + 中心偏移 - 锚点偏移
        let x = size.width / 2 + centerX
        let y = size.height / 2 + centerY - anchorOffsetY
        
        return CGPoint(x: x, y: y)
    }
}

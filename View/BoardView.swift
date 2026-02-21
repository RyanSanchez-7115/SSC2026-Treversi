import SwiftUI

struct BoardView: View {
    @ObservedObject var gameState: GameState
    let geometry: BoardGeometry
    let side: CGFloat = 100
    let spacing: CGFloat = 7.0
    var realside: CGFloat { side - spacing }
    
    // 新增：功能开关
    let showLegalMoves: Bool
    let showPreview: Bool
    
    @State private var previewCoord: TriangleCoordinate?
    @State private var previewFlipped: Set<TriangleCoordinate> = []
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(Array(geometry.allCoordinates), id: \.self) { coord in
                    TriangleView(
                        coordinate: coord,
                        player: gameState.board[coord] ?? .empty,
                        isLegalMove: showLegalMoves && !gameState.isAnimating && gameState.legalMoves.contains(coord),
                        isPreview: (coord == previewCoord),
                        isPreviewFlipped: previewFlipped.contains(coord),
                        isHovered: false,
                        side: realside
                    )
                    .position(position(for: coord, in: proxy.size))
                }

                // 手势层：仅在游戏未动画时添加
                if !gameState.isAnimating {
                    if showPreview {
                        // 预览模式：使用拖动手势处理预览和落子
                        Color.clear
                            .contentShape(Rectangle())
                            .frame(width: proxy.size.width, height: proxy.size.height)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        handleDragChanged(value, in: proxy)
                                    }
                                    .onEnded { value in
                                        handleDragEnded(value, in: proxy)
                                    }
                            )
                    } else {
                        // 非预览模式：使用简单点击层，直接落子
                        Color.clear
                            .contentShape(Rectangle())
                            .frame(width: proxy.size.width, height: proxy.size.height)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onEnded { value in
                                        let location = value.location
                                        guard let coord = findCoordinate(at: location, in: proxy.size) else { return }
                                        if gameState.legalMoves.contains(coord) {
                                            _ = gameState.makeMove(at: coord)
                                        }
                                    }
                            )
                    }
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }
    // MARK: - 手势处理
    private func handleDragChanged(_ value: DragGesture.Value, in proxy: GeometryProxy) {
        guard !gameState.isAnimating else { return }
        
        let location = value.location
        guard let coord = findCoordinate(at: location, in: proxy.size) else {
            if previewCoord != nil {
                withAnimation(.easeOut(duration: 0.2)) {
                    clearPreview()
                }
            }
            return
        }
        
        if previewCoord == nil {
            // 进入新的预览点
            if gameState.legalMoves.contains(coord) {
                let flipped = gameState.previewFlipped(at: coord)
                withAnimation(.easeOut(duration: 0.2)) {
                    previewCoord = coord
                    previewFlipped = Set(flipped)
                }
            }
        } else if coord != previewCoord {
            // 移出当前预览点
            withAnimation(.easeOut(duration: 0.2)) {
                clearPreview()
            }
        }
    }
    
    private func handleDragEnded(_ value: DragGesture.Value, in proxy: GeometryProxy) {
        guard !gameState.isAnimating else {
            withAnimation(.easeOut(duration: 0.2)) {
                clearPreview()
            }
            return
        }
        
        let location = value.location
        if let coord = findCoordinate(at: location, in: proxy.size),
           coord == previewCoord,
           gameState.legalMoves.contains(coord) {
            _ = gameState.makeMove(at: coord)
        }
        withAnimation(.easeOut(duration: 0.2)) {
            clearPreview()
        }
    }
    private func clearPreview() {
        previewCoord = nil
        previewFlipped.removeAll()
    }
    
    // MARK: - 坐标查找
    private func findCoordinate(at location: CGPoint, in size: CGSize) -> TriangleCoordinate? {
        let threshold = side / 2  // 可调整
        var bestCoord: TriangleCoordinate?
        var bestDistance: CGFloat = .infinity
        
        for coord in geometry.allCoordinates {
            let center = position(for: coord, in: size)
            let distance = hypot(location.x - center.x, location.y - center.y)
            if distance < threshold && distance < bestDistance {
                bestDistance = distance
                bestCoord = coord
            }
        }
        return bestCoord
    }
    
    // MARK: - 坐标转位置
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

import SwiftUI

struct BoardView: View {
    @ObservedObject var gameState: GameState
    let geometry: BoardGeometry
    let side: CGFloat = 85
    let spacing: CGFloat = 7.0
    var realside: CGFloat { side - spacing }
    let showLegalMoves: Bool
    let showPreview: Bool
    var isEnabled: Bool = true
    
    @State private var previewCoord: TriangleCoordinate?
    @State private var previewFlipped: Set<TriangleCoordinate> = []
    
    // MARK: - 交互状态
    @State private var isPreviewActive: Bool = false
    @State private var longPressTask: Task<Void, Never>? = nil // 用于检测长按的任务
    
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
                
                // 手势层
                if isEnabled && !gameState.isAnimating {
                    if showPreview {
                        Color.clear
                            .contentShape(Rectangle())
                            .frame(width: proxy.size.width, height: proxy.size.height)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        handleTouchDownOrMove(value, in: proxy)
                                    }
                                    .onEnded { value in
                                        handleTouchUp(value, in: proxy)
                                    }
                            )
                    } else {
                        // 非预览模式：直接落子
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
    
    // MARK: - 手势处理逻辑
    
    func handleTouchDownOrMove(_ value: DragGesture.Value, in proxy: GeometryProxy) {
        guard !gameState.isAnimating else { return }
        let location = value.location

        // 1. 如果这是新的触摸（还没有任务），启动长按检测任务
        if longPressTask == nil && !isPreviewActive {
            longPressTask = Task {
                // 等待 0.3 秒
                try? await Task.sleep(nanoseconds: 300_000_000) // 0.3s
                
                // 如果任务没有被取消（手指没松开），则激活预览
                if !Task.isCancelled {
                    await MainActor.run {
                        // 激活预览模式，并显示当前位置的预览
                        isPreviewActive = true
                        updatePreview(at: location, in: proxy)
                    }
                }
            }
        }
        
        // 2. 如果预览已经激活（无论是刚激活还是正在拖动），实时更新显示
        if isPreviewActive {
            updatePreview(at: location, in: proxy)
        }
    }
    
    func updatePreview(at location: CGPoint, in proxy: GeometryProxy) {
        guard let coord = findCoordinate(at: location, in: proxy.size) else {
            // 移出了有效区域
            if previewCoord != nil {
                withAnimation(.easeOut(duration: 0.2)) {
                    clearPreview()
                }
            }
            return
        }
        
        if previewCoord != coord {
            // 只有当移到新格子，且是合法步时才更新
            if gameState.legalMoves.contains(coord) {
                let flipped = gameState.previewFlipped(at: coord)
                withAnimation(.easeOut(duration: 0.2)) {
                    previewCoord = coord
                    previewFlipped = Set(flipped)
                }
            } else {
                // 移到了不合法格子
                withAnimation(.easeOut(duration: 0.2)) {
                    clearPreview()
                }
            }
        }
    }
    
    func handleTouchUp(_ value: DragGesture.Value, in proxy: GeometryProxy) {
       
        longPressTask?.cancel()
        longPressTask = nil
                
        // 重置状态
        isPreviewActive = false
        
        guard !gameState.isAnimating else {
            withAnimation(.easeOut(duration: 0.2)) { clearPreview() }
            return
        }
        
        let location = value.location
        guard let coord = findCoordinate(at: location, in: proxy.size),
              gameState.legalMoves.contains(coord) else {
            // 在无效位置松手
            withAnimation(.easeOut(duration: 0.2)) { clearPreview() }
            return
        }
        
        // 逻辑：
        // A. 如果是短按（wasPreviewActive == false），直接落子。
        // B. 如果是长按预览后松手（wasPreviewActive == true），通常也意味着确认落子。
        _ = gameState.makeMove(at: coord)
        
        withAnimation(.easeOut(duration: 0.2)) {
            clearPreview()
        }
    }
    
    func clearPreview() {
        previewCoord = nil
        previewFlipped.removeAll()
    }
    
    // MARK: - 坐标查找 (保持不变)
    func findCoordinate(at location: CGPoint, in size: CGSize) -> TriangleCoordinate? {
        let threshold = side / 2
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
    
    // MARK: - 坐标转位置 (保持不变)
    func position(for coord: TriangleCoordinate, in size: CGSize) -> CGPoint {
        let height = side * sqrt(2.8) / 2
        let horizontalSpacing = side / 2
        let verticalSpacing = height
        let centerX = horizontalSpacing * CGFloat(coord.q)
        let centerY = -verticalSpacing * CGFloat(coord.r)
        let anchorOffsetY = height / 2
        let x = size.width / 2 + centerX
        let y = size.height / 2 + centerY - anchorOffsetY
        return CGPoint(x: x, y: y)
    }
}


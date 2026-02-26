import SwiftUI

struct PreviewBoardView: View {
    @ObservedObject var state: PreviewBoardState
    let side: CGFloat = 100
    let spacing: CGFloat = 7.0
    var realside: CGFloat { side - spacing }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(Array(state.allCoordinates), id: \.self) { coord in
                    let isWithin = state.isWithinRadius(coord)
                    let piece = isWithin ? (state.currentLayout[coord] ?? .empty) : .empty
                    let isLegal = isWithin && state.showLegalMoves && !state.isAnimating && piece == .empty && state.legalMoves.contains(coord)
                    
                    TriangleView(
                        coordinate: coord,
                        piece: piece,                     // ← 改成 piece
                        isLegalMove: isLegal,
                        isPreview: false,
                        isPreviewFlipped: false,
                        isHovered: false,
                        side: realside
                    )
                    .position(position(for: coord, in: proxy.size))
                    .opacity(isWithin ? 1 : 0)
                    .allowsHitTesting(false)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .delay(
                            Double(coord.q + coord.r + (coord.isPointingUp ? 10 : 0)) * 0.03
                        ),  // 根据 q + r 计算延迟，0.03秒间隔，视觉波浪效果
                        value: state.layoutIndex  // 依赖 layoutIndex 变化触发
                    )
                }
            }
        }
    }
    
    private func position(for coord: TriangleCoordinate, in size: CGSize) -> CGPoint {
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

import SwiftUI

struct PreviewTriangleView: View {
    @ObservedObject var state: PreviewBoardState
    let side: CGFloat = 100        // 必须与 BoardView 中的 side 完全一致
    let spacing: CGFloat = 7.0     // 必须与 BoardView 中的 spacing 完全一致
    var realside: CGFloat { side - spacing }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(Array(state.allCoordinates), id: \.self) { coord in
                    let isWithin = state.isWithinRadius(coord)
                    // 半径内：使用布局中的 player（如果没有则为 .empty）
                    // 半径外：强制设为 .empty（但通过 opacity 隐藏）
                    let player = isWithin ? (state.currentLayout[coord] ?? .empty) : .empty
                    let isLegal = isWithin && state.showLegalMoves && player == .empty && state.legalMoves.contains(coord)
                    
                    TriangleView(
                        coordinate: coord,
                        player: player,
                        isLegalMove: isLegal,
                        isPreview: false,
                        isPreviewFlipped: false,
                        isHovered: false,
                        side: realside
                    )
                    .position(position(for: coord, in: proxy.size))
                    .opacity(isWithin ? 1 : 0)      // 半径外完全透明
                    .allowsHitTesting(false)         // 禁止所有交互
                }
            }
        }
    }
    
    // 坐标转换函数：必须与 BoardView 中的 position 完全一致
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

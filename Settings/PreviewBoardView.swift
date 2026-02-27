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
                        piece: piece,
                        isLegalMove: isLegal,
                        isPreview: false,
                        isPreviewFlipped: false,
                        isHovered: false,
                        side: realside
                    )
                    .position(position(for: coord, in: proxy.size))
                    .opacity(isWithin ? 1 : 0)
                    .allowsHitTesting(false)
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

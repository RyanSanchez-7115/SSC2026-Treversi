import SwiftUI

struct DemoBoardView: View {
    let allCoordinates: Set<TriangleCoordinate>
    let colorForCoordinate: (TriangleCoordinate) -> Color?
    let side: CGFloat = 60

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(Array(allCoordinates), id: \.self) { coord in
                    DemoTriangleView(
                        coordinate: coord,
                        targetColor: colorForCoordinate(coord),
                        side: side
                    )
                    .position(position(for: coord, in: proxy.size))
                }
            }
        }
    }

    func position(for coord: TriangleCoordinate, in size: CGSize) -> CGPoint {
        let height = side * sqrt(3) / 2
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

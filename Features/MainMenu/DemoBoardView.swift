import SwiftUI

/**
 * @struct DemoBoardView
 * @brief Demo board view for the main menu background.
 * @details Responsible for rendering a static, non-interactive triangle grid background. The color of each cell is provided externally.
 */
struct DemoBoardView: View {
    /// Set of all triangle cell coordinates to be rendered.
    let allCoordinates: Set<TriangleCoordinate>
    /// A closure that returns the color for a given coordinate.
    let colorForCoordinate: (TriangleCoordinate) -> Color?
    
    /// The side length of the triangle cells for Demo
    let side: CGFloat = 55
    
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
    
    /**
     * @brief Calculate the CGPoint position of a given coordinate within the view.
     * @param coord The triangle grid coordinate.
     * @param size The size of the container view.
     * @return Returns the absolute position to be used in the ZStack.
     */
    func position(for coord: TriangleCoordinate, in size: CGSize) -> CGPoint {
        let height = side * sqrt(3) / 2
        let horizontalSpacing = side / 2
        let verticalSpacing = height
        
        // Calculate the offset from the center based on axial coordinates.
        let centerX = horizontalSpacing * CGFloat(coord.q)
        let centerY = -verticalSpacing * CGFloat(coord.r)
        
        // Visual offset correction.
        let anchorOffsetY = height / 2
        
        // Calculate the final absolute position in the view.
        let x = size.width / 2 + centerX
        let y = size.height / 2 + centerY - anchorOffsetY
        
        return CGPoint(x: x, y: y)
    }
}

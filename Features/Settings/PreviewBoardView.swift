import SwiftUI

/**
 * @struct PreviewBoardView
 * @brief A view for displaying a board preview in the settings screen.
 * @details This view renders a static, non-interactive board preview based on a `PreviewBoardState` object.
 *          It is responsible for displaying the piece distribution for different board types, sizes, and layouts,
 *          and can highlight legal move positions.
 */
struct PreviewBoardView: View {
    /// The manager for the board's state and logic. The view observes its changes and updates automatically.
    @ObservedObject var state: PreviewBoardState
    /// The base side length of the triangle cells (including spacing).
    let side: CGFloat = 100
    /// The spacing between triangle cells.
    let spacing: CGFloat = 7.0
    /// The actual rendering side length of the triangle cells (after subtracting spacing).
    var realside: CGFloat { side - spacing }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                // Iterate over all possible coordinates to create the board background grid
                ForEach(Array(state.allCoordinates), id: \.self) { coord in
                    // Check if the coordinate is within the currently selected radius
                    let isWithin = state.isWithinRadius(coord)
                    // Get the piece at the current coordinate, or empty if it's outside the radius
                    let piece = isWithin ? (state.currentLayout[coord] ?? .empty) : .empty
                    // Determine if it's a legal move position
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
                    .opacity(isWithin ? 1 : 0) // Make cells outside the radius transparent
                    .allowsHitTesting(false)   // The preview view does not respond to user interaction
                }
            }
        }
    }

    /**
     * @brief Calculates the absolute position of a given coordinate within the view.
     * @param coord The coordinate of the triangle cell to calculate the position for.
     * @param size The size of the container view.
     * @return A `CGPoint` to be used in the ZStack.
     */
    private func position(for coord: TriangleCoordinate, in size: CGSize) -> CGPoint {
        // Note: The sqrt(2.8) here is a visual adjustment value to match the board's visual spacing, not a strict geometric calculation.
        let height = side * sqrt(2.8) / 2
        let horizontalSpacing = side / 2
        let verticalSpacing = height

        // Calculate offset from the center based on axial coordinates
        let centerX = horizontalSpacing * CGFloat(coord.q)
        let centerY = -verticalSpacing * CGFloat(coord.r)

        // Visual anchor point offset correction
        let anchorOffsetY = height / 2

        // Calculate the final absolute position in the view
        let x = size.width / 2 + centerX
        let y = size.height / 2 + centerY - anchorOffsetY
        return CGPoint(x: x, y: y)
    }
}

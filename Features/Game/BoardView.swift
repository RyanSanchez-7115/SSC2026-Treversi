import SwiftUI

/**
 * @struct BoardView
 * @brief The main interactive game board view.
 * @details This view is responsible for rendering the triangular grid, displaying the pieces,
 *          and handling all user interactions, including simple taps to place a piece and a
 *          long-press gesture to preview a move before confirming. It observes a `GameState`
 *          object to reflect real-time changes in the game.
 */
struct BoardView: View {
    // MARK: - Properties

    /// The game state object, which this view observes for changes.
    @ObservedObject var gameState: GameState
    /// The geometric model of the board (e.g., Hexagon, Diamond).
    let geometry: BoardGeometry
    /// The base side length for a triangle cell, including spacing.
    let side: CGFloat = 100
    /// The spacing between triangle cells.
    let spacing: CGFloat = 7.0
    /// The actual rendering side length of a triangle cell (side - spacing).
    var realside: CGFloat { side - spacing }
    /// A flag to control the visibility of legal move indicators.
    let showLegalMoves: Bool
    /// A flag to enable or disable the long-press preview feature.
    let showPreview: Bool
    /// A flag to enable or disable user interaction with the board.
    var isEnabled: Bool = true

    // MARK: - State for Interaction

    /// The coordinate currently being previewed via long-press.
    @State private var previewCoord: TriangleCoordinate?
    /// The set of coordinates that would be flipped if a piece is placed at `previewCoord`.
    @State private var previewFlipped: Set<TriangleCoordinate> = []
    /// Tracks if the long-press preview gesture is currently active.
    @State private var isPreviewActive: Bool = false
    /// The background task that detects a long-press gesture.
    @State private var longPressTask: Task<Void, Never>?

    // MARK: - Body

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                // Layer 1: Render all triangle cells for the board grid.
                ForEach(Array(geometry.allCoordinates), id: \.self) { coord in
                    TriangleView(
                        coordinate: coord,
                        piece: gameState.board[coord] ?? .empty,
                        isLegalMove: showLegalMoves && !gameState.isAnimating && gameState.legalMoves.contains(coord),
                        isPreview: (coord == previewCoord),
                        isPreviewFlipped: previewFlipped.contains(coord),
                        isHovered: false,
                        side: realside
                    )
                    .position(position(for: coord, in: proxy.size))
                }

                // Layer 2: Gesture handling overlay.
                if isEnabled && !gameState.isAnimating {
                    gestureOverlay(in: proxy)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }

    // MARK: - Gesture Handling

    /**
     * @brief Creates a transparent overlay that captures user gestures.
     * @param proxy The geometry proxy of the container view.
     * @return A view that handles either long-press previews or simple taps.
     */
    @ViewBuilder
    private func gestureOverlay(in proxy: GeometryProxy) -> some View {
        if showPreview {
            // Mode 1: Long-press to preview, release to place.
            Color.clear
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            handleTouchDownOrMove(value.location, in: proxy)
                        }
                        .onEnded { value in
                            handleTouchUp(value.location, in: proxy)
                        }
                )
        } else {
            // Mode 2: Simple tap to place.
            Color.clear
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onEnded { value in
                            if let coord = findCoordinate(at: value.location, in: proxy.size),
                               gameState.legalMoves.contains(coord) {
                                _ = gameState.makeMove(at: coord)
                            }
                        }
                )
        }
    }

    /**
     * @brief Handles the initial touch-down or drag-move of a gesture.
     * @details It starts a timer for a long-press. If the gesture is held long enough,
     *          it activates preview mode. If preview is already active, it updates the preview.
     * @param location The current location of the touch.
     * @param proxy The geometry proxy of the container view.
     */
    private func handleTouchDownOrMove(_ location: CGPoint, in proxy: GeometryProxy) {
        guard !gameState.isAnimating else { return }

        // If this is a new touch, start a task to detect a long press.
        if longPressTask == nil && !isPreviewActive {
            longPressTask = Task {
                try? await Task.sleep(nanoseconds: 300_000_000) // 0.3s delay
                // If the task wasn't cancelled (finger is still down), activate preview mode.
                if !Task.isCancelled {
                    await MainActor.run {
                        isPreviewActive = true
                        updatePreview(at: location, in: proxy)
                    }
                }
            }
        }

        // If preview mode is active, update the preview display as the finger moves.
        if isPreviewActive {
            updatePreview(at: location, in: proxy)
        }
    }

    /**
     * @brief Handles the release of a touch gesture.
     * @details It cancels the long-press detection task, places a piece if the location is valid,
     *          and clears the preview state.
     * @param location The final location of the touch.
     * @param proxy The geometry proxy of the container view.
     */
    private func handleTouchUp(_ location: CGPoint, in proxy: GeometryProxy) {
        // Cancel the long-press task and reset preview state.
        longPressTask?.cancel()
        longPressTask = nil
        isPreviewActive = false

        guard !gameState.isAnimating else {
            clearPreviewAnimated()
            return
        }

        // Find the coordinate at the release point.
        guard let coord = findCoordinate(at: location, in: proxy.size),
              gameState.legalMoves.contains(coord) else {
            // Released on an invalid spot, just clear the preview.
            clearPreviewAnimated()
            return
        }

        // If the move is legal (short tap or release after long-press), make the move.
        _ = gameState.makeMove(at: coord)
        clearPreviewAnimated()
    }

    // MARK: - Preview Logic

    /**
     * @brief Updates the preview state based on the user's touch location.
     * @details Finds the coordinate under the touch. If it's a new, legal move,
     *          it updates the `previewCoord` and `previewFlipped` state variables.
     * @param location The current location of the touch.
     * @param proxy The geometry proxy of the container view.
     */
    private func updatePreview(at location: CGPoint, in proxy: GeometryProxy) {
        guard let coord = findCoordinate(at: location, in: proxy.size) else {
            // Finger moved outside any valid cell.
            if previewCoord != nil { clearPreviewAnimated() }
            return
        }

        if previewCoord != coord {
            if gameState.legalMoves.contains(coord) {
                // Moved to a new, legal cell. Update preview.
                let flipped = gameState.previewFlipped(at: coord)
                withAnimation(.easeOut(duration: 0.2)) {
                    previewCoord = coord
                    previewFlipped = Set(flipped)
                }
            } else {
                // Moved to an illegal cell. Clear preview.
                clearPreviewAnimated()
            }
        }
    }

    /// Resets the preview state variables.
    private func clearPreview() {
        previewCoord = nil
        previewFlipped.removeAll()
    }

    /// Resets the preview state variables with a fade-out animation.
    private func clearPreviewAnimated() {
        withAnimation(.easeOut(duration: 0.2)) {
            clearPreview()
        }
    }

    // MARK: - Coordinate & Position Helpers

    /**
     * @brief Finds the `TriangleCoordinate` corresponding to a `CGPoint` in the view.
     * @param location The point of interaction (e.g., a tap).
     * @param size The total size of the container view.
     * @return The `TriangleCoordinate` of the closest cell, or `nil` if none are close enough.
     */
    private func findCoordinate(at location: CGPoint, in size: CGSize) -> TriangleCoordinate? {
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

    /**
     * @brief Calculates the absolute `CGPoint` for a given `TriangleCoordinate`.
     * @param coord The coordinate of the triangle cell.
     * @param size The size of the container view.
     * @return The `CGPoint` to use for positioning the cell in a `ZStack`.
     */
    private func position(for coord: TriangleCoordinate, in size: CGSize) -> CGPoint {
        // Note: The sqrt(2.8) is a visual adjustment factor, not a strict geometric value.
        let height = side * sqrt(2.8) / 2
        let horizontalSpacing = side / 2
        let verticalSpacing = height

        // Calculate offset from center based on axial coordinates.
        let centerX = horizontalSpacing * CGFloat(coord.q)
        let centerY = -verticalSpacing * CGFloat(coord.r)

        // Adjust anchor point offset for different board types to achieve visual balance.
        let anchorOffsetY: CGFloat
        switch type(of: geometry) {
        case is HexagonBoard.Type, is DiamondBoard.Type:
            anchorOffsetY = height / 2
        case is TriangleBoard.Type:
            anchorOffsetY = -height * 0.9
        default:
            anchorOffsetY = height / 2
        }

        // Calculate final absolute position.
        let x = size.width / 2 + centerX
        let y = size.height / 2 + centerY - anchorOffsetY
        return CGPoint(x: x, y: y)
    }
}

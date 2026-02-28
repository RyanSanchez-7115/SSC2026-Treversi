import SwiftUI

/**
 * @struct TriangleView
 * @brief View component for a single triangle cell.
 * @details Responsible for rendering the triangle shape at the corresponding coordinate, piece style (color, border), special piece icons (neutral, directional), and flip animations.
 */
struct TriangleView: View {
    
    // MARK: - Configuration Properties
    
    let coordinate: TriangleCoordinate
    
    let side: CGFloat
    
    /// The type of piece currently on this cell
    let piece: Piece
    
    let isLegalMove: Bool
    
    /// Whether in preview mode (semi-transparent state shown on mouse hover or touch down)
    let isPreview: Bool
    
    /// Whether in flip preview state
    let isPreviewFlipped: Bool
    
    /// Whether the mouse is hovering over this cell (Considering touch interaction is primary and using Magic Keyboard or Apple Pencil to interact with such a two-palyers game is not a good choice ,over preview is not fully implemented but reserved for future expansion)
    let isHovered: Bool
    
    // MARK: - Internal State
    
    /// Controls the angle of the flip animation (0 -> 90 -> -90 -> 0)
    @State private var rotationAngle: Double = 0
    
    /// The current piece state being displayed (used for animation transitions)
    @State private var displayPiece: Piece
    
    /// Flag indicating if a flip animation is in progress
    @State private var isAnimating: Bool = false
    
    // MARK: - Initialization
    
    init(coordinate: TriangleCoordinate, piece: Piece, isLegalMove: Bool, isPreview: Bool, isPreviewFlipped: Bool, isHovered: Bool, side: CGFloat) {
        self.coordinate = coordinate
        self.piece = piece
        self.isLegalMove = isLegalMove
        self.isPreview = isPreview
        self.isPreviewFlipped = isPreviewFlipped
        self.isHovered = isHovered
        self.side = side
        // Initialize state to ensure the view displays correctly on first load
        _displayPiece = State(initialValue: piece)
    }
    
    // MARK: - Computed Properties (Style)
    
    /**
     * @brief Calculates the fill color of the triangle.
     * @details Determines color based on preview state, hover state, legal move state, and piece type.
     */
    private var fillColor: Color {
        // 1. Interaction states take precedence
        if isPreview || isPreviewFlipped || isHovered {
            return Color.green.opacity(0.3)
        }
        
        // 2. Piece state
        switch displayPiece {
        case .black: return .black
        case .white: return .white
        case .neutral: return .orange.opacity(0.4)
        case .directional: return .purple.opacity(0.4)
        case .empty:
            // If empty position is a legal move, show hint color
            return isLegalMove ? Color.green.opacity(0.3) : Color(.systemGray3)
        }
    }
    
    /**
     * @brief Calculates the border color of the triangle.
     */
    private var borderColor: Color {
        if isLegalMove && displayPiece == .empty && !isPreview && !isPreviewFlipped {
            return .green
        } else {
            return displayPiece.borderColor()
        }
    }
    
    /**
     * @brief Calculates the border width of the triangle.
     */
    private var borderWidth: CGFloat {
        if isLegalMove && displayPiece == .empty && !isPreview && !isPreviewFlipped {
            return 2
        } else {
            return displayPiece.borderWidth()
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Background and border layer
            TriangleShape(isPointingUp: coordinate.isPointingUp, cornerRadius: 2)
                .fill(fillColor)
                .animation(.easeInOut(duration: 0.2), value: isLegalMove)
                .overlay(
                    TriangleShape(isPointingUp: coordinate.isPointingUp, cornerRadius: 2)
                        .stroke(borderColor, lineWidth: borderWidth)
                )
            
            // Special piece icon layer (Neutral, Directional)
            if displayPiece != .empty && displayPiece.owner == nil {
                specialPieceIcon
            }
        }
        // Size and layout
        .frame(width: side, height: side * sqrt(3)/2)
        // Effects
        .scaleEffect(isPreview ? 0.85 : 1.0)
        .rotation3DEffect(.degrees(rotationAngle), axis: (x: 0, y: 1, z: 0), perspective: 0.3)
        // State monitoring
        .onChange(of: piece) { newPiece in
            if displayPiece != newPiece {
                performFlipAnimation(to: newPiece)
            } else {
                displayPiece = newPiece
            }
        }
        .onAppear {
            if displayPiece != piece {
                displayPiece = piece
            }
        }
    }
    
    // MARK: - Subviews
    
    /**
     * @brief Icon view for special pieces.
     * @details Displays an arrow or asterisk based on displayPiece type, positioned at the triangle's centroid.
     */
    @ViewBuilder
    private var specialPieceIcon: some View {
        // Calculate geometric center (centroid)
        let centroid: CGPoint = calculateCentroid()
        let iconSize: CGFloat = side * 0.3
        let frameSize: CGFloat = side * 0.38
        
        Group {
            if case .directional(let dir) = displayPiece {
                Image(systemName: "arrow.right")
                    .font(.system(size: iconSize, weight: .bold))
                    .foregroundStyle(Color.purple.opacity(0.8))
                    .rotationEffect(.degrees(Double(dir) * 60))
                    .frame(width: frameSize, height: frameSize)
            } else if case .neutral = displayPiece {
                Image(systemName: "asterisk")
                    .font(.system(size: iconSize, weight: .bold))
                    .foregroundStyle(Color.orange.opacity(0.85))
                    .rotationEffect(.degrees(30))
                    .frame(width: frameSize, height: frameSize)
            }
        }
        .position(centroid) // Critical: Position icon container at the triangle's geometric center
    }
    
    // MARK: - Helper Methods
    
    /**
     * @brief Calculates the geometric centroid of the triangle.
     * @return Centroid point CGPoint in the local coordinate system.
     */
    private func calculateCentroid() -> CGPoint {
        let height = side * sqrt(3) / 2
        let rect = CGRect(x: 0, y: 0, width: side, height: height)
        let p1, p2, p3: CGPoint
        
        if coordinate.isPointingUp {
            p1 = CGPoint(x: rect.midX, y: rect.minY)          // Top vertex
            p2 = CGPoint(x: rect.minX, y: rect.maxY)          // Bottom left
            p3 = CGPoint(x: rect.maxX, y: rect.maxY)          // Bottom right
        } else {
            p1 = CGPoint(x: rect.midX, y: rect.maxY)          // Bottom vertex
            p2 = CGPoint(x: rect.maxX, y: rect.minY)          // Top right
            p3 = CGPoint(x: rect.minX, y: rect.minY)          // Top left
        }
        
        let centerX = (p1.x + p2.x + p3.x) / 3
        let centerY = (p1.y + p2.y + p3.y) / 3
        return CGPoint(x: centerX, y: centerY)
    }
    
    /**
     * @brief Performs the flip animation.
     * @param newPiece The new piece state after the flip.
     */
    private func performFlipAnimation(to newPiece: Piece) {
        guard !isAnimating else { return }
        isAnimating = true
        let duration = 0.27
        
        // Phase 1: Rotate to 90 degrees (disappear)
        withAnimation(.easeIn(duration: duration)) {
            rotationAngle = 90
        }
        
        // Phase 2: Switch data, reset angle, rotate back to 0 degrees (reappear)
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.displayPiece = newPiece
            self.rotationAngle = -90
            withAnimation(.easeOut(duration: duration)) {
                self.rotationAngle = 0
            }
            // Animation finished
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                self.isAnimating = false
            }
        }
    }
}

// MARK: - Shapes

/**
 * @struct TriangleShape
 * @brief Custom triangle shape.
 * @details Supports upward or downward pointing direction and rounded corner drawing.
 */
struct TriangleShape: Shape {
    let isPointingUp: Bool
    var cornerRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let p1, p2, p3: CGPoint
        if isPointingUp {
            p1 = CGPoint(x: rect.midX, y: rect.minY)
            p2 = CGPoint(x: rect.minX, y: rect.maxY)
            p3 = CGPoint(x: rect.maxX, y: rect.maxY)
        } else {
            p1 = CGPoint(x: rect.midX, y: rect.maxY)
            p2 = CGPoint(x: rect.maxX, y: rect.minY)
            p3 = CGPoint(x: rect.minX, y: rect.minY)
        }
        
        // Simple linear interpolation to calculate corner start points (simplified algorithm)
        // Uses addArc(tangent1End:tangent2End:radius:) API to handle rounded corners automatically
        path.move(to: CGPoint(x: p1.x + (p3.x - p1.x) * (cornerRadius / rect.width),
                              y: p1.y + (p3.y - p1.y) * (cornerRadius / rect.height)))
        
        path.addArc(tangent1End: p1, tangent2End: p2, radius: cornerRadius)
        path.addArc(tangent1End: p2, tangent2End: p3, radius: cornerRadius)
        path.addArc(tangent1End: p3, tangent2End: p1, radius: cornerRadius)
        path.closeSubpath()
        return path
    }
}

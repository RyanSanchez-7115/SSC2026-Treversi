import SwiftUI

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
        path.move(to: CGPoint(x: p1.x + (p3.x - p1.x) * (cornerRadius / rect.width), y: p1.y + (p3.y - p1.y) * (cornerRadius / rect.height)))
        path.addArc(tangent1End: p1, tangent2End: p2, radius: cornerRadius)
        path.addArc(tangent1End: p2, tangent2End: p3, radius: cornerRadius)
        path.addArc(tangent1End: p3, tangent2End: p1, radius: cornerRadius)
        path.closeSubpath()
        return path
    }
}

struct TriangleView: View {
    let coordinate: TriangleCoordinate
    let piece: Piece                     // ← 改成 Piece
    let isLegalMove: Bool
    let isPreview: Bool
    let isPreviewFlipped: Bool
    let isHovered: Bool
    let side: CGFloat
    
    @State private var rotationAngle: Double = 0
    @State private var displayPiece: Piece
    @State private var isAnimating: Bool = false
    
    init(coordinate: TriangleCoordinate, piece: Piece, isLegalMove: Bool, isPreview: Bool, isPreviewFlipped: Bool, isHovered: Bool, side: CGFloat) {
        self.coordinate = coordinate
        self.piece = piece
        self.isLegalMove = isLegalMove
        self.isPreview = isPreview
        self.isPreviewFlipped = isPreviewFlipped
        self.isHovered = isHovered
        self.side = side
        _displayPiece = State(initialValue: piece)
    }
    
    var body: some View {
        ZStack {
            TriangleShape(isPointingUp: coordinate.isPointingUp, cornerRadius: 2)
                .fill(fillColor)
                .animation(.easeInOut(duration: 0.2), value: isLegalMove)
                .overlay(
                    TriangleShape(isPointingUp: coordinate.isPointingUp, cornerRadius: 2)
                        .stroke(borderColor, lineWidth: borderWidth)
                )
            // 特殊棋子的图标层（方向子 + 中立子）
            if displayPiece != .empty && displayPiece.owner == nil {
                let iconSize: CGFloat = side * 0.3
                let frameSize: CGFloat = side * 0.38
                let offsetY = side * 0.14

                if case .directional(let dir) = displayPiece {
                    // 方向子
                    Image(systemName: "arrow.right")
                        .font(.system(size: iconSize, weight: .bold))
                        .foregroundStyle(.purple.opacity(0.8))
                        .rotationEffect(.degrees(Double(dir) * 60))
                        .frame(width: frameSize, height: frameSize)
                        .offset(x: 0, y: offsetY)
                } else if case .neutral = displayPiece {
                    // 中立子
                    Image(systemName: "asterisk")
                        .font(.system(size: side * 0.3, weight: .bold))
                        .foregroundStyle(.orange.opacity(0.85))
                        .rotationEffect(.degrees(30))
                        .frame(width: frameSize, height: frameSize)
                        .offset(x: 0, y: offsetY)
                }
            }
        }
        .frame(width: side, height: side * sqrt(3)/2)
        .scaleEffect(isPreview ? 0.85 : 1.0)
        .rotation3DEffect(
            .degrees(rotationAngle),
            axis: (x: 0, y: 1, z: 0),
            perspective: 0.3
        )
        .onChange(of: piece) { newPiece in
            guard displayPiece != newPiece else { return }
            performFlipAnimation(to: newPiece)
        }
        .onAppear {
            if displayPiece != piece {
                displayPiece = piece
            }
        }
    }
    
    private func performFlipAnimation(to newPiece: Piece) {
        guard !isAnimating else { return }
        isAnimating = true
        let duration = 0.27
        
        withAnimation(.easeIn(duration: duration)) {
            rotationAngle = 90
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.displayPiece = newPiece
            self.rotationAngle = -90
            withAnimation(.easeOut(duration: duration)) {
                self.rotationAngle = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                self.isAnimating = false
            }
        }
    }
    
    private var fillColor: Color {
        if isPreview {
            return Color.green.opacity(0.4)
        } else if isPreviewFlipped {
            return Color.green.opacity(0.3)
        } else if isHovered {
            return Color.green.opacity(0.3)
        } else {
            switch displayPiece {
            case .black: return .black
            case .white: return .white
            case .neutral: return .yellow.opacity(0.4)
            case .directional: return .purple.opacity(0.4)
            case .empty: return isLegalMove ? Color.green.opacity(0.3) : Color(.systemGray3)
            }
        }
    }
    
    private var borderColor: Color {
        if isLegalMove && displayPiece == .empty && !isPreview && !isPreviewFlipped {
            return .green
        } else {
            switch displayPiece {
            case .neutral: return displayPiece.borderColor()
            case .directional: return displayPiece.borderColor()
            default: return displayPiece.borderColor()
            }
        }
    }
    
    private var borderWidth: CGFloat {
        if isLegalMove && displayPiece == .empty && !isPreview && !isPreviewFlipped {
            return 2
        } else {
            return displayPiece.borderWidth()
        }
    }
}

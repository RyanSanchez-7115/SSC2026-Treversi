import SwiftUI

// 圆角三角形形状
struct TriangleShape: Shape {
    let isPointingUp: Bool
    var cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let p1, p2, p3: CGPoint
        if isPointingUp {
            p1 = CGPoint(x: rect.midX, y: rect.minY) // Top
            p2 = CGPoint(x: rect.minX, y: rect.maxY) // Bottom-left
            p3 = CGPoint(x: rect.maxX, y: rect.maxY) // Bottom-right
        } else {
            p1 = CGPoint(x: rect.midX, y: rect.maxY) // Bottom
            p2 = CGPoint(x: rect.maxX, y: rect.minY) // Top-right
            p3 = CGPoint(x: rect.minX, y: rect.minY) // Top-left
        }

        path.move(to: CGPoint(x: p1.x + (p3.x - p1.x) * (cornerRadius / rect.width), y: p1.y + (p3.y - p1.y) * (cornerRadius / rect.height)))
        
        path.addArc(tangent1End: p1, tangent2End: p2, radius: cornerRadius)
        path.addArc(tangent1End: p2, tangent2End: p3, radius: cornerRadius)
        path.addArc(tangent1End: p3, tangent2End: p1, radius: cornerRadius)
        path.closeSubpath()
        
        return path
    }
}

// 三角形视图
struct TriangleView: View {
    let coordinate: TriangleCoordinate
    let player: Player
    let isLegalMove: Bool
    let isPreview: Bool
    let isPreviewFlipped: Bool
    let isHovered: Bool
    let side: CGFloat
    
    // 旋转角度
    @State private var rotationAngle: Double = 0
    // 用于显示的 Player 状态，分离数据源 player 和显示层逻辑
    @State private var displayPlayer: Player
    
    // 标记是否正在执行翻转动画，防止冲突
    @State private var isAnimating: Bool = false
    
    init(coordinate: TriangleCoordinate, player: Player, isLegalMove: Bool, isPreview: Bool, isPreviewFlipped: Bool, isHovered: Bool, side: CGFloat) {
        self.coordinate = coordinate
        self.player = player
        self.isLegalMove = isLegalMove
        self.isPreview = isPreview
        self.isPreviewFlipped = isPreviewFlipped
        self.isHovered = isHovered
        self.side = side
        // 初始化时显示状态等于传入状态
        _displayPlayer = State(initialValue: player)
    }
    
    var body: some View {
        TriangleShape(isPointingUp: coordinate.isPointingUp, cornerRadius: 2)
            .fill(fillColor)
            .animation(.easeInOut(duration: 0.2), value: isLegalMove)
            .overlay(
                TriangleShape(isPointingUp: coordinate.isPointingUp, cornerRadius: 2)
                    .stroke(borderColor, lineWidth: 2)
            )
            .frame(width: side, height: side * sqrt(3)/2)
            .scaleEffect(isPreview ? 0.85 : 1.0)
            .rotation3DEffect(
                .degrees(rotationAngle),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.3
            )
            .onChange(of: player) { newPlayer in
                // 如果是从空变为有棋子，或者两个不同颜色的棋子切换（翻转）
                // 且不是初始化状态，则执行动画
                if displayPlayer != newPlayer {
                    performFlipAnimation(to: newPlayer)
                }
            }
            .onAppear {
                // 确保视图出现时与数据一致
                if displayPlayer != player {
                    displayPlayer = player
                }
            }
    }
    
    private func performFlipAnimation(to newPlayer: Player) {
        guard !isAnimating else { return }
        isAnimating = true
        
        let duration = 0.27 // 单程时间，稍微增加一点让动画更清晰
        
        // 第一阶段：翻转 90 度 (旧颜色 -> 侧面)
        // 使用 .easeIn，开始慢，结束快，模拟用力翻起的动作
        withAnimation(.easeIn(duration: duration)) {
            rotationAngle = 90
        }
        
        // 动画中点：切换颜色，重置角度
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.displayPlayer = newPlayer
            self.rotationAngle = -90 // 瞬间切换到反面
            
            // 第二阶段：翻转回 0 度 (侧面 -> 新颜色)
            // 使用 .easeOut，开始快，结束慢，模拟惯性落下的动作
            withAnimation(.easeOut(duration: duration)) {
                self.rotationAngle = 0
            }
            
            // 动画结束清理
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                self.isAnimating = false
            }
        }
    }
    
    private var fillColor: Color {
        if isPreview {
            return Color.green.opacity(0.3)
        } else if isPreviewFlipped {
            return Color.green.opacity(0.3)
        } else if isHovered {
            return Color.green.opacity(0.3)
        } else {
            switch displayPlayer {
            case .black:
                return .black
            case .white:
                return .white
            case .empty:
                return isLegalMove ? Color.green.opacity(0.3) : Color(.systemGray3)
            }
        }
    }

    private var borderColor: Color {
        if isLegalMove && displayPlayer == .empty && !isPreview && !isPreviewFlipped {
            return .green
        } else {
            return .gray.opacity(0.3)
        }
    }
}

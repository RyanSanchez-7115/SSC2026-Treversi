import SwiftUI

struct DemoTriangleView: View {
    let coordinate: TriangleCoordinate
    let targetColor: Color?   // nil 表示隐藏
    let side: CGFloat
    
    @State private var rotationAngle: Double = 0
    @State private var currentColor: Color? = nil
    @State private var isAnimating = false

    var body: some View {
        TriangleShape(isPointingUp: coordinate.isPointingUp, cornerRadius: 2)
            .fill(currentColor ?? Color.clear)
            .overlay(
                TriangleShape(isPointingUp: coordinate.isPointingUp, cornerRadius: 0)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
            )
            .frame(width: side, height: side * sqrt(3)/2)
            .rotation3DEffect(
                .degrees(rotationAngle),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.3
            )
            .onChange(of: targetColor) { newColor in
                guard !isAnimating else { return }

                if newColor != nil && currentColor == nil {
                    isAnimating = true
                    let duration = 0.3
                    
                    // 第一段动画：翻转到90度 (加速，模拟用力翻起)
                    withAnimation(.easeIn(duration: duration)) {
                        rotationAngle = 90
                    }
                    
                    // 在第一段动画结束后，改变颜色并开始第二段动画
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        self.currentColor = newColor
                        // 瞬间切换到背面
                        self.rotationAngle = -90
                        
                        // 第二段动画：从-90度翻转到0度 (减速，模拟惯性落下)
                        withAnimation(.easeOut(duration: duration)) {
                            self.rotationAngle = 0
                        }
                    }
                    
                    // 整个动画结束后，重置状态
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration * 2) {
                        self.isAnimating = false
                    }
                    
                } else if newColor == nil {
                    // 隐藏（无需动画）
                    currentColor = nil
                    rotationAngle = 0
                }
            }
    }
}

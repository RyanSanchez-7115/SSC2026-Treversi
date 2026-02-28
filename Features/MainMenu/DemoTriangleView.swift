import SwiftUI

/**
 * @struct DemoTriangleView
 * @brief A single triangle cell view for the main menu demo board.
 * @details Responsible for rendering the shape and color of a single triangle, as well as its flip animation. When `targetColor` changes, it triggers a 3D flip effect to update the color.
 */
struct DemoTriangleView: View {
    /// The coordinate of this cell in the grid.
    let coordinate: TriangleCoordinate
    /// The target color. If `nil`, the cell becomes transparent (hidden).
    let targetColor: Color?
    /// The side length of the triangle.
    let side: CGFloat
    
    /// Controls the angle of the flip animation.
    @State private var rotationAngle: Double = 0
    /// The currently displayed color, used for state management during the animation.
    @State private var currentColor: Color? = nil
    /// A flag to indicate if an animation is in progress, to prevent repeated triggers.
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
                
                // When appearing (from nil to a color), perform the flip animation.
                if newColor != nil && currentColor == nil {
                    isAnimating = true
                    let duration = 0.3
                    
                    // First stage of animation: flip from 0 to 90 degrees (disappear).
                    withAnimation(.easeIn(duration: duration)) {
                        rotationAngle = 90
                    }
                    
                    // Mid-animation: update the color and reset the angle to the other side.
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        self.currentColor = newColor
                        self.rotationAngle = -90 // Instantly switch to the back face.
                        
                        // Second stage of animation: flip from -90 back to 0 degrees (appear).
                        withAnimation(.easeOut(duration: duration)) {
                            self.rotationAngle = 0
                        }
                    }
                    
                    // After the entire animation is complete, reset the animation flag.
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration * 2) {
                        self.isAnimating = false
                    }
                    
                } else if newColor == nil {
                    // When hiding, reset the state directly.
                    currentColor = nil
                    rotationAngle = 0
                }
            }
    }
}

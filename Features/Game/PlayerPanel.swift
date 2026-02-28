import SwiftUI

/**
 * @struct PlayerPanel
 * @brief Player information and operation panel view.
 * @details Displays the current player's piece count, turn indicator, and provides control buttons for undo, restart, and back.
 */
struct PlayerPanel: View {
    
    // MARK: - Configuration Properties
    
    let player: Player
    let opponent: Player
    
    /// Indicates whether it is this player's turn to move (highlights background)
    let isCurrentPlayer: Bool
    
    let counts: (black: Int, white: Int)
    let enableUndo: Bool
    
    /// Whether the panel is located at the top of the screen (top panel needs rotation to face the opponent)
    let isTop: Bool
    
    let onUndo: () -> Void
    let onRestart: () -> Void
    let onBack: () -> Void
    
    // MARK: - Computed Logic
    
    /**
     * @brief Get the piece count for the player represented by this panel.
     */
    private var myCount: Int {
        player == .black ? counts.black : counts.white
    }
    
    /**
     * @brief Get the piece count for the opponent.
     */
    private var opponentCount: Int {
        opponent == .black ? counts.black : counts.white
    }
    
    /**
     * @brief Determine background color based on whose turn it is.
     */
    private var backgroundColor: Color {
        isCurrentPlayer ? Color.cyan.opacity(0.3) : Color(.secondarySystemBackground)
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 8) {
            // Score display area
            HStack {
                Spacer()
                
                // Own score
                HStack(spacing: 4) {
                    TriangleIcon(player: player)
                        .frame(width: 30, height: 30)
                    Text("\(myCount)")
                        .font(.title2)
                        .bold()
                }
                
                Divider()
                    .frame(height: 30)
                
                // Opponent score
                HStack(spacing: 4) {
                    Text("\(opponentCount)")
                        .font(.title2)
                        .bold()
                    TriangleIcon(player: opponent)
                        .frame(width: 30, height: 30)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            // Button operation area
            HStack(spacing: 20) {
                if enableUndo {
                    Button(action: onUndo) {
                        Label("Undo", systemImage: "arrow.uturn.backward")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PanelButtonStyle())
                }
                
                Button(action: onRestart) {
                    Label("Restart", systemImage: "arrow.counterclockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PanelButtonStyle())
                
                Button(action: onBack) {
                    Label("Back", systemImage: "xmark") // Simplified text to fit layout
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PanelButtonStyle())
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundColor)
        )
        .padding(.horizontal, 30)
        // Rotate 180 degrees if it's the top panel, for the opponent's view in local multiplayer
        .rotationEffect(isTop ? .degrees(180) : .zero)
    }
}

// MARK: - Helper Views & Styles

/**
 * @struct TriangleIcon
 * @brief Simple triangle icon component for displaying player color.
 */
struct TriangleIcon: View {
    let player: Player
    
    var body: some View {
        TriangleShape(isPointingUp: true, cornerRadius: 2)
            .fill(player == .black ? Color.black : Color.white)
            .overlay(
                TriangleShape(isPointingUp: true, cornerRadius: 2)
                    .stroke(Color.gray, lineWidth: 1)
            )
    }
}

/**
 * @struct PanelButtonStyle
 * @brief Unified style for panel buttons.
 */
struct PanelButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 8)
            .background(Color(.blue).opacity(configuration.isPressed ? 0.2 : 0.1))
            .cornerRadius(8)
            .foregroundColor(.blue)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

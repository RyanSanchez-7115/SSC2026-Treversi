import SwiftUI

struct PlayerPanel: View {
    let player: Player
    let opponent: Player
    let isCurrentPlayer: Bool
    let counts: (black: Int, white: Int)
    let enableUndo: Bool
    let isTop: Bool
    let onUndo: () -> Void
    let onRestart: () -> Void
    let onBack: () -> Void
    
    private var myCount: Int {
        player == .black ? counts.black : counts.white
    }
    
    private var opponentCount: Int {
        opponent == .black ? counts.black : counts.white
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Spacer()
                HStack(spacing: 4) {
                    TriangleIcon(player: player)
                        .frame(width: 30, height: 30)
                    Text("\(myCount)")
                        .font(.title2)
                        .bold()
                }
                 
                Divider()
                    .frame(height: 30)

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
                    Label("Back to Setting", systemImage: "xmark")
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
        .rotationEffect(isTop ? .degrees(180) : .zero)
    }
    
    private var backgroundColor: Color {
            isCurrentPlayer ? Color.cyan.opacity(0.3) : Color(.secondarySystemBackground)
        }

}

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


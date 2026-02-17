import SwiftUI

@main
struct TreversiApp: App {
    var body: some Scene {
        WindowGroup {
            GameView(
                gameState: GameState(geometry: HexagonBoard(radius: 3)),
                geometry: HexagonBoard(radius: 3)
            )
        }
    }
}

import SwiftUI

@main
struct TreversiApp: App {
    init(){
        HexagonBoard(radius: 3).testGeneration(radius: 3) // 在应用启动时测试生成函数
    }
    var body: some Scene {
        WindowGroup {
            GameView(
                gameState: GameState(geometry: HexagonBoard(radius: 3)),
                geometry: HexagonBoard(radius: 3)
            )
        }
    }
}

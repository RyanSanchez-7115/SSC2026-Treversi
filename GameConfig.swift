import SwiftUI

struct GameConfig {
    var boardType: BoardType = .hexagon
    var radius: Int = 3
    var layoutIndex: Int = 0
    var showLegalMoves: Bool = true
    var showPreview: Bool = true
    var enableUndo: Bool = true
}

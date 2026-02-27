struct GameConfig {
    //棋盘设置项
    var boardType: BoardType = .hexagon
    var radius: Int = 3
    var layoutIndex: Int = 0
    // 功能设置项
    var showLegalMoves: Bool = true
    var showPreview: Bool = true
    var enableUndo: Bool = false
    //特殊棋子设置项
    var enableNeutral: Bool = true
    var enableDirectional: Bool = true
}

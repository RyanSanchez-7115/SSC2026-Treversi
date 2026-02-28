/**
 * @struct GameConfig
 * @brief Configuration for the game, including board type, radius, layout, and feature toggles.
 */
struct GameConfig {
    /// Board type
    var boardType: BoardType = .hexagon
    
    /// Board radius
    var radius: Int = 3
    
    /// Layout index
    var layoutIndex: Int = 0
    
    /// Show legal moves
    var showLegalMoves: Bool = true
    
    /// Show move preview
    var showPreview: Bool = true
    
    /// Enable undo functionality
    var enableUndo: Bool = false
    
    /// Enable neutral pieces
    var enableNeutral: Bool = true
    
    /// Enable directional pieces
    var enableDirectional: Bool = true
}

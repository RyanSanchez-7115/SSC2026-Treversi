import Foundation

enum Piece: Hashable, Equatable{
    case empty
    case black
    case white
    case neutral                  // 中立子
    case directional(Direction)   // 方向子（带固定方向）
    
    var player: Player? {
        switch self {
        case .black: return .black
        case .white: return .white
        default: return nil         // 中立和方向都不属于玩家
        }
    }
    
    var isCapturable: Bool {        // 新增：是否可被翻转/占领
        switch self {
        case .black, .white: return true
        default: return false
        }
    }
    
    var isNeutralLike: Bool {       // 中立或方向子，都不可翻转
        !isCapturable
    }
    
    // 方向子专用：检查是否匹配搜索方向
    func matchesDirection(_ dirIndex: Int) -> Bool {
        if case .directional(let dir) = self {
            return dir.rawValue == dirIndex
        }
        return false
    }
}

// NEW: 6方向枚举，对应GameState.directions索引
enum Direction: Int, CaseIterable {
    case left = 0, right = 1, northwest = 2, southwest = 3, northeast = 4, southeast = 5
    
    // UI旋转角度 (hex grid)
    var rotationDegrees: Double {
        switch self {
        case .left: return 180
        case .right: return 0
        case .northwest: return 240
        case .southwest: return 300
        case .northeast: return 120
        case .southeast: return 60
        }
    }
}

// 原Player保留（UI/当前玩家用）
enum Player {
    case black, white
    
    var opponent: Player {
        self == .black ? .white : .black
    }
    
    var piece: Piece { self == .black ? .black : .white }
}

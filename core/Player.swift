import SwiftUI

enum Piece: Hashable, Equatable {
    case empty
    case black
    case white
    case neutral                  // 中立子：不可翻转，可穿越
    case directional(direction: Int)  // 方向子：0~5 对应6个方向

    var owner: Player? {
        switch self {
        case .black:   return .black
        case .white:   return .white
        default:       return nil
        }
    }

    var isFlippable: Bool {
        switch self {
        case .black, .white: return true
        default:             return false
        }
    }
    
    func allowsTraversal(fromSearchDirIndex dirIndex: Int) -> Bool {
            switch self {
            case .neutral:
                return true                     // 中立子总是允许穿越
            case .directional(let restrictedDir):
                return restrictedDir == dirIndex  // 只允许匹配的方向穿越
            default:
                return false                    // 普通棋子不“穿越”，而是被翻转或挡住
            }
        }

    var directionalDirection: Int? {
        if case .directional(let dir) = self { return dir }
        return nil
    }

    func color(fillOpacity: Double = 1.0) -> Color {
        switch self {
        case .empty:      return .clear
        case .black:      return .black
        case .white:      return .white
        case .neutral:    return .orange.opacity(0.4 * fillOpacity)
        case .directional:
            return .purple.opacity(0.4 * fillOpacity)
        }
    }

    func borderColor() -> Color {
        switch self {
        case .neutral:    return .orange.opacity(0.6)
        case .directional: return .purple.opacity(0.6)
        default:          return .gray.opacity(0.3)
        }
    }

    func borderWidth() -> CGFloat {
        switch self {
        case .neutral, .directional: return 3
        default:                     return 2
        }
    }

    static func piece(for player: Player) -> Piece {
        player == .black ? .black : .white
    }
}

extension Piece {
    var opponentPiece: Piece? {
        switch self {
        case .black: return .white
        case .white: return .black
        default:     return nil
        }
    }
    var isAnimatable: Bool {
            switch self {
            case .empty: return false
            default: return true  // 黑白 + neutral + directional 都动画
            }
        }
}
// 原Player保留（UI/当前玩家用）
enum Player {
    case black
    case white

    var opponent: Player {
        self == .black ? .white : .black
    }

    var name: String {
        self == .black ? "Black" : "White"
    }
}

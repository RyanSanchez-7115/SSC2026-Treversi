import SwiftUI

/**
 * @enum Player
 * @brief Represents the two players in the game.
 */
enum Player {
    /// Black player
    case black
    /// White player
    case white

    /// Returns the opponent player.
    var opponent: Player {
        self == .black ? .white : .black
    }

    /// Returns the display name of the player.
    var name: String {
        self == .black ? "Black" : "White"
    }
}

/**
 * @enum Piece
 * @brief Represents a piece on the game board or an empty spot.
 */
enum Piece: Hashable, Equatable {
    /// Empty spot
    case empty
    /// Black piece
    case black
    /// White piece
    case white
    /// Neutral piece: cannot be flipped, can be traversed by any search ray
    case neutral
    /**
     * @brief Directional piece: cannot be flipped, allows traversal only in a specific direction.
     * @param direction Integer representing one of the 6 hexagonal directions (0-5).
     */
    case directional(direction: Int)

    // MARK: - Logic Properties & Methods

    /**
     * @brief The player who owns this piece, if applicable.
     */
    var owner: Player? {
        switch self {
        case .black:   return .black
        case .white:   return .white
        default:       return nil
        }
    }

    /**
     * @brief Returns the corresponding piece type for the opponent, or nil.
     */
    var opponentPiece: Piece? {
        switch self {
        case .black: return .white
        case .white: return .black
        default:     return nil
        }
    }

    /**
     * @brief Determines if the piece can be flipped by an opponent's move.
     */
    var isFlippable: Bool {
        switch self {
        case .black, .white: return true
        default:             return false
        }
    }

    /**
     * @brief Determines if this piece type should trigger animation effects.
     */
    var isAnimatable: Bool {
        switch self {
        case .empty: return false
        default: return true
        }
    }

    /**
     * @brief Extracts the direction value if this is a directional piece.
     */
    var directionalDirection: Int? {
        if case .directional(let dir) = self { return dir }
        return nil
    }

    /**
     * @brief Determines if a search ray can pass through this piece.
     * @param dirIndex The index of the search direction (0-5).
     * @return True if traversal is allowed.
     */
    func allowsTraversal(fromSearchDirIndex dirIndex: Int) -> Bool {
        switch self {
        case .neutral:
            return true
        case .directional(let restrictedDir):
            return restrictedDir == dirIndex
        default:
            return false
        }
    }

    /**
     * @brief Creates a piece corresponding to a specific player.
     * @param player The player to create the piece for.
     */
    static func piece(for player: Player) -> Piece {
        player == .black ? .black : .white
    }
}

// MARK: - UI Configuration
extension Piece {
    /**
     * @brief Returns the fill color for the piece UI.
     * @param fillOpacity Opacity multiplier for the color.
     */
    func color(fillOpacity: Double = 1.0) -> Color {
        switch self {
        case .empty:       return .clear
        case .black:       return .black
        case .white:       return .white
        case .neutral:     return .orange.opacity(0.4 * fillOpacity)
        case .directional: return .purple.opacity(0.4 * fillOpacity)
        }
    }

    /**
     * @brief Returns the border color for the piece UI.
     */
    func borderColor() -> Color {
        switch self {
        case .neutral:     return .orange.opacity(0.6)
        case .directional: return .purple.opacity(0.6)
        default:           return .gray.opacity(0.3)
        }
    }

    /**
     * @brief Returns the border width for the piece UI.
     */
    func borderWidth() -> CGFloat {
        switch self {
        case .neutral, .directional: return 3
        default:                     return 2
        }
    }
}

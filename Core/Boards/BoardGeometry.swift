import Foundation

/// @brief Board geometry protocol defining basic properties
protocol BoardGeometry {
    /// @brief All valid coordinates
    var allCoordinates: Set<TriangleCoordinate> { get }
    /// @brief Initial occupation mapping to piece types
    var initialOccupation: [TriangleCoordinate: Piece] { get }
    /// @brief Display name
    var displayName: String { get }
    /// @brief Description text
    var description: String { get }
}

/// @brief Board type enumeration
enum BoardType: String, CaseIterable, Identifiable {
    case hexagon
    case diamond
    case triangle
    
    /// @brief Unique identifier
    var id: String { rawValue }
    
    /// @brief Create geometry for a given radius
    /// @param radius Radius
    /// @return Board geometry instance
    func geometry(radius: Int) -> any BoardGeometry {
        switch self {
        case .hexagon:  return HexagonBoard(radius: radius)
        case .diamond:  return DiamondBoard(radius: radius)
        case .triangle: return TriangleBoard(radius: radius)
        }
    }
    
    /// @brief Display name for the type
    var displayName: String {
        switch self {
        case .hexagon:  return "Classic Hexagon"
        case .diamond:  return "Dimond Field"
        case .triangle: return "Trianguland"
        }
    }
    
    /// @brief Available layout names for this type
    var layoutNames: [String] {
        switch self {
        case .hexagon:  return HexagonBoard.layoutNames
        case .diamond:  return DiamondBoard.layoutNames
        case .triangle: return TriangleBoard.layoutNames
        }
    }
    
    /// @brief Get layout by index
    /// @param index Layout index
    /// @return Mapping from coordinate to piece; empty if out of range
    func getLayout(at index: Int) -> [TriangleCoordinate: Piece] {
        switch self {
        case .hexagon:
            guard index < HexagonBoard.layouts.count else { return [:] }
            return HexagonBoard.layouts[index]
        case .diamond:
            guard index < DiamondBoard.layouts.count else { return [:] }
            return DiamondBoard.layouts[index]
        case .triangle:
            guard index < TriangleBoard.layouts.count else { return [:] }
            return TriangleBoard.layouts[index]
        }
    }
}

extension BoardGeometry {
    /// @brief Default display name
    var displayName: String { "Unnamed Board" }
    /// @brief Default description
    var description: String { "" }
    
    /// @brief Get adjacent triangle coordinates for a coordinate
    /// @param coordinate Target coordinate
    /// @return Set of adjacent coordinates
    func neighbors(of coordinate: TriangleCoordinate) -> Set<TriangleCoordinate> {
        let (q, r, isUp) = (coordinate.q, coordinate.r, coordinate.isPointingUp)
        if isUp {
            return [
                TriangleCoordinate(q: q, r: r - 1, isPointingUp: false),
                TriangleCoordinate(q: q - 1, r: r, isPointingUp: false),
                TriangleCoordinate(q: q + 1, r: r, isPointingUp: false)
            ]
        } else {
            return [
                TriangleCoordinate(q: q, r: r + 1, isPointingUp: true),
                TriangleCoordinate(q: q - 1, r: r, isPointingUp: true),
                TriangleCoordinate(q: q + 1, r: r, isPointingUp: true)
            ]
        }
    }
}

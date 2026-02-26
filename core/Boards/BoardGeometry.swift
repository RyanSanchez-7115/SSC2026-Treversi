import Foundation

protocol BoardGeometry {
    var allCoordinates: Set<TriangleCoordinate> { get }
    var initialOccupation: [TriangleCoordinate: Piece] { get }   // 改成 Piece
    var displayName: String { get }
    var description: String { get }
}

enum BoardType: String, CaseIterable, Identifiable {
    case hexagon
    case diamond
    case triangle
    
    var id: String { self.rawValue }
    
    func geometry(radius: Int) -> any BoardGeometry {
        switch self {
        case .hexagon:  return HexagonBoard(radius: radius)
        case .diamond:  return DiamondBoard(radius: radius)
        case .triangle: return TriangleBoard(radius: radius)
        }
    }
    
    var displayName: String {
        switch self {
        case .hexagon:  return "Classic Hexagon"
        case .diamond:  return "Dimond Field"
        case .triangle: return "Trianguland"
        }
    }
    
    var layoutNames: [String] {
        switch self {
        case .hexagon:  return HexagonBoard.layoutNames
        case .diamond:  return DiamondBoard.layoutNames
        case .triangle: return TriangleBoard.layoutNames
        }
    }
    
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
    var displayName: String { "Unnamed Board" }
    var description: String { "" }
    
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

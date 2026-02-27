import Foundation

struct DiamondBoard: BoardGeometry {
    let radius: Int
    var displayName: String { "Dimond Field" }
    var description: String { "菱形的对称战场，两种发展方向" }
    
    var allCoordinates: Set<TriangleCoordinate> {
        var coords = Set<TriangleCoordinate>()
        for r in -radius...(radius - 1) {
            let qStart = -(radius * 2 - 1) + r
            let qEnd = qStart + radius * 4 - 1
            for q in qStart...qEnd {
                let s = -q - r
                coords.insert(TriangleCoordinate(q: q, r: r, isPointingUp: s % 2 == 0 ? false : true))
            }
        }
        return coords
    }
    
    var initialOccupation: [TriangleCoordinate: Piece] {
        var occupation: [TriangleCoordinate: Piece] = [:]
        occupation[TriangleCoordinate(q: -1, r: -1, isPointingUp: false)] = .black
        occupation[TriangleCoordinate(q: 0, r: 0, isPointingUp: false)] = .black
        occupation[TriangleCoordinate(q: 1, r: -1, isPointingUp: false)] = .black
        occupation[TriangleCoordinate(q: -1, r: 0, isPointingUp: true)] = .white
        occupation[TriangleCoordinate(q: 1, r: 0, isPointingUp: true)] = .white
        occupation[TriangleCoordinate(q: 0, r: -1, isPointingUp: true)] = .white
        return occupation
    }
}

extension DiamondBoard {
    static let layouts: [[TriangleCoordinate: Piece]] = [
        // 0 Classic
        [
            TriangleCoordinate(q: -1, r: -1, isPointingUp: false): .black,
            TriangleCoordinate(q: -1, r: 0, isPointingUp: true): .black,
            TriangleCoordinate(q: 0, r: -1, isPointingUp: true): .white,
            TriangleCoordinate(q: 1, r: -1, isPointingUp: false): .white,
            TriangleCoordinate(q: 1, r: 0, isPointingUp: true): .white
        ],
        // 1 Irregular
        [
            TriangleCoordinate(q: 0, r: 0, isPointingUp: false): .black,
            TriangleCoordinate(q: 1, r: -1, isPointingUp: false): .black,
            TriangleCoordinate(q: 2, r: 0, isPointingUp: false): .black,
            TriangleCoordinate(q: -1, r: 0, isPointingUp: true): .white,
            TriangleCoordinate(q: 0, r: -1, isPointingUp: true): .white,
            TriangleCoordinate(q: -2, r: -1, isPointingUp: true): .white
        ],
        // 2 Aggressive
        [
            TriangleCoordinate(q: -1, r: -1, isPointingUp: false): .white,
            TriangleCoordinate(q: 1, r: -1, isPointingUp: false): .white,
            TriangleCoordinate(q: -2, r: 0, isPointingUp: false): .white,
            TriangleCoordinate(q: 0, r: -2, isPointingUp: false): .white,
            TriangleCoordinate(q: -1, r: 0, isPointingUp: true): .black
        ],
        // 3 Special
        [
            TriangleCoordinate(q: -1, r: -1, isPointingUp: false): .neutral,
            TriangleCoordinate(q: 0, r: 0, isPointingUp: false): .black,
            TriangleCoordinate(q: 1, r: 0, isPointingUp: true): .white,
            TriangleCoordinate(q: 0, r: -1, isPointingUp: true): .white,
            TriangleCoordinate(q: 2, r: -1, isPointingUp: true): .neutral,
            TriangleCoordinate(q: -2, r: 0, isPointingUp: false): .directional(direction: 0),
            TriangleCoordinate(q: 1, r: -2, isPointingUp: true): .directional(direction: 3)
        ]
    ]
    static let layoutNames: [String] = ["Classic", "Symmetrical", "Aggressive", "Special"]
}

extension DiamondBoard {
    func isCoordinate(_ coord: TriangleCoordinate, withinRadius radius: Int) -> Bool {
        let r = coord.r
        guard r >= -radius && r <= radius - 1 else { return false }
        let qStart = -(radius * 2 - 1) + r
        let qEnd = qStart + radius * 4 - 1
        return coord.q >= qStart && coord.q <= qEnd
    }
}

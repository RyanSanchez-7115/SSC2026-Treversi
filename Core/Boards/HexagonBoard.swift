import Foundation

struct HexagonBoard: BoardGeometry {
    let radius: Int
    var displayName: String { "Classic Hexagon" }
    var description: String { "完美对称的几何美感" }
    
    var allCoordinates: Set<TriangleCoordinate> {
        var coords = Set<TriangleCoordinate>()
        for r in 0...(radius - 1) {
            for q in -(radius*2 - 1 - r)...(radius*2 - 1 - r) {
                let s = -q - r
                coords.insert(TriangleCoordinate(q: q, r: r, isPointingUp: s % 2 == 0 ? false : true))
            }
        }
        for r in (-radius)...(-1) {
            for q in -(radius*2 + r)...(radius*2 + r) {
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

extension HexagonBoard {
    static let layouts: [[TriangleCoordinate: Piece]] = [
        // 0 Classic
        [
            TriangleCoordinate(q: 0, r: 0, isPointingUp: false): .directional(direction: 3),
            TriangleCoordinate(q: 0, r: -1, isPointingUp: true): .black,
            TriangleCoordinate(q: 1, r: 0, isPointingUp: true): .white,
            TriangleCoordinate(q: -1, r: 0, isPointingUp: true): .white,
            TriangleCoordinate(q: -1, r: -1, isPointingUp: false): .white,
            TriangleCoordinate(q: 1, r: -1, isPointingUp: false): .white
        ],
        // 1 Symmetrical
        [
            TriangleCoordinate(q: -1, r: -1, isPointingUp: false): .black,
            TriangleCoordinate(q: 0, r: 0, isPointingUp: false): .black,
            TriangleCoordinate(q: 1, r: -1, isPointingUp: false): .black,
            TriangleCoordinate(q: -1, r: 0, isPointingUp: true): .white,
            TriangleCoordinate(q: 1, r: 0, isPointingUp: true): .white,
            TriangleCoordinate(q: 0, r: -1, isPointingUp: true): .white
        ],
        // 2 Line
        [
            TriangleCoordinate(q: 1, r: 0, isPointingUp: true): .black,
            TriangleCoordinate(q: -1, r: -1, isPointingUp: false): .black,
            TriangleCoordinate(q: 0, r: 1, isPointingUp: true): .white,
            TriangleCoordinate(q: -1, r: 0, isPointingUp: true): .white,
            TriangleCoordinate(q: -2, r: -1, isPointingUp: true): .white
        ],
        // 3 Special（中立子 + 方向子）
        [
            TriangleCoordinate(q: 0, r: 0, isPointingUp: false): .black,
            TriangleCoordinate(q: 0, r: -1, isPointingUp: true): .black,
            TriangleCoordinate(q: 1, r: 0, isPointingUp: true): .white,
            TriangleCoordinate(q: -1, r: 0, isPointingUp: true): .white,
            TriangleCoordinate(q: -1, r: -1, isPointingUp: false): .white,
            TriangleCoordinate(q: 1, r: -1, isPointingUp: false): .white,
            TriangleCoordinate(q: 2, r: -1, isPointingUp: true): .neutral,
            TriangleCoordinate(q: -2, r: -1, isPointingUp: true): .directional(direction: 1),
            TriangleCoordinate(q: 0, r: 1, isPointingUp: true): .directional(direction: 4)
        ]
    ]
    
    static let layoutNames: [String] = ["Classic", "Symmetrical", "Line", "Special"]
}

extension HexagonBoard {
    func isCoordinate(_ coord: TriangleCoordinate, withinRadius radius: Int) -> Bool {
        let r = coord.r
        let q = coord.q
        if r >= 0 && r < radius {
            let minQ = -(radius * 2 - 1 - r)
            let maxQ = radius * 2 - 1 - r
            return q >= minQ && q <= maxQ
        } else if r < 0 && r >= -radius {
            let minQ = -(radius * 2 + r)
            let maxQ = radius * 2 + r
            return q >= minQ && q <= maxQ
        }
        return false
    }
}

import Foundation

struct TriangleBoard: BoardGeometry {
    let radius: Int
    var displayName: String { "Trianguland" }
    var description: String { "Triangular chessboard, corners are key" }
    
    var allCoordinates: Set<TriangleCoordinate> {
        var coords = Set<TriangleCoordinate>()
        for r in -radius...radius*2 - 1 {
            let qStart = -radius*2 + 1 + r
            let qEnd = radius*2 - 1 - r
            for q in qStart...qEnd {
                let s = -q - r
                coords.insert(TriangleCoordinate(q: q, r: r, isPointingUp: s % 2 == 0 ? false : true))
            }
        }
        return coords
    }
    
    var initialOccupation: [TriangleCoordinate: Piece] {
        var occupation: [TriangleCoordinate: Piece] = [:]
        occupation[TriangleCoordinate(q: -1, r: -1, isPointingUp: true)] = .black
        occupation[TriangleCoordinate(q: 0, r: 0, isPointingUp: false)] = .black
        occupation[TriangleCoordinate(q: 1, r: -1, isPointingUp: false)] = .black
        occupation[TriangleCoordinate(q: -1, r: 0, isPointingUp: true)] = .white
        occupation[TriangleCoordinate(q: 1, r: 0, isPointingUp: true)] = .white
        occupation[TriangleCoordinate(q: 0, r: -1, isPointingUp: true)] = .white
        return occupation
    }
}

extension TriangleBoard {
    static let layouts: [[TriangleCoordinate: Piece]] = [
        // 0 Balanced
        [
            //black
            TriangleCoordinate(q: 0, r: 0, isPointingUp: false): .black,
            TriangleCoordinate(q: 1, r: -1, isPointingUp: false): .black,
            TriangleCoordinate(q: -1, r: -1, isPointingUp: false): .black,
            TriangleCoordinate(q: 0, r: -1, isPointingUp: true): .black,
            //white
            TriangleCoordinate(q: 0, r: 1, isPointingUp: true): .white,
            TriangleCoordinate(q: 1, r: 0, isPointingUp: true): .white,
            TriangleCoordinate(q: -1, r: 0, isPointingUp: true): .white,
            //special pieces
            TriangleCoordinate(q: 1, r: 1, isPointingUp: false): .neutral,
            TriangleCoordinate(q: -1, r: 1, isPointingUp: true): .directional(direction: 1)
        ],
        // 1 Aggressive
        [
            //black
            TriangleCoordinate(q: -2, r: 0, isPointingUp: false): .black,
            TriangleCoordinate(q: -1, r: -1, isPointingUp: false): .black,
            TriangleCoordinate(q: -1, r: 0, isPointingUp: true): .black,
            //white
            TriangleCoordinate(q: 0, r: -1, isPointingUp: true): .white,
            TriangleCoordinate(q: 1, r: 0, isPointingUp: true): .white,
            TriangleCoordinate(q: 0, r: 1, isPointingUp: true): .white,
            TriangleCoordinate(q: 0, r: 0, isPointingUp: false): .white,
            //special pieces
            TriangleCoordinate(q: -2, r: 1, isPointingUp: true): .neutral,
            TriangleCoordinate(q: 2, r: -1, isPointingUp: true): .directional(direction: 3)
        ],
        // 2 Defence
        [
            //black
            TriangleCoordinate(q: 0, r: 0, isPointingUp: false): .black,
            TriangleCoordinate(q: 1, r: 0, isPointingUp: true): .black,
            TriangleCoordinate(q: -1, r: 0, isPointingUp: true): .black,
            TriangleCoordinate(q: 0, r: -1, isPointingUp: true): .black,
            //white
            TriangleCoordinate(q: 0, r: 1, isPointingUp: true): .white,
            TriangleCoordinate(q: 1, r: -1, isPointingUp: false): .white,
            TriangleCoordinate(q: -1, r: -1, isPointingUp: false): .white,
            //special pieces
            TriangleCoordinate(q: 0, r: 2, isPointingUp: false): .directional(direction: 4),
            TriangleCoordinate(q: 0, r: -2, isPointingUp: false): .neutral
        ],
        // 3 Special
        [
            //black
            TriangleCoordinate(q: 0, r: 0, isPointingUp: false): .black,
            TriangleCoordinate(q: 1, r: -1, isPointingUp: false): .black,
            TriangleCoordinate(q: -1, r: 0, isPointingUp: true): .black,
            //white
            TriangleCoordinate(q: 0, r: 1, isPointingUp: true): .white,
            TriangleCoordinate(q: 1, r: 0, isPointingUp: true): .white,
            TriangleCoordinate(q: -1, r: -1, isPointingUp: false): .white,
            //special pieces
            TriangleCoordinate(q: 1, r: 1, isPointingUp: false): .neutral,
            TriangleCoordinate(q: -1, r: 1, isPointingUp: true): .neutral,
            TriangleCoordinate(q: 2, r: -1, isPointingUp: true): .directional(direction: 0),
            TriangleCoordinate(q: -2, r: 0, isPointingUp: false): .directional(direction: 3)
        ]
    ]
    
    static let layoutNames: [String] = ["Balanced", "Aggressive", "Defence", "Special"]
}

extension TriangleBoard {
    func isCoordinate(_ coord: TriangleCoordinate, withinRadius radius: Int) -> Bool {
        let r = coord.r
        let q = coord.q
        guard r >= -radius && r <= radius*2 - 1 else { return false }
        let qStart = -radius*2 + 1 + r
        let qEnd = radius*2 - 1 - r
        return q >= qStart && q <= qEnd
    }
}

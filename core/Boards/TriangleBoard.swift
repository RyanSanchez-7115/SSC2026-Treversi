import Foundation

struct TriangleBoard: BoardGeometry {
    let radius: Int
    var displayName: String { "Trianguland" }
    var description: String { "三角形棋盘，角是关键" }
    
    var allCoordinates: Set<TriangleCoordinate> {
        var coords = Set<TriangleCoordinate>()
        for r in -radius...radius {
            let qStart = -radius + r
            let qEnd = radius - r
            for q in qStart...qEnd {
                let s = -q - r
                coords.insert(TriangleCoordinate(q: q, r: r, isPointingUp: s % 2 != 0 ? false : true))
            }
        }
        return coords
    }
    
    var initialOccupation: [TriangleCoordinate: Piece] {
        var occupation: [TriangleCoordinate: Piece] = [:]
        occupation[TriangleCoordinate(q: -1, r: -1, isPointingUp: false)] = .black
        occupation[TriangleCoordinate(q: 0, r: 0, isPointingUp: true)] = .black
        occupation[TriangleCoordinate(q: 1, r: -1, isPointingUp: false)] = .black
        occupation[TriangleCoordinate(q: -1, r: 0, isPointingUp: false)] = .white
        occupation[TriangleCoordinate(q: 1, r: 0, isPointingUp: true)] = .white
        occupation[TriangleCoordinate(q: 0, r: -1, isPointingUp: true)] = .white
        return occupation
    }
}

extension TriangleBoard {
    func isCoordinate(_ coord: TriangleCoordinate, withinRadius radius: Int) -> Bool {
        let r = coord.r
        let q = coord.q
        guard r >= -radius && r <= radius else { return false }
        let qStart = -radius + r
        let qEnd = radius - r
        return q >= qStart && q <= qEnd
    }
}

extension TriangleBoard {
    static let layouts: [[TriangleCoordinate: Piece]] = [
        // 0 Original
        [
            TriangleCoordinate(q: 0, r: 0, isPointingUp: true): .black,
            TriangleCoordinate(q: 0, r: -1, isPointingUp: false): .black,
            TriangleCoordinate(q: -1, r: -1, isPointingUp: true): .white,
            TriangleCoordinate(q: 1, r: -1, isPointingUp: true): .white
        ],
        // 1 Classic
        [
            TriangleCoordinate(q: 0, r: -1, isPointingUp: false): .black,
            TriangleCoordinate(q: -1, r: -2, isPointingUp: false): .black,
            TriangleCoordinate(q: 1, r: -2, isPointingUp: false): .black,
            TriangleCoordinate(q: -1, r: -1, isPointingUp: true): .white,
            TriangleCoordinate(q: 1, r: -1, isPointingUp: true): .white,
            TriangleCoordinate(q: 0, r: -2, isPointingUp: true): .white
        ],
        // 2 Irregular
        [
            TriangleCoordinate(q: 0, r: -1, isPointingUp: false): .white,
            TriangleCoordinate(q: 1, r: -2, isPointingUp: false): .white,
            TriangleCoordinate(q: -1, r: -1, isPointingUp: true): .white,
            TriangleCoordinate(q: 1, r: -1, isPointingUp: true): .black,
            TriangleCoordinate(q: 0, r: -2, isPointingUp: true): .black,
            TriangleCoordinate(q: -1, r: -2, isPointingUp: false): .black
        ],
        // 3 Special
        [
            TriangleCoordinate(q: 0, r: 0, isPointingUp: true): .black,
            TriangleCoordinate(q: 0, r: -1, isPointingUp: false): .black,
            TriangleCoordinate(q: -1, r: -1, isPointingUp: true): .white,
            TriangleCoordinate(q: 1, r: -1, isPointingUp: true): .white,
            TriangleCoordinate(q: 1, r: 0, isPointingUp: false): .neutral,
            TriangleCoordinate(q: -1, r: 0, isPointingUp: true): .directional(direction: 2),
            TriangleCoordinate(q: 0, r: -2, isPointingUp: false): .directional(direction: 5)
        ]
    ]
    
    static let layoutNames: [String] = ["Original", "Classic", "Asymmetrical", "Special"]
}

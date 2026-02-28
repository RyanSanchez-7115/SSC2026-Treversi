import Foundation

/// @brief Diamond board structure, implements `BoardGeometry` protocol
struct DiamondBoard: BoardGeometry {
    /// @brief Board radius, controls the board size
    let radius: Int
    
    /// @brief Display name
    var displayName: String { "Dimond Field" }
    
    /// @brief Description
    var description: String { "Symmetrical diamond battlefield with two development paths" }
    
    /// @brief Generate all valid coordinates for the current radius
    var allCoordinates: Set<TriangleCoordinate> {
        var coords = Set<TriangleCoordinate>()
        for r in -radius..<(radius) {
            let qStart = -(radius * 2 - 1) + r
            let qEnd = qStart + radius * 4 - 1
            for q in qStart...qEnd {
                let s = -q - r
                coords.insert(
                    TriangleCoordinate(
                        q: q,
                        r: r,
                        isPointingUp: s % 2 == 0 ? false : true
                    )
                )
            }
        }
        return coords
    }
    
    /// @brief Default initial occupation mapping
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
    /// @brief Preset layout collection
    static let layouts: [[TriangleCoordinate: Piece]] = [
        /// @brief Layout 0: Classic
        [
            //black
            TriangleCoordinate(q: -1, r: -1, isPointingUp: false): .black,
            TriangleCoordinate(q: -1, r: 0, isPointingUp: true): .black,
            //white
            TriangleCoordinate(q: 0, r: -1, isPointingUp: true): .white,
            TriangleCoordinate(q: 1, r: -1, isPointingUp: false): .white,
            TriangleCoordinate(q: 1, r: 0, isPointingUp: true): .white,
            //special pieces
            TriangleCoordinate(q: 0, r: 0, isPointingUp: false): .neutral
        ],
        /// @brief Layout 1: Symmetrical
        [
            //black
            TriangleCoordinate(q: 0, r: 0, isPointingUp: false): .black,
            TriangleCoordinate(q: 1, r: -1, isPointingUp: false): .black,
            TriangleCoordinate(q: 2, r: 0, isPointingUp: false): .black,
            //white
            TriangleCoordinate(q: -1, r: 0, isPointingUp: true): .white,
            TriangleCoordinate(q: 0, r: -1, isPointingUp: true): .white,
            TriangleCoordinate(q: -2, r: -1, isPointingUp: true): .white,
            //special pieces
            TriangleCoordinate(q: -1, r: -1, isPointingUp: false): .neutral,
            TriangleCoordinate(q: 1, r: 0, isPointingUp: true): .neutral
        ],
        /// @brief Layout 2: Aggressive
        [
            //black
            TriangleCoordinate(q: -1, r: 0, isPointingUp: true): .black,
            //white
            TriangleCoordinate(q: -1, r: -1, isPointingUp: false): .white,
            TriangleCoordinate(q: 1, r: -1, isPointingUp: false): .white,
            TriangleCoordinate(q: -2, r: 0, isPointingUp: false): .white,
            TriangleCoordinate(q: 0, r: -2, isPointingUp: false): .white,
            //special pieces
            TriangleCoordinate(q: 1, r: 0, isPointingUp: true): .neutral
        ],
        /// @brief Layout 3: Special
        [
            //black
            TriangleCoordinate(q: 1, r: -1, isPointingUp: false): .black,
            TriangleCoordinate(q: 0, r: 0, isPointingUp: false): .black,
            //white
            TriangleCoordinate(q: 1, r: 0, isPointingUp: true): .white,
            TriangleCoordinate(q: 0, r: -1, isPointingUp: true): .white,
            //special pieces
            TriangleCoordinate(q: 2, r: -1, isPointingUp: true): .neutral,
            TriangleCoordinate(q: -1 ,r: -1, isPointingUp: false): .neutral,
            TriangleCoordinate(q: -2, r: 0, isPointingUp: false): .directional(direction: 0),
            TriangleCoordinate(q: 1, r: -2, isPointingUp: true): .directional(direction: 3)
        ]
    ]
    
    /// @brief Layout names
    static let layoutNames: [String] = ["Classic", "Symmetrical", "Aggressive", "Special"]
}

extension DiamondBoard {
    /// @brief Determine whether the coordinate is within the specified radius
    /// @param coord The coordinate to check
    /// @param radius Target radius
    /// @return Returns true if the coordinate is valid
    func isCoordinate(_ coord: TriangleCoordinate, withinRadius radius: Int) -> Bool {
        let r = coord.r
        guard r >= -radius && r <= radius - 1 else { return false }
        let qStart = -(radius * 2 - 1) + r
        let qEnd = qStart + radius * 4 - 1
        return coord.q >= qStart && coord.q <= qEnd
    }
}

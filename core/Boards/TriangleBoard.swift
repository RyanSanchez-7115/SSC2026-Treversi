import Foundation

struct TriangleBoard: BoardGeometry {
    let radius: Int
    
    var displayName: String { "Trianguland" }
    var description: String { "三角形棋盘，角是关键" }
    
    // MARK: - 坐标生成（严格遵循用户提供的算法）
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
    
    // MARK: - 默认初始布局
    var initialOccupation: [TriangleCoordinate: Player] {
        
        var occupation: [TriangleCoordinate: Player] = [:]
        occupation[TriangleCoordinate(q: -1, r: -1, isPointingUp: false)] = .black
        occupation[TriangleCoordinate(q: 0, r: 0, isPointingUp: true)] = .black
        occupation[TriangleCoordinate(q: 1, r: -1, isPointingUp: false)] = .black
        occupation[TriangleCoordinate(q: -1, r: 0, isPointingUp: false)] = .white
        occupation[TriangleCoordinate(q: 1, r: 0, isPointingUp: true)] = .white
        occupation[TriangleCoordinate(q: 0, r: -1, isPointingUp: true)] = .white
        
        return occupation
    }
}

// MARK: - 布局扩展（目前只有空棋盘，可后续添加）
extension TriangleBoard {
    /// 判断坐标是否在指定半径的三角形棋盘内（需与 allCoordinates 逻辑一致）
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
    static let layouts: [[TriangleCoordinate: Player]] = [
        // 布局0：original开局
        [
            TriangleCoordinate(q: 0, r: 0, isPointingUp: true): .black,
            TriangleCoordinate(q: 0, r: -1, isPointingUp: false): .black,
            TriangleCoordinate(q: -1, r: -1, isPointingUp: true): .white,
            TriangleCoordinate(q: 1, r: -1, isPointingUp: true): .white,
        ],
        // 布局1：classic布局
        [
            TriangleCoordinate(q: 0, r: -1, isPointingUp: false): .black,
            TriangleCoordinate(q: -1, r: -2, isPointingUp: false): .black,
            TriangleCoordinate(q: 1, r: -2, isPointingUp: false): .black,
            TriangleCoordinate(q: -1, r: -1, isPointingUp: true): .white,
            TriangleCoordinate(q: 1, r: -1, isPointingUp: true): .white,
            TriangleCoordinate(q: 0, r: -2, isPointingUp: true): .white,
            
        ],
        // 布局2：balance布局
        
        // 布局3：irragular布局
        [
            TriangleCoordinate(q: 0, r: -1, isPointingUp: false): .white,
            TriangleCoordinate(q: 1, r: -2, isPointingUp: false): .white,
            TriangleCoordinate(q: -1, r: -1, isPointingUp: true): .white,
            TriangleCoordinate(q: 1, r: -1, isPointingUp: true): .black,
            TriangleCoordinate(q: 0, r: -2, isPointingUp: true): .black,
            TriangleCoordinate(q: -1, r: -2, isPointingUp: false): .black
  
        ]
    ]
    
    static let layoutNames: [String] = ["Original", "Classic", "Asymmetrical"]
}

// MARK: - 通用六边形棋盘

struct HexagonBoard: BoardGeometry {
    
    let radius: Int
    var displayName: String { "Classic Hexagon" }
    var description: String { "完美对称的几何美感" }
    
    var allCoordinates: Set<TriangleCoordinate> {
        var coords = Set<TriangleCoordinate>()
        for r in 0...(radius - 1){
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
    

    var initialOccupation: [TriangleCoordinate: Player] {
        
        var occupation: [TriangleCoordinate: Player] = [:]
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
    // 预定义的布局数组
    static let layouts: [[TriangleCoordinate: Player]] = [
        // 布局0：classic开局
        [
            TriangleCoordinate(q: 0, r: 0, isPointingUp: false): .black,
            TriangleCoordinate(q: 0, r: -1, isPointingUp: true): .black,
            TriangleCoordinate(q: 1, r: 0, isPointingUp: true): .white,
            TriangleCoordinate(q: -1, r: 0, isPointingUp: true): .white,
            TriangleCoordinate(q: -1, r: -1, isPointingUp: false): .white,
            TriangleCoordinate(q: 1, r: -1, isPointingUp: false): .white
        ],
        // 布局1：Symmetrical布局
        [
            TriangleCoordinate(q: -1, r: -1, isPointingUp: false): .black,
            TriangleCoordinate(q: 0, r: 0, isPointingUp: false): .black,
            TriangleCoordinate(q: 1, r: -1, isPointingUp: false): .black,
            TriangleCoordinate(q: -1, r: 0, isPointingUp: true): .white,
            TriangleCoordinate(q: 1, r: 0, isPointingUp: true): .white,
            TriangleCoordinate(q: 0, r: -1, isPointingUp: true): .white
        ],
        // 布局2：Line布局
        [
            TriangleCoordinate(q: 1, r: 0, isPointingUp: true): .black,
            TriangleCoordinate(q: -1, r: -1, isPointingUp: false): .black,
            TriangleCoordinate(q: 0, r: 1, isPointingUp: true): .white,
            TriangleCoordinate(q: -1, r: 0, isPointingUp: true): .white,
            TriangleCoordinate(q: -2, r: -1, isPointingUp: true): .white,
  
        ]
    ]
    
    static let layoutNames: [String] = ["Classic", "Symmetrical", "Line"]
}
extension HexagonBoard {
    /// 判断给定坐标是否在指定半径的六边形棋盘内（遵循生成算法）
    func isCoordinate(_ coord: TriangleCoordinate, withinRadius radius: Int) -> Bool {
        let r = coord.r
        let q = coord.q
        // 正半轴 r 从 0 到 radius-1
        if r >= 0 && r < radius {
            let minQ = -(radius * 2 - 1 - r)
            let maxQ = radius * 2 - 1 - r
            return q >= minQ && q <= maxQ
        }
        // 负半轴 r 从 -radius 到 -1
        else if r < 0 && r >= -radius {
            let minQ = -(radius * 2 + r)   // r 为负数，radius*2 + r 可能小于 radius*2
            let maxQ = radius * 2 + r
            return q >= minQ && q <= maxQ
        }
        return false
    }
}

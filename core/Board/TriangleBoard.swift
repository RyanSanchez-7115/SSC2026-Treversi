import Foundation

struct TriangleBoard: BoardGeometry {
    let radius: Int
    
    var displayName: String { "三角领域" }
    var description: String { "奇偶半径形状不同的三角形棋盘，顶点灵活多变。" }
    
    // MARK: - 坐标生成（严格遵循用户提供的算法）
    var allCoordinates: Set<TriangleCoordinate> {
        var coords = Set<TriangleCoordinate>()
        if radius % 2 == 0 {
            // 偶数半径：生成一个六边形区域（实际上可能是一个菱形？但忠实于用户代码）
            for r in -radius...radius {
                let qStart = -radius + r
                let qEnd = radius - r
                for q in qStart...qEnd {
                    let s = -q - r
                    coords.insert(TriangleCoordinate(q: q, r: r, isPointingUp: s % 2 != 0 ? false : true))
                }
            }
        } else {
            // 奇数半径：生成一个高度为 radius*2 的倒梯形区域
            for r in -radius...(radius*2 - 1) {
                let qStart = -(radius*2 - 1) + r
                let qEnd = (radius*2 - 1) - r
                for q in qStart...qEnd {
                    let s = -q - r
                    coords.insert(TriangleCoordinate(q: q, r: r, isPointingUp: s % 2 == 0 ? false : true))
                }
            }
        }
        return coords
    }
    
    // MARK: - 邻居计算（与六边形完全相同）
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
    
    // MARK: - 默认初始布局（空棋盘）
    var initialOccupation: [TriangleCoordinate: Player] {
        return [:]
    }
}

// MARK: - 布局扩展（目前只有空棋盘，可后续添加）
extension TriangleBoard {
    /// 判断坐标是否在指定半径的三角形棋盘内（需与 allCoordinates 逻辑一致）
    func isCoordinate(_ coord: TriangleCoordinate, withinRadius radius: Int) -> Bool {
        let r = coord.r
        let q = coord.q
        if radius % 2 == 0 {
            // 偶数半径：对应六边形范围
            guard r >= -radius && r <= radius else { return false }
            let qStart = -radius + r
            let qEnd = radius - r
            return q >= qStart && q <= qEnd
        } else {
            // 奇数半径：对应倒梯形范围
            guard r >= -radius && r <= (radius*2 - 1) else { return false }
            let qStart = -(radius*2 - 1) + r
            let qEnd = (radius*2 - 1) - r
            return q >= qStart && q <= qEnd
        }
    }
    
    static let layouts: [[TriangleCoordinate: Player]] = [
        [:]  // 布局0：空棋盘
    ]
    
    static let layoutNames: [String] = ["默认"]
}

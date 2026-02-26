import Foundation

struct DiamondBoard: BoardGeometry {
    let radius: Int
    
    var displayName: String { "Dimond Field" }
    var description: String { "菱形的对称战场，两种发展方向" }
    
    // MARK: - 坐标生成（根据用户提供的算法）
    var allCoordinates: Set<TriangleCoordinate> {
        var coords = Set<TriangleCoordinate>()
        for r in -radius...(radius - 1){
            // 计算 q 的范围：起始 = -(1 + radius*2)，结束 = 起始 + radius*4
            let qStart = -(radius * 2 - 1) + r
            let qEnd = qStart + radius * 4 - 1
            for q in qStart...qEnd {
                let s = -q - r
                // 朝向由 s 的奇偶决定（与六边形保持一致）
                coords.insert(TriangleCoordinate(q: q, r: r, isPointingUp: s % 2 == 0 ? false : true))
            }
        }
        return coords
    }
    
    // MARK: - 默认初始布局
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

// MARK: - 布局扩展（可添加多个初始布局）
extension DiamondBoard {
    // 预定义的布局数组
    static let layouts: [[TriangleCoordinate: Player]] = [
        // 布局0：classic开局
        [
            TriangleCoordinate(q: -1, r: -1, isPointingUp: false): .black,
                TriangleCoordinate(q: -1, r: 0, isPointingUp: true): .black,
                TriangleCoordinate(q: 0, r: -1, isPointingUp: true): .white,
                TriangleCoordinate(q: 1, r: -1, isPointingUp: false): .white,
                TriangleCoordinate(q: 1, r: 0, isPointingUp: true): .white
        ],
        // 布局1：irragular布局
        [
            TriangleCoordinate(q: 0, r: 0, isPointingUp: false): .black,
            TriangleCoordinate(q: 1, r: -1, isPointingUp: false): .black,
            TriangleCoordinate(q: 2, r: 0, isPointingUp: false): .black,
            TriangleCoordinate(q: -1, r: 0, isPointingUp: true): .white,
            TriangleCoordinate(q: 0, r: -1, isPointingUp: true): .white,
            TriangleCoordinate(q: -2, r: -1, isPointingUp: true): .white
            
        ],
        // 布局2：激进布局
        [
            TriangleCoordinate(q: -1, r: -1, isPointingUp: false): .white,
            TriangleCoordinate(q: 1, r: -1, isPointingUp: false): .white,
            TriangleCoordinate(q: -2, r: 0, isPointingUp: false): .white,
            TriangleCoordinate(q: 0, r: -2, isPointingUp: false): .white,
            TriangleCoordinate(q: -1, r: 0, isPointingUp: true): .black,
        ]
    ]
    static let layoutNames: [String] = ["Classic", "Symmetrical", "Aggressive"]
}
extension DiamondBoard {
    /// 判断给定坐标是否在指定半径的菱形棋盘内（与 allCoordinates 生成逻辑一致）
    func isCoordinate(_ coord: TriangleCoordinate, withinRadius radius: Int) -> Bool {
        let r = coord.r
        // 检查 r 是否在有效范围内
        guard r >= -radius && r <= radius - 1 else { return false }
        // 计算该 r 对应的 q 范围
        let qStart = -(radius * 2 - 1) + r
        let qEnd = qStart + radius * 4 - 1
        return coord.q >= qStart && coord.q <= qEnd
    }
}

import Foundation

struct DiamondBoard: BoardGeometry {
    let radius: Int
    
    var displayName: String { "菱形战场" }
    var description: String { "菱形密铺的对称战场，对角线是战略要地。" }
    
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
    
    // MARK: - 邻居计算（与六边形完全相同，因为三角形网格局部结构一致）
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
        // 布局0：经典开局（你之前设计的6个棋子）
        [
            TriangleCoordinate(q: -1, r: -1, isPointingUp: false): .black,
            TriangleCoordinate(q: 0, r: 0, isPointingUp: false): .black,
            TriangleCoordinate(q: 1, r: -1, isPointingUp: false): .black,
            TriangleCoordinate(q: -1, r: 0, isPointingUp: true): .white,
            TriangleCoordinate(q: 1, r: 0, isPointingUp: true): .white,
            TriangleCoordinate(q: 0, r: -1, isPointingUp: true): .white
        ],
        // 布局1：非对称布局
        [
           
            //TriangleCoordinate(q: 0, r: 0, isPointingUp: false): .black,
            TriangleCoordinate(q: 1, r: -1, isPointingUp: false): .black,
            TriangleCoordinate(q: 1, r: 0, isPointingUp: true): .black,
            TriangleCoordinate(q: -1, r: 0, isPointingUp: true): .white,
            TriangleCoordinate(q: 0, r: -1, isPointingUp: true): .white,
            
        ],
        // 布局2：激进布局（可自行设计）
        [
            TriangleCoordinate(q: -1, r: -1, isPointingUp: false): .white,
            TriangleCoordinate(q: 1, r: -1, isPointingUp: false): .white,
            TriangleCoordinate(q: -2, r: 0, isPointingUp: false): .white,
            TriangleCoordinate(q: -1, r: 0, isPointingUp: true): .black,
  
        ]
    ]
    static let layoutNames: [String] = ["经典", "对称", "激进"]
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

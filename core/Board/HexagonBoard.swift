// MARK: - 安全启动：硬编码的 radius=2 六边形棋盘 (24个三角形)
// 我们先确保游戏引擎能运行，稍后可以替换为更通用的生成算法。
struct HexagonBoard: BoardGeometry {
    
    let radius: Int = 2 // 固定为2
    var displayName: String { "经典六边形" }
    var description: String { "三角密铺的古老契约。" }
    
    // 一个预先计算好的、保证正确的坐标集合（对应radius=2的24个三角形）
    var allCoordinates: Set<TriangleCoordinate> {
        return [
            //第一圈层
            TriangleCoordinate(q: 0, r: 0, isPointingUp: false),
            TriangleCoordinate(q: 1, r: -1, isPointingUp: false),
            TriangleCoordinate(q: -1, r: -1, isPointingUp: false),
            TriangleCoordinate(q: 1, r: 0, isPointingUp: true),
            TriangleCoordinate(q: -1, r: 0, isPointingUp: true),
            TriangleCoordinate(q: 0, r: -1, isPointingUp: true),
            //第二圈层
            TriangleCoordinate(q: -1, r: 1, isPointingUp: false),
            TriangleCoordinate(q: 1, r: 1, isPointingUp: false), 
            TriangleCoordinate(q: -2, r: 0, isPointingUp: false),
            TriangleCoordinate(q: 2, r: 0, isPointingUp: false),
            TriangleCoordinate(q: -1, r: 1, isPointingUp: false),
            TriangleCoordinate(q: -3, r: -1, isPointingUp: false),
            TriangleCoordinate(q: 3, r: -1, isPointingUp: false),
            TriangleCoordinate(q: -2, r: -2, isPointingUp: false),
            TriangleCoordinate(q: 0, r: -2, isPointingUp: false),
            TriangleCoordinate(q: 2, r: -2, isPointingUp: false),
            TriangleCoordinate(q: -2, r: 1, isPointingUp: true),
            TriangleCoordinate(q: 0, r: 1, isPointingUp: true),
            TriangleCoordinate(q: 2, r: 1, isPointingUp: true),
            TriangleCoordinate(q: -3, r: 0, isPointingUp: true),
            TriangleCoordinate(q: 3, r: 0, isPointingUp: true),
            TriangleCoordinate(q: -2, r: -1, isPointingUp: true),
            TriangleCoordinate(q: 2, r: -1, isPointingUp: true),
            TriangleCoordinate(q: -1, r: -2, isPointingUp: true),
            TriangleCoordinate(q: 1, r: -2, isPointingUp: true),
        ]
    }
    
    // MARK: - 邻居计算
    func neighbors(of coordinate: TriangleCoordinate) -> Set<TriangleCoordinate> {
        let (q, r, isUp) = (coordinate.q, coordinate.r, coordinate.isPointingUp)
        
        if isUp {
            // 朝上三角形的三个朝下邻居
            return [
                TriangleCoordinate(q: q, r: r - 1, isPointingUp: false),  // 正下方
                TriangleCoordinate(q: q - 1, r: r, isPointingUp: false),  // 左下方
                TriangleCoordinate(q: q + 1, r: r, isPointingUp: false)   // 右下方
            ]
        } else {
            // 朝下三角形的三个朝上邻居
            return [
                TriangleCoordinate(q: q, r: r + 1, isPointingUp: true),   // 正上方
                TriangleCoordinate(q: q - 1, r: r, isPointingUp: true),   // 左上方
                TriangleCoordinate(q: q + 1, r: r, isPointingUp: true)    // 右上方
            ]
        }
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
    
    // 初始化器简化
    init() {} // 固定半径，不需要参数
}

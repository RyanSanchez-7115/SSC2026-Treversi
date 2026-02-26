import Foundation

protocol BoardGeometry {
    // MARK: - 必需属性
    /// 棋盘上所有有效的三角形坐标集合。
    /// 游戏引擎将遍历这个集合来绘制棋盘和判断状态。
    var allCoordinates: Set<TriangleCoordinate> { get }
    
    /// 棋盘的默认初始布局，一个从坐标到玩家的映射字典。
    /// 例如：某个坐标初始时为黑子 `[someCoordinate: .black]`
    var initialOccupation: [TriangleCoordinate: Player] { get }
    
    // MARK: - 可选但推荐的属性
    /// 棋盘的显示名称，用于UI（例如：“经典六边形”、“菱形战场”）。
    var displayName: String { get }
    
    /// 关于此棋盘策略特点的简短描述，用于UI提示。
    var description: String { get }
}
// MARK: - 棋盘类型枚举
enum BoardType: String, CaseIterable, Identifiable {
    case hexagon
    case diamond
    case triangle
    
    var id: String { self.rawValue }
    
    // 根据枚举创建具体的棋盘实例
    func geometry(radius: Int) -> any BoardGeometry {
        switch self {
        case .hexagon:
            return HexagonBoard(radius: radius)
        case .diamond:
            return DiamondBoard(radius: radius)
        case .triangle:
            return TriangleBoard(radius: radius)
        }
    }
    
    // 显示名称
    var displayName: String {
        switch self {
        case .hexagon: return "Classic Hexagon"
        case .diamond: return "Dimond Field"
        case .triangle: return "Trianguland"
        }
    }
    
    // 获取该类型可用的布局名称列表
    var layoutNames: [String] {
        switch self {
        case .hexagon:
            return HexagonBoard.layoutNames
        case .diamond:
            return DiamondBoard.layoutNames
        case .triangle:
            return TriangleBoard.layoutNames
        }
    }
    
    // 获取指定索引的布局字典
    func getLayout(at index: Int) -> [TriangleCoordinate: Player] {
        switch self {
        case .hexagon:
            guard index < HexagonBoard.layouts.count else { return [:] }
            return HexagonBoard.layouts[index]
        case .diamond:
            guard index < DiamondBoard.layouts.count else { return [:] }
            return DiamondBoard.layouts[index]
        case.triangle:
            guard index < TriangleBoard.layouts.count else { return [:] }
            return TriangleBoard.layouts[index]
        }
    }
}
// MARK: - 邻居计算（所有棋盘共享的逻辑）
extension BoardGeometry {
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
}
// 为协议提供默认实现，使这两个UI属性变为可选
extension BoardGeometry {
    var displayName: String { return "Unnamed Board" }
    var description: String { return "" }
}

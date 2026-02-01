//
//  Untitled.swift
//  Treversi
//
//  Created by 刁泓宁 on 2026/2/5.
//
import Foundation

protocol BoardGeometry {
    // MARK: - 必需属性
    /// 棋盘上所有有效的三角形坐标集合。
    /// 游戏引擎将遍历这个集合来绘制棋盘和判断状态。
    var allCoordinates: Set<TriangleCoordinate> { get }
    
    /// 棋盘的默认初始布局，一个从坐标到玩家的映射字典。
    /// 例如：某个坐标初始时为黑子 `[someCoordinate: .black]`
    var initialOccupation: [TriangleCoordinate: Player] { get }
    
    // MARK: - 必需方法
    /// **最核心的函数**：给定一个坐标，返回其所有直接相邻的坐标。
    /// 游戏引擎完全依赖此函数来计算落子是否合法、翻转哪些棋子。
    /// - Parameter coordinate: 要查询的三角形坐标
    /// - Returns: 一个包含所有邻居坐标的集合
    func neighbors(of coordinate: TriangleCoordinate) -> Set<TriangleCoordinate>
    
    // MARK: - 可选但推荐的属性
    /// 棋盘的显示名称，用于UI（例如：“经典六边形”、“菱形战场”）。
    var displayName: String { get }
    
    /// 关于此棋盘策略特点的简短描述，用于UI提示。
    var description: String { get }
}

// 为协议提供默认实现，使这两个UI属性变为可选
extension BoardGeometry {
    var displayName: String { return "未命名棋盘" }
    var description: String { return "" }
}
// MARK: - 棋盘类型枚举（用于SwiftUI Picker）
enum BoardType: String, CaseIterable, Identifiable {
    case hexagon
    case diamond
    case irregular
    
    var id: String { self.rawValue }
    
    // 根据枚举创建具体的棋盘实例
    var geometry: any BoardGeometry {
        switch self {
        case .hexagon:
            return HexagonBoard()
        case .diamond:
            // 先返回一个临时的六边形，等实现了DiamondBoard再替换
            return HexagonBoard()
        case .irregular:
            // 先返回一个临时的六边形，等实现了IrregularBoard再替换
            return HexagonBoard()
        }
    }
    
    // 显示名称
    var displayName: String {
        switch self {
        case .hexagon: return "经典六边形"
        case .diamond: return "菱形战场"
        case .irregular: return "异形领域"
        }
    }
}

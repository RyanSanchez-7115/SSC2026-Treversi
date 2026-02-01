//
//  TriangleCoordinate.swift
//  Treversi
//
//  Created by 刁泓宁 on 2026/2/5.
//
// 采用六边形网格中经典的立方坐标系
struct TriangleCoordinate: Hashable {
    // 立方坐标的三个轴：q, r, s。对于任何有效坐标，满足 q + r + s = 0
    let q: Int
    let r: Int
    let s: Int // 可通过计算得出，但存储它便于调试和哈希
    
    // 三角形的朝向：指向上方（尖朝上）或下方（尖朝下）
    let isPointingUp: Bool
    
    // 初始化器：只需提供 q, r 和朝向，s 自动计算
    init(q: Int, r: Int, isPointingUp: Bool) {
        self.q = q
        self.r = r
        self.s = -(q + r) // 强制满足 q + r + s = 0
        self.isPointingUp = isPointingUp
    }
}


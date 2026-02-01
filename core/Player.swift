//
//  Player.swift
//  Treversi
//
//  Created by 刁泓宁 on 2026/2/5.
//
enum Player {
    case black
    case white
    case empty // 表示该位置为空，或用于初始化
    
    // 一个便捷属性，用于获取对手的颜色
    var opponent: Player {
        switch self {
        case .black: return .white
        case .white: return .black
        case .empty: return .empty
        }
    }
}

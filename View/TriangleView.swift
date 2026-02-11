//
//  TriangleView.swift
//  Treversi
//
//  Created by 刁泓宁 on 2026/2/17.
//

import SwiftUI

// 三角形形状
struct TriangleShape: Shape {
    let isPointingUp: Bool
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        if isPointingUp {
            // 顶点在上
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        } else {
            // 顶点在下
            path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        }
        path.closeSubpath()
        return path
    }
}

// 三角形视图
struct TriangleView: View {
    let coordinate: TriangleCoordinate
    let player: Player
    let isLegalMove: Bool
    let isHovered: Bool   // 用于悬停预览
    let side: CGFloat      // 三角形边长
    
    var body: some View {
        TriangleShape(isPointingUp: coordinate.isPointingUp)
            .fill(fillColor)
            .overlay(
                TriangleShape(isPointingUp: coordinate.isPointingUp)
                    .stroke(borderColor, lineWidth: 2)
            )
            .frame(width: side, height: side * sqrt(3)/2)
    }
    
    var fillColor: Color {
        if isHovered {
            return Color.yellow.opacity(0.6)
        }
        switch player {
        case .black:
            return .red
        case .white:
            return .blue
        case .empty:
            return isLegalMove ? Color.green.opacity(0.3) : Color.clear
        }
    }
    
    var borderColor: Color {
        if isLegalMove && player == .empty {
            return .green
        } else {
            return .gray.opacity(0.3)
        }
    }
}

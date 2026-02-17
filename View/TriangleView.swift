//
//  TriangleView.swift
//  Treversi
//
//  Created by 刁泓宁 on 2026/2/17.
//

import SwiftUI

// 圆角三角形形状
struct TriangleShape: Shape {
    let isPointingUp: Bool
    var cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let p1, p2, p3: CGPoint
        if isPointingUp {
            p1 = CGPoint(x: rect.midX, y: rect.minY) // Top
            p2 = CGPoint(x: rect.minX, y: rect.maxY) // Bottom-left
            p3 = CGPoint(x: rect.maxX, y: rect.maxY) // Bottom-right
        } else {
            p1 = CGPoint(x: rect.midX, y: rect.maxY) // Bottom
            p2 = CGPoint(x: rect.maxX, y: rect.minY) // Top-right
            p3 = CGPoint(x: rect.minX, y: rect.minY) // Top-left
        }

        // 移动到第一个圆角的起始点
        path.move(to: CGPoint(x: p1.x + (p3.x - p1.x) * (cornerRadius / rect.width), y: p1.y + (p3.y - p1.y) * (cornerRadius / rect.height)))
        
        path.addArc(tangent1End: p1, tangent2End: p2, radius: cornerRadius)
        path.addArc(tangent1End: p2, tangent2End: p3, radius: cornerRadius)
        path.addArc(tangent1End: p3, tangent2End: p1, radius: cornerRadius)
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
       
        let shape = TriangleShape(isPointingUp: coordinate.isPointingUp, cornerRadius: 2)
        
        shape
            .fill(fillColor)
            .overlay(
                shape.stroke(borderColor, lineWidth: 2)
            )
            .frame(width: side, height: side * sqrt(3)/2)
    }
    

    var fillColor: Color {
        if isHovered {
            return Color.yellow.opacity(0.6)
        }
        switch player {
        case .black:
            return .black
        case .white:
            return .white
        case .empty:
            return isLegalMove ? Color.green.opacity(0.5) : Color.black.opacity(0.2)
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

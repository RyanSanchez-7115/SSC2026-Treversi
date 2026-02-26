//
//  ArrowShape.swift
//  Treversi
//
//  Created by 刁泓宁 on 2026/2/26.
//


import SwiftUI

struct ArrowShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        
        // 默认指向右的箭头（之后用 rotationEffect 转方向）
        path.move(to: CGPoint(x: 0, y: h * 0.5))
        path.addLine(to: CGPoint(x: w * 0.72, y: h * 0.5))
        path.addLine(to: CGPoint(x: w * 0.72, y: h * 0.25))
        path.addLine(to: CGPoint(x: w, y: h * 0.5))
        path.addLine(to: CGPoint(x: w * 0.72, y: h * 0.75))
        path.addLine(to: CGPoint(x: w * 0.72, y: h * 0.5))
        path.closeSubpath()
        
        return path
    }
}
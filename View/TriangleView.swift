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
import SwiftUI

struct TriangleView: View {
    let coordinate: TriangleCoordinate
    let player: Player
    let isLegalMove: Bool
    let isHovered: Bool
    let side: CGFloat
    
    // 旋转角度（0～180）
    @State private var rotationAngle: Double = 0
    // 动画开始前的原始颜色
    @State private var originalPlayer: Player
    // 目标颜色（即将变成的颜色）
    @State private var targetPlayer: Player
    
    init(coordinate: TriangleCoordinate, player: Player, isLegalMove: Bool, isHovered: Bool, side: CGFloat) {
        self.coordinate = coordinate
        self.player = player
        self.isLegalMove = isLegalMove
        self.isHovered = isHovered
        self.side = side
        _originalPlayer = State(initialValue: player)
        _targetPlayer = State(initialValue: player)
    }
    
    // 根据旋转角度决定当前显示的颜色：角度≥90°时显示目标颜色，否则显示原始颜色
    private var currentPlayer: Player {
        rotationAngle >= 90 ? targetPlayer : originalPlayer
    }
    
    var body: some View {
        TriangleShape(isPointingUp: coordinate.isPointingUp, cornerRadius: 2)
            .fill(fillColor(for: currentPlayer))
            .overlay(
                TriangleShape(isPointingUp: coordinate.isPointingUp, cornerRadius: 2)
                    .stroke(borderColor, lineWidth: 2)
            )
            .frame(width: side, height: side * sqrt(3)/2)
            .rotation3DEffect(
                .degrees(rotationAngle),
                axis: (x: 0, y: 1, z: 0),  // 绕X轴旋转（水平轴），可改为Y轴实现垂直翻面
                perspective: 0.3
            )
            .onChange(of: player) { newPlayer in
                // 仅当棋子确实发生变化时触发动画
                guard newPlayer != originalPlayer else { return }
                targetPlayer = newPlayer
                // 开始旋转动画
                withAnimation(.easeInOut(duration: 0.6)) {
                    rotationAngle = 180
                }
            }
            .onChange(of: rotationAngle) { newAngle in
                // 动画完成时（角度达到180）进行处理
                if newAngle == 180 {
                    // 将原始颜色更新为目标颜色，确保复位后颜色正确
                    originalPlayer = targetPlayer
                    // 延迟复位角度，避免视觉突兀
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        rotationAngle = 0
                    }
                }
            }
    }
    
    private func fillColor(for player: Player) -> Color {
        if isHovered {
            return Color.yellow.opacity(0.6)
        }
        switch player {
        case .black:
            return .black
        case .white:
            return .white
        case .empty:
            return isLegalMove ? Color.green.opacity(0.3) : Color.black.opacity(0.2)
        }
    }
    
    private var borderColor: Color {
        if isLegalMove && player == .empty {
            return .green
        } else {
            return .gray.opacity(0.3)
        }
    }
}

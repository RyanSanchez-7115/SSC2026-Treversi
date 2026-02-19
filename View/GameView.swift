//
//  GameView.swift
//  Treversi
//
//  Created by 刁泓宁 on 2026/2/17.
//

import SwiftUI

struct GameView: View {
    @StateObject var gameState: GameState
    let geometry: BoardGeometry
    
    var body: some View {
        VStack {
            // 顶部信息栏
            HStack {
                PlayerIndicator(player: .black, count: gameState.countPieces().black)
                Spacer()
                Text("当前回合")
                    .font(.headline)
                Spacer()
                PlayerIndicator(player: .white, count: gameState.countPieces().white)
            }
            .padding(.horizontal)
            //棋盘视图
            BoardView(gameState: gameState, geometry: geometry)
                          .aspectRatio(1, contentMode: .fit)
                          .padding()

            HStack(spacing: 30) {
              Button(action: { _ = gameState.undoMove() }) {
                  Label("撤销", systemImage: "arrow.uturn.backward")
              }
              .disabled(gameState.moveHistory.isEmpty || gameState.isAnimating)

              Button(action: { gameState.restart() }) {
                  Label("重新开始", systemImage: "arrow.counterclockwise")
              }
              .disabled(gameState.isAnimating)
          }
          .padding()
                  }
        .background(
            // 简单背景，后续可替换为动态背景
            Color(.systemBackground)
                .ignoresSafeArea()
        )
    }
}

// 玩家指示器组件
struct PlayerIndicator: View {
    let player: Player
    let count: Int
    
    var body: some View {
        HStack {
            Circle()
                .fill(player == .black ? Color.black : Color.white)
                .frame(width: 24, height: 24)
                .overlay(Circle().stroke(Color.gray, lineWidth: 1))
            Text("\(count)")
                .font(.title2)
                .bold()
        }
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

import SwiftUI

struct AboutView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // 标题
                    Text("Treversi")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    
                    // 副标题
                    Text("三角翻转棋：Reversi 的几何创新变体")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    
                    // 项目简介
                    Group {
                        Text("Treversi 是一个基于 SwiftUI 开发的原创棋类游戏，将经典黑白棋（Reversi）的翻转机制扩展到三角形棋子与多种几何棋盘上。")
                        
                        Text("核心创新点：")
                        Text("• 支持三种完全不同的棋盘几何：六边形、菱形、三角形")
                        Text("• 每种棋盘提供多个初始布局（经典、对称、激进、特殊）")
                        Text("• 特殊棋子机制：中立子（可穿越桥梁） + 方向子（单向限制翻转）")
                        Text("• 流畅的 3D 翻转动画、合法落子预览、撤销功能")
                    }
                    .font(.body)
                    .lineSpacing(8)
                    
                    // 技术亮点
                    VStack(alignment: .leading, spacing: 12) {
                        Text("技术亮点")
                            .font(.title3.bold())
                        
                        Text("• 使用立方体坐标系（q, r, s）实现三角网格精准定位")
                        Text("• 自定义 Shape + rotation3DEffect 实现三角棋子与翻转动画")
                        Text("• ObservableObject + @Published 高效管理游戏状态")
                        Text("• 异步计算合法落子 + 缓存机制，保证大棋盘流畅体验")
                        Text("• 模块化设计：Core（模型+引擎） / Features（界面） / UI（通用组件）")
                    }
                    
                    // 灵感来源与原创说明
                    VStack(alignment: .leading, spacing: 12) {
                        Text("灵感来源与原创说明")
                            .font(.title3.bold())
                        
                        Text("游戏灵感来源于经典黑白棋规则，但通过三角坐标系与六边形变体进行了深度改造。")
                        Text("特殊棋子（中立子 + 方向子）为本人原创设计，旨在增加策略深度与空间博弈乐趣。")
                        Text("所有代码均为独立完成，未直接复制任何现有游戏实现。")
                    }
                    
                    // 致谢与信息
                    VStack(alignment: .leading, spacing: 12) {
                        Text("制作信息")
                            .font(.title3.bold())
                        
                        Text("作者：刁泓宁")
                        Text("提交：Swift Student Challenge 2026")
                        Text("开发工具：SwiftUI + Xcode")
                        Text("完成时间：2026 年 2 月")
                    }
                    .font(.callout)
                    .foregroundStyle(.secondary)
                }
                .padding(32)
            }
            .navigationTitle("关于 Treversi")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


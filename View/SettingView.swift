import SwiftUI

enum DetailView {
    case welcome
    case game(GameConfig)
}

struct SettingView: View {
    @State private var config = GameConfig()
    @State private var detail: DetailView = .welcome
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    
    // 根据棋盘类型获取布局名称列表
    private var layoutNames: [String] {
        switch config.boardType {
        case .hexagon:
            return HexagonBoard.layoutNames
        case .diamond, .irregular:
            return ["默认"] // 临时，后续完善
        }
    }
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // 侧边栏：设置选项
            List {
                Section("棋盘") {
                    Picker("类型", selection: $config.boardType) {
                        ForEach(BoardType.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    
                    if config.boardType == .hexagon {
                        Stepper("半径: \(config.radius)", value: $config.radius, in: 3...5)
                    }
                }
                
                Section("初始布局") {
                    Picker("布局", selection: $config.layoutIndex) {
                        ForEach(0..<layoutNames.count, id: \.self) { index in
                            Text(layoutNames[index]).tag(index)
                        }
                    }
                }
                
                Section("功能") {
                    Toggle("显示合法落子点", isOn: $config.showLegalMoves)
                    Toggle("预览翻转效果", isOn: $config.showPreview)
                    Toggle("允许撤销", isOn: $config.enableUndo)
                }
                
                Section {
                    Button("开始游戏") {
                        detail = .game(config)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("游戏设置")
        } detail: {
                GameView(config: config, onBack: {
                    withAnimation {
                        detail = .welcome
                    }
                })
        }
        .navigationSplitViewStyle(.balanced)
    }
}

import SwiftUI

enum DetailView {
    case welcome
    case game(GameConfig)
}

struct SettingView: View {
    @State private var config = GameConfig()
    @State private var detail: DetailView = .welcome
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    
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
                    // 使用 BoardType 的 layoutNames 获取名称列表
                    let layoutNames = config.boardType.layoutNames
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
            // 根据 detail 值展示不同视图
            switch detail {
            case .welcome:
                VStack {
                    Image(systemName: "triangle.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.accentColor)
                        .padding()
                    Text("选择设置后开始游戏")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
            case .game(let gameConfig):
                GameView(config: gameConfig, onBack: {
                    withAnimation {
                        detail = .welcome
                    }
                })
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}

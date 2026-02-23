import SwiftUI

struct SettingView: View {
    @StateObject private var previewState = PreviewBoardState()
    @State private var config = GameConfig() // 用于最终游戏
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    @State private var showingGame = false

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
                    .onChange(of: config.boardType) { newType in
                        previewState.boardType = newType
                    }

                    // 大小选择器（分段控件）
                    Picker("大小", selection: $previewState.sizeLevel) {
                        ForEach(SizeLevel.allCases) { level in
                            Text(level.name).tag(level)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("初始布局") {
                    let layoutNames = previewState.boardType.layoutNames
                    Picker("布局", selection: $previewState.layoutIndex) {
                        ForEach(0..<layoutNames.count, id: \.self) { index in
                            Text(layoutNames[index]).tag(index)
                        }
                    }
                }

                Section("功能") {
                    Toggle("显示合法落子点", isOn: $previewState.showLegalMoves)
                    Toggle("预览翻转效果", isOn: $config.showPreview)
                    Toggle("允许撤销", isOn: $config.enableUndo)
                }

                Section {
                    Button("开始游戏") {
                        // 将预览状态同步到 config
                        config.boardType = previewState.boardType
                        config.radius = previewState.radius
                        config.layoutIndex = previewState.layoutIndex
                        showingGame = true
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("游戏设置")
        } detail: {
            // 详情区：预览棋盘
            VStack {
                PreviewBoardView(state: previewState)
                    .aspectRatio(1, contentMode: .fit)
                    .padding()

                Text("预览棋盘")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
        }
        .navigationSplitViewStyle(.balanced)
        .fullScreenCover(isPresented: $showingGame) {
            NavigationStack {
                GameView(config: config) {
                    showingGame = false
                }
            }
        }
    }
}

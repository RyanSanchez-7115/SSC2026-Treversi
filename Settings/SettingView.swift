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
                Section("Board") {
                    
                    let layoutNames = previewState.boardType.layoutNames
                    
                    Picker("Type", selection: $config.boardType) {
                        ForEach(BoardType.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .onChange(of: config.boardType) { newType in
                        previewState.boardType = newType
                    }
                    .pickerStyle(.automatic)
                    
                    Picker("Size", selection: $previewState.sizeLevel) {
                        ForEach(previewState.availableSizeLevels) { level in
                            Text(level.name).tag(level)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Picker("Initial Layout", selection: $previewState.layoutIndex) {
                        ForEach(0..<layoutNames.count, id: \.self) { index in
                            Text(layoutNames[index]).tag(index)
                        }
                    }
                    .pickerStyle(.automatic)
                }

                Section("Features") {
                    Toggle("Show Legal Moves", isOn: $previewState.showLegalMoves)
                    Toggle("Preview Moves", isOn: $config.showPreview)
                    Toggle("Enable Undo", isOn: $config.enableUndo)
                }

                Section {
                    Button("Start Game") {
                        config.boardType = previewState.boardType
                        config.radius = previewState.radius
                        config.layoutIndex = previewState.layoutIndex
                        config.showLegalMoves = previewState.showLegalMoves
                        showingGame = true
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Game Settings")
        } detail: {
            // 详情区：预览棋盘
            VStack {
                PreviewBoardView(state: previewState)
                    .aspectRatio(1, contentMode: .fit)
                    .padding()

                Text("Board Preview")
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

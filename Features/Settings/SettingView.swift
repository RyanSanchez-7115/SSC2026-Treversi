import SwiftUI

/**
 * @struct SettingView
 * @brief The main view for game settings.
 * @details This view uses a `NavigationSplitView` to organize its layout, with configurable
 *          settings on the left and a real-time board preview (`PreviewBoardView`) on the
 *          right. Users can configure the board type, size, initial layout, and special
 *          game features. After configuration, tapping the "Start Game" button will
 *          enter the game screen with the selected configuration.
 */
struct SettingView: View {
    /// An `ObservableObject` that manages the state and logic of the board preview.
    @StateObject private var previewState = PreviewBoardState()
    /// Stores the final game configuration to be passed to the game view.
    @State private var config = GameConfig()
    /// Controls the column visibility of the `NavigationSplitView` (e.g., how the sidebar and detail panes are displayed).
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    /// Controls whether the `GameView` is shown in a full-screen modal.
    @State private var showingGame = false

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // Sidebar: Contains all game setting options.
            List {
                Section(header: Text("Board").font(.system(size: 25, weight: .semibold))) {

                    let layoutNames = previewState.boardType.layoutNames

                    // Board type picker
                    Picker("Type", selection: $config.boardType) {
                        ForEach(BoardType.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .onChange(of: config.boardType) { newType in
                        previewState.boardType = newType
                    }
                    .pickerStyle(.automatic)

                    // Board size picker
                    Picker("Size", selection: $previewState.sizeLevel) {
                        ForEach(previewState.availableSizeLevels) { level in
                            Text(level.name).tag(level)
                        }
                    }
                    .pickerStyle(.segmented)

                    // Initial layout picker
                    Picker("Initial Layout", selection: $previewState.layoutIndex) {
                        ForEach(0..<layoutNames.count, id: \.self) { index in
                            Text(layoutNames[index]).tag(index)
                        }
                    }
                    .pickerStyle(.automatic)
                }

                Section(header: Text("Features").font(.system(size: 25, weight: .semibold))) {
                    Toggle("Show Legal Moves", isOn: $previewState.showLegalMoves)
                    Toggle("Preview Moves", isOn: $config.showPreview)
                    Toggle("Enable Undo", isOn: $config.enableUndo)
                }

                Section(header: Text("Special Piece").font(.system(size: 25, weight: .semibold))) {
                    // Neutral pieces toggle
                    Toggle("Neutral Pieces", isOn: $config.enableNeutral)
                        .onChange(of: config.enableNeutral) { newValue in
                            previewState.enableNeutral = newValue
                        }

                    // Directional pieces toggle
                    Toggle("Directional Pieces", isOn: $config.enableDirectional)
                        .onChange(of: config.enableDirectional) { newValue in
                            previewState.enableDirectional = newValue
                        }
                }

                Section {
                    // Start Game button
                    Button("Start Game") {
                        // Before starting the game, sync the final configuration from the preview state to the game config object
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
            // Detail area: Displays the board preview.
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
            // Present the game view as a full-screen modal
            NavigationStack {
                GameView(config: config) {
                    // Callback to close the game view
                    showingGame = false
                }
            }
        }
    }
}

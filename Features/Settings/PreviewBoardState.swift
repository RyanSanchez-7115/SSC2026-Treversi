import SwiftUI

/**
 * @enum SizeLevel
 * @brief Defines the size levels for the game board.
 * @details Provides small and medium (labeled as Large in the UI) sizes.
 */
enum SizeLevel: Int, CaseIterable, Identifiable {
    case small = 0
    case medium = 1  // current max size

    /// The unique identifier for the `Identifiable` protocol.
    var id: Int { rawValue }

    /// The name to be displayed in the UI.
    var name: String {
        switch self {
        case .small: return "Small"
        case .medium: return "Large"  // label as Large
        }
    }
}

/**
 * @class PreviewBoardState
 * @brief Manages the state and logic for the preview board in the settings screen.
 * @details This is an `ObservableObject` responsible for handling all user changes to the board type,
 *          size, layout, and special piece display, as well as computing and caching legal moves.
 */
class PreviewBoardState: ObservableObject {
    // MARK: - Board Settings

    /// The currently selected board type (hexagon, diamond, triangle).
    @Published var boardType: BoardType = .hexagon { didSet { handleBoardTypeChange() } }
    /// The currently selected board size level.
    @Published var sizeLevel: SizeLevel = .small { didSet { handleSizeLevelChange() } }
    /// The currently selected initial layout index for the board.
    @Published var layoutIndex: Int = 0 { didSet { handleLayoutIndexChange() } }

    // MARK: - Display Toggles

    /// Whether to show hints for legal move positions.
    @Published var showLegalMoves: Bool = true
    /// Whether to enable neutral pieces.
    @Published var enableNeutral: Bool = true { didSet { handleSpecialToggleChange() } }
    /// Whether to enable directional pieces.
    @Published var enableDirectional: Bool = true { didSet { handleSpecialToggleChange() } }

    // MARK: - Computed & Animation State

    /// The current board radius, calculated from `sizeLevel`.
    @Published private(set) var radius: Int = 3
    /// A flag indicating if a layout change animation is in progress.
    @Published var isAnimating: Bool = false
    /// The set of currently calculated legal move positions.
    @Published private(set) var legalMoves: Set<TriangleCoordinate> = []
    /// A flag indicating if legal moves are being computed asynchronously.
    @Published var isComputingLegalMoves: Bool = false

    // MARK: - Private Helpers

    /// The duration for animations after a layout change.
    private let animationDuration: TimeInterval = 0.6
    /// A `DispatchWorkItem` for delayed execution of legal move computation.
    private var pendingWorkItem: DispatchWorkItem?

    /// Pre-created instance of a hexagon board at its maximum size.
    private let hexagonBoard = HexagonBoard(radius: 5)
    /// Pre-created instance of a diamond board at its maximum size.
    private let diamondBoard = DiamondBoard(radius: 4)
    /// Pre-created instance of a triangle board at its maximum size.
    private let triangleBoard = TriangleBoard(radius: 4)

    // MARK: - Computed Properties

    /// A list of available size levels for the current board type.
    var availableSizeLevels: [SizeLevel] {
        switch boardType {
        case .triangle: return [.small, .medium]
        default: return SizeLevel.allCases
        }
    }

    /// All coordinates for the current board type at its maximum radius.
    var allCoordinates: Set<TriangleCoordinate> {
        switch boardType {
        case .hexagon: return hexagonBoard.allCoordinates
        case .diamond: return diamondBoard.allCoordinates
        case .triangle: return triangleBoard.allCoordinates
        }
    }

    /// The board geometry for the currently selected radius.
    private var currentGeometry: BoardGeometry {
        switch boardType {
        case.hexagon: return HexagonBoard(radius: radius)
        case .diamond: return DiamondBoard(radius: radius)
        case .triangle: return TriangleBoard(radius: radius)
        }
    }

    /// The original (unfiltered) layout for the current layout index.
    private var originalLayout: [TriangleCoordinate: Piece] {
        let layouts: [[TriangleCoordinate: Piece]]
        switch boardType {
        case .hexagon: layouts = HexagonBoard.layouts
        case .diamond: layouts = DiamondBoard.layouts
        case .triangle: layouts = TriangleBoard.layouts
        }
        guard layoutIndex < layouts.count else { return [:] }
        return layouts[layoutIndex]
    }

    /// The layout after being filtered by the special piece toggles.
    private var filteredLayout: [TriangleCoordinate: Piece] = [:]
    /// The final current layout for the view to use.
    var currentLayout: [TriangleCoordinate: Piece] { filteredLayout }

    init() {
        updateRadiusFromSizeLevel()
        updateFilteredLayout()
        updateLegalMoves()
    }

    // MARK: - Change Handlers

    /// Handles the logic for a board type change.
    private func handleBoardTypeChange() {
        updateRadiusFromSizeLevel()
        handleLayoutChange()
    }

    /// Handles the logic for a board size change.
    private func handleSizeLevelChange() {
        updateRadiusFromSizeLevel()
        handleLayoutChange()
    }

    /// Handles the logic for a layout index change.
    private func handleLayoutIndexChange() {
        handleLayoutChange()
    }

    /// Handles the logic for a special piece toggle change.
    private func handleSpecialToggleChange() {
        handleLayoutChange()
    }

    /**
     * @brief Unified handler for all changes that can affect the layout and legal moves.
     * @details Flow: Immediately clear highlights -> Update and trigger piece animations -> Delay update of legal moves.
     */
    private func handleLayoutChange() {
        legalMoves = []          // clear immediately
        updateFilteredLayout()   // trigger piece flip animations
        isAnimating = true

        pendingWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            self.updateLegalMoves()
            self.isAnimating = false
            self.pendingWorkItem = nil
        }
        pendingWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration, execute: workItem)
    }

    // MARK: - Radius Calculation

    /// Updates the `radius` property based on the current `sizeLevel`.
    private func updateRadiusFromSizeLevel() {
        radius = radiusFor(boardType: boardType, sizeLevel: sizeLevel)
    }

    /**
     * @brief Returns the corresponding radius for a given board type and size level.
     * @param boardType The type of the board.
     * @param sizeLevel The size level.
     * @return An integer radius value.
     */
    private func radiusFor(boardType: BoardType, sizeLevel: SizeLevel) -> Int {
        switch boardType {
        case .hexagon:
            switch sizeLevel {
            case .small: return 3
            case .medium: return 4
            }
        case .diamond:
            switch sizeLevel {
            case .small: return 2
            case .medium: return 3
            }
        case .triangle:
            switch sizeLevel {
            case .small: return 2
            case .medium: return 3
            }
        }
    }

    // MARK: - Layout Filtering

    /// Filters the original layout based on the `enableNeutral` and `enableDirectional` toggles.
    private func updateFilteredLayout() {
        var layout = originalLayout
        for (coord, piece) in layout {
            var finalPiece = piece
            if !enableNeutral && piece == .neutral {
                finalPiece = .empty
            }
            if !enableDirectional && piece.directionalDirection != nil {
                finalPiece = .empty
            }
            layout[coord] = finalPiece
        }
        filteredLayout = layout
        objectWillChange.send()  // force view refresh
    }

    // MARK: - Legal Moves Calculation & Caching

    /**
     * @struct CacheKey
     * @brief A key for caching legal move positions.
     */
    private struct CacheKey: Hashable {
        let boardType: BoardType
        let sizeLevel: SizeLevel
        let layoutIndex: Int
        let enableNeutral: Bool
        let enableDirectional: Bool
    }

    /// A cache dictionary for legal move positions.
    private var legalMovesCache: [CacheKey: Set<TriangleCoordinate>] = [:]

    /// Updates the legal moves, using the cache if possible.
    private func updateLegalMoves() {
        isComputingLegalMoves = true

        let key = CacheKey(
            boardType: boardType,
            sizeLevel: sizeLevel,
            layoutIndex: layoutIndex,
            enableNeutral: enableNeutral,
            enableDirectional: enableDirectional
        )

        if let cached = legalMovesCache[key] {
            legalMoves = cached
            isComputingLegalMoves = false
            return
        }

        let geometry = currentGeometry
        var boardState: [TriangleCoordinate: Piece] = [:]
        for coord in geometry.allCoordinates {
            boardState[coord] = currentLayout[coord] ?? .empty
        }

        let computed = GameState.legalMoves(for: .black, board: boardState, geometry: geometry)
        legalMovesCache[key] = computed
        legalMoves = computed
        isComputingLegalMoves = false
    }

    // MARK: - Helpers

    /**
     * @brief Checks if a given coordinate is within the currently selected radius.
     * @param coord The coordinate to check.
     * @return Returns `true` if the coordinate is within the radius.
     */
    func isWithinRadius(_ coord: TriangleCoordinate) -> Bool {
        switch boardType {
        case .hexagon: return hexagonBoard.isCoordinate(coord, withinRadius: radius)
        case .diamond: return diamondBoard.isCoordinate(coord, withinRadius: radius)
        case .triangle: return triangleBoard.isCoordinate(coord, withinRadius: radius)
        }
    }
}

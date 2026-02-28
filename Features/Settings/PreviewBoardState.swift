import SwiftUI

enum SizeLevel: Int, CaseIterable, Identifiable {
    case small = 0
    case medium = 1  // current max size

    var id: Int { rawValue }

    var name: String {
        switch self {
        case .small: return "Small"
        case .medium: return "Large"  // label as Large
        }
    }
}

class PreviewBoardState: ObservableObject {
    // Board settings
    @Published var boardType: BoardType = .hexagon { didSet { handleBoardTypeChange() } }
    @Published var sizeLevel: SizeLevel = .small { didSet { handleSizeLevelChange() } }
    @Published var layoutIndex: Int = 0 { didSet { handleLayoutIndexChange() } }

    // Display toggles
    @Published var showLegalMoves: Bool = true
    @Published var enableNeutral: Bool = true { didSet { handleSpecialToggleChange() } }
    @Published var enableDirectional: Bool = true { didSet { handleSpecialToggleChange() } }

    // Computed / animation state
    @Published private(set) var radius: Int = 3
    @Published var isAnimating: Bool = false
    @Published private(set) var legalMoves: Set<TriangleCoordinate> = []
    @Published var isComputingLegalMoves: Bool = false

    // Animation and async helpers
    private let animationDuration: TimeInterval = 0.6
    private var pendingWorkItem: DispatchWorkItem?

    // Base boards (max radius)
    private let hexagonBoard = HexagonBoard(radius: 5)
    private let diamondBoard = DiamondBoard(radius: 4)
    private let triangleBoard = TriangleBoard(radius: 4)

    // Available size levels per board
    var availableSizeLevels: [SizeLevel] {
        switch boardType {
        case .triangle: return [.small, .medium]
        default: return SizeLevel.allCases
        }
    }

    // All coordinates for the current board type (at max radius)
    var allCoordinates: Set<TriangleCoordinate> {
        switch boardType {
        case .hexagon: return hexagonBoard.allCoordinates
        case .diamond: return diamondBoard.allCoordinates
        case .triangle: return triangleBoard.allCoordinates
        }
    }

    // Current geometry at selected radius
    private var currentGeometry: BoardGeometry {
        switch boardType {
        case.hexagon: return HexagonBoard(radius: radius)
        case .diamond: return DiamondBoard(radius: radius)
        case .triangle: return TriangleBoard(radius: radius)
        }
    }

    // Original layout (unfiltered)
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

    // Filtered layout (after toggles)
    private var filteredLayout: [TriangleCoordinate: Piece] = [:]
    var currentLayout: [TriangleCoordinate: Piece] { filteredLayout }

    init() {
        updateRadiusFromSizeLevel()
        updateFilteredLayout()
        updateLegalMoves()
    }

    // MARK: - Change handlers

    private func handleBoardTypeChange() {
        updateRadiusFromSizeLevel()
        handleLayoutChange()
    }

    private func handleSizeLevelChange() {
        updateRadiusFromSizeLevel()
        handleLayoutChange()
    }

    private func handleLayoutIndexChange() {
        handleLayoutChange()
    }

    private func handleSpecialToggleChange() {
        handleLayoutChange()
    }

    /// Unified change handling: clear highlights, update layout, animate, then recompute highlights.
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

    // MARK: - Radius

    private func updateRadiusFromSizeLevel() {
        radius = radiusFor(boardType: boardType, sizeLevel: sizeLevel)
    }

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

    // MARK: - Layout filtering

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

    // MARK: - Legal moves with caching

    private struct CacheKey: Hashable {
        let boardType: BoardType
        let sizeLevel: SizeLevel
        let layoutIndex: Int
        let enableNeutral: Bool
        let enableDirectional: Bool
    }

    private var legalMovesCache: [CacheKey: Set<TriangleCoordinate>] = [:]

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

    func isWithinRadius(_ coord: TriangleCoordinate) -> Bool {
        switch boardType {
        case .hexagon: return hexagonBoard.isCoordinate(coord, withinRadius: radius)
        case .diamond: return diamondBoard.isCoordinate(coord, withinRadius: radius)
        case .triangle: return triangleBoard.isCoordinate(coord, withinRadius: radius)
        }
    }
}

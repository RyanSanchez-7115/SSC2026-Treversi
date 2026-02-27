import SwiftUI
enum SizeLevel: Int, CaseIterable, Identifiable {
    case small = 0
    case medium = 1  // 现在是最大尺寸
    var id: Int { rawValue }
    var name: String {
        switch self {
        case .small: return "Small"
        case .medium: return "Large"  // 改名字为 Large
        }
    }
}
class PreviewBoardState: ObservableObject {
    @Published var boardType: BoardType = .hexagon { didSet { handleBoardTypeChange() } }
    @Published var sizeLevel: SizeLevel = .small { didSet { handleSizeLevelChange() } }
    @Published var layoutIndex: Int = 0 { didSet { handleLayoutIndexChange() } }
    @Published var showLegalMoves: Bool = true
    // 开关属性
    @Published var enableNeutral: Bool = true { didSet { handleSpecialToggleChange() } }
    @Published var enableDirectional: Bool = true { didSet { handleSpecialToggleChange() } }
    @Published private(set) var radius: Int = 3
    @Published var isAnimating: Bool = false
    @Published private(set) var legalMoves: Set<TriangleCoordinate> = []
    @Published var isComputingLegalMoves = false  // 计算中标志
    private let animationDuration: TimeInterval = 0.6
    private var pendingWorkItem: DispatchWorkItem?
    private let hexagonBoard = HexagonBoard(radius: 5)
    private let diamondBoard = DiamondBoard(radius: 4)
    private let triangleBoard = TriangleBoard(radius: 4)
    var availableSizeLevels: [SizeLevel] {
        switch boardType {
        case .triangle: return [.small, .medium]
        default: return SizeLevel.allCases
        }
    }
    var allCoordinates: Set<TriangleCoordinate> {
        switch boardType {
        case .hexagon: return hexagonBoard.allCoordinates
        case .diamond: return diamondBoard.allCoordinates
        case .triangle: return triangleBoard.allCoordinates
        }
    }
    // 当前几何（计算属性）
        private var currentGeometry: BoardGeometry {
            switch boardType {
            case .hexagon: return HexagonBoard(radius: radius)
            case .diamond: return DiamondBoard(radius: radius)
            case .triangle: return TriangleBoard(radius: radius)
            }
        }
    // 原始布局（无过滤）
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
    // 过滤后的布局
    private var filteredLayout: [TriangleCoordinate: Piece] = [:]
    var currentLayout: [TriangleCoordinate: Piece] {
        filteredLayout
    }
    init() {
        updateRadiusFromSizeLevel()
        updateFilteredLayout()
        updateLegalMoves()
    }
    private func handleBoardTypeChange() {
        sizeLevel = .small
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
    // 统一变化处理：清高亮 + 过滤布局 + 延迟重算高亮
    private func handleLayoutChange() {
        // 1. 立即清空高亮
        legalMoves = []
        // 2. 更新过滤布局（触发棋子翻转动画）
        updateFilteredLayout()
        // 3. 设置动画标志
        isAnimating = true
        // 4. 延迟动画结束重算高亮
        pendingWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.updateLegalMoves()
            self.isAnimating = false
            self.pendingWorkItem = nil
        }
        pendingWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration, execute: workItem)
    }
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
    // 核心过滤函数
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
        objectWillChange.send()  // 强制视图更新
    }
    // MARK: - 缓存机制
    private struct CacheKey: Hashable {
        let boardType: BoardType
        let sizeLevel: SizeLevel
        let layoutIndex: Int
        let enableNeutral: Bool
        let enableDirectional: Bool  // 缓存加开关，避免开关变化不命中缓存
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
    func isWithinRadius(_ coord: TriangleCoordinate) -> Bool {
        switch boardType {
        case .hexagon: return hexagonBoard.isCoordinate(coord, withinRadius: radius)
        case .diamond: return diamondBoard.isCoordinate(coord, withinRadius: radius)
        case .triangle: return triangleBoard.isCoordinate(coord, withinRadius: radius)
        }
    }
}

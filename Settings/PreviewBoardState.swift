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
    @Published var boardType: BoardType = .hexagon{ didSet { handleBoardTypeChange() } }
    @Published var sizeLevel: SizeLevel = .small{ didSet { handleSizeLevelChange() } }
    @Published var layoutIndex: Int = 0 { didSet { handleLayoutIndexChange() } }
    @Published var showLegalMoves: Bool = true
    @Published private(set) var legalMoves: Set<TriangleCoordinate> = []
    @Published private(set) var radius: Int = 3
    @Published var isAnimating: Bool = false
    private let animationDuration: TimeInterval = 0.6
    private var pendingWorkItem: DispatchWorkItem?
  
    private let hexagonBoard = HexagonBoard(radius: 4)
    private let diamondBoard = DiamondBoard(radius: 3)
    private let triangleBoard = TriangleBoard(radius: 4)
    
    
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
    // MARK: - 缓存机制（彻底解决切换卡顿）
    private struct CacheKey: Hashable {
        let boardType: BoardType
        let sizeLevel: SizeLevel
        let layoutIndex: Int
    }

    private var legalMovesCache: [CacheKey: Set<TriangleCoordinate>] = [:]
    
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

    private var currentGeometry: BoardGeometry {
        switch boardType {
        case .hexagon: return HexagonBoard(radius: radius)
        case .diamond: return DiamondBoard(radius: radius)
        case .triangle: return TriangleBoard(radius: radius)
        }
    }
    
    var currentLayout: [TriangleCoordinate: Piece] {
        let layouts: [[TriangleCoordinate: Piece]]
        switch boardType {
        case .hexagon: layouts = HexagonBoard.layouts
        case .diamond: layouts = DiamondBoard.layouts
        case .triangle: layouts = TriangleBoard.layouts
        }
        guard layoutIndex < layouts.count else { return [:] }
        return layouts[layoutIndex]
    }
    

    init() {
        updateRadiusFromSizeLevel()
        updateLegalMoves()
    }

    private func handleBoardTypeChange() {
        sizeLevel = .small  // 切换棋盘类型时，默认回小尺寸
        updateRadiusFromSizeLevel()
        updateLegalMoves()
    }

    private func handleSizeLevelChange() {
        updateRadiusFromSizeLevel()
        updateLegalMoves()
    }

    private func handleLayoutIndexChange() {
        isAnimating = true
        pendingWorkItem?.cancel()
        scheduleLegalMovesUpdate(after: animationDuration)
    }
    
    private func updateRadiusFromSizeLevel() {
        radius = radiusFor(boardType: boardType, sizeLevel: sizeLevel)
    }

    private func scheduleLegalMovesUpdate(after delay: TimeInterval) {
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.updateLegalMoves()
            self.isAnimating = false
            self.pendingWorkItem = nil
        }
        pendingWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }

    private func updateLegalMoves() {
        let key = CacheKey(
            boardType: boardType,
            sizeLevel: sizeLevel,
            layoutIndex: layoutIndex
        )
        
        // 1. 命中缓存 → 瞬间返回
        if let cached = legalMovesCache[key] {
            legalMoves = cached
            return
        }
        
        // 2. 未命中 → 计算并缓存
        let geometry = currentGeometry
        var boardState: [TriangleCoordinate: Piece] = [:]
        for coord in geometry.allCoordinates {
            boardState[coord] = currentLayout[coord] ?? .empty
        }
        
        let computed = GameState.legalMoves(for: .black, board: boardState, geometry: geometry)
        
        // 存缓存
        legalMovesCache[key] = computed
        legalMoves = computed
    }

    func isWithinRadius(_ coord: TriangleCoordinate) -> Bool {
        switch boardType {
        case .hexagon: return hexagonBoard.isCoordinate(coord, withinRadius: radius)
        case .diamond: return diamondBoard.isCoordinate(coord, withinRadius: radius)
        case .triangle: return triangleBoard.isCoordinate(coord, withinRadius: radius)
        }
    }
}

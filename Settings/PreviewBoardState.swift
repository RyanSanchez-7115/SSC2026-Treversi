import SwiftUI
import Combine

enum SizeLevel: Int, CaseIterable, Identifiable {
    case small = 0
    case medium = 1
    case large = 2

    var id: Int { rawValue }
    var name: String {
        switch self {
        case .small: return "Small"
        case .medium: return "Medium"
        case .large: return "Large"
        }
    }
}


class PreviewBoardState: ObservableObject {
    // 用户可调节的配置
    @Published var boardType: BoardType = .diamond {
        didSet { handleBoardTypeChange() }
    }
    @Published var sizeLevel: SizeLevel = .medium {
        didSet { handleSizeLevelChange() }
    }
    @Published var layoutIndex: Int = 0 {
        didSet { handleLayoutIndexChange() }
    }
    @Published var showLegalMoves: Bool = true

    // 实际半径值（由 sizeLevel 和 boardType 共同决定）
    @Published private(set) var radius: Int = 3

    // 动画状态（仅布局变化时使用）
    @Published var isAnimating: Bool = false
    private let animationDuration: TimeInterval = 0.6
    private var pendingWorkItem: DispatchWorkItem?

    // 固定最大半径（用于生成所有坐标，保持视图稳定）
    let maxRadius = 5

    // 不同棋盘类型的最大半径几何体（用于获取所有坐标和范围判断）
    private let hexagonBoard = HexagonBoard(radius: 5)
    private let diamondBoard = DiamondBoard(radius: 4)
    private let triangleBoard = TriangleBoard(radius: 4)
    
    // 根据当前棋盘类型返回可用的尺寸级别
        var availableSizeLevels: [SizeLevel] {
            switch boardType {
            case .triangle:
                return [.small, .large]
            default:
                return SizeLevel.allCases
            }
        }

    // 当前棋盘的所有坐标（基于最大半径）
    var allCoordinates: Set<TriangleCoordinate> {
        switch boardType {
        case .hexagon:
            return hexagonBoard.allCoordinates
        case .diamond:
            return diamondBoard.allCoordinates
        case .triangle:
            return triangleBoard.allCoordinates
        }
    }

    // 当前棋盘的几何体（用于合法移动计算，半径动态）
    private var currentGeometry: BoardGeometry {
        switch boardType {
        case .hexagon:
            return HexagonBoard(radius: radius)
        case .diamond:
            return DiamondBoard(radius: radius)
        case .triangle:
            return TriangleBoard(radius: radius)
        }
    }

    // 当前布局（从对应棋盘的 layouts 获取）
    var currentLayout: [TriangleCoordinate: Player] {
        let layouts: [[TriangleCoordinate: Player]]
        switch boardType {
        case .hexagon:
            layouts = HexagonBoard.layouts
        case .diamond:
            layouts = DiamondBoard.layouts
        case .triangle:
            layouts = TriangleBoard.layouts
        }
        guard layoutIndex < layouts.count else { return [:] }
        return layouts[layoutIndex]
    }
    

    @Published private(set) var legalMoves: Set<TriangleCoordinate> = []

    init() {
        updateRadiusFromSizeLevel()
        updateLegalMoves()
    }

    // MARK: - 变化处理
    private func handleBoardTypeChange() {
        // 如果切换到三角形棋盘且当前为 medium，自动切换到 small
        if boardType == .triangle && sizeLevel == .medium {
            sizeLevel = .small
        }
        updateRadiusFromSizeLevel()
        updateLegalMoves()
    }

    private func handleSizeLevelChange() {
        // 立即更新半径
        updateRadiusFromSizeLevel()
        // 立即更新合法移动（无动画）
        updateLegalMoves()
    }

    private func handleLayoutIndexChange() {
        // 布局变化需要动画延迟
        isAnimating = true
        pendingWorkItem?.cancel()
        scheduleLegalMovesUpdate(after: animationDuration)
    }
    
    // MARK: - 辅助方法
    private func updateRadiusFromSizeLevel() {
        radius = radiusFor(boardType: boardType, sizeLevel: sizeLevel)
    }

    private func radiusFor(boardType: BoardType, sizeLevel: SizeLevel) -> Int {
        switch boardType {
        case .hexagon:
            switch sizeLevel {
            case .small: return 3
            case .medium: return 4
            case .large: return 5
            }
        case .diamond:
            switch sizeLevel {
            case .small: return 2
            case .medium: return 3
            case .large: return 4
            }
        case .triangle:
            switch sizeLevel {
            case .small: return 2
            case .medium: return 3
            case .large: return 4 
            }
        }
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
        let geometry = currentGeometry
        var boardState: [TriangleCoordinate: Player] = [:]
        for coord in geometry.allCoordinates {
            boardState[coord] = currentLayout[coord] ?? .empty
        }
        legalMoves = GameState.legalMoves(for: .black, board: boardState, geometry: geometry)
    }

    // 判断坐标是否在当前半径内
    func isWithinRadius(_ coord: TriangleCoordinate) -> Bool {
        switch boardType {
        case .hexagon:
            return hexagonBoard.isCoordinate(coord, withinRadius: radius)
        case .diamond:
            return diamondBoard.isCoordinate(coord, withinRadius: radius)
        case .triangle:
            return triangleBoard.isCoordinate(coord, withinRadius: radius)
        }
    }
}

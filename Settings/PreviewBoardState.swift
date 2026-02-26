import SwiftUI

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
    @Published var boardType: BoardType = .diamond { didSet { handleBoardTypeChange() } }
    @Published var sizeLevel: SizeLevel = .medium { didSet { handleSizeLevelChange() } }
    @Published var layoutIndex: Int = 0 { didSet { handleLayoutIndexChange() } }
    @Published var showLegalMoves: Bool = true

    @Published private(set) var radius: Int = 3
    @Published var isAnimating: Bool = false
    private let animationDuration: TimeInterval = 0.6
    private var pendingWorkItem: DispatchWorkItem?
    @Published var isLayoutAnimating = false

    let maxRadius = 5
    private let hexagonBoard = HexagonBoard(radius: 5)
    private let diamondBoard = DiamondBoard(radius: 4)
    private let triangleBoard = TriangleBoard(radius: 4)
    
    var availableSizeLevels: [SizeLevel] {
        switch boardType {
        case .triangle: return [.small, .large]
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
    
    @Published private(set) var legalMoves: Set<TriangleCoordinate> = []

    init() {
        updateRadiusFromSizeLevel()
        updateLegalMoves()
    }

    private func handleBoardTypeChange() {
        if boardType == .triangle && sizeLevel == .medium { sizeLevel = .small }
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

    private func radiusFor(boardType: BoardType, sizeLevel: SizeLevel) -> Int {
        switch boardType {
        case .hexagon:
            switch sizeLevel { case .small: return 3; case .medium: return 4; case .large: return 5 }
        case .diamond:
            switch sizeLevel { case .small: return 2; case .medium: return 3; case .large: return 4 }
        case .triangle:
            switch sizeLevel { case .small: return 2; case .medium: return 3; case .large: return 4 }
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
        var boardState: [TriangleCoordinate: Piece] = [:]
        for coord in geometry.allCoordinates {
            boardState[coord] = currentLayout[coord] ?? .empty
        }
        legalMoves = GameState.legalMoves(for: .black, board: boardState, geometry: geometry)
    }

    func isWithinRadius(_ coord: TriangleCoordinate) -> Bool {
        switch boardType {
        case .hexagon: return hexagonBoard.isCoordinate(coord, withinRadius: radius)
        case .diamond: return diamondBoard.isCoordinate(coord, withinRadius: radius)
        case .triangle: return triangleBoard.isCoordinate(coord, withinRadius: radius)
        }
    }
}

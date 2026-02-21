import Foundation

// MARK: - 游戏状态引擎（核心大脑）
/// 管理棋盘状态、当前玩家、历史记录，并执行所有游戏规则计算。
class GameState: ObservableObject {
    
    // MARK: - 发布属性（驱动UI更新）
    /// 当前棋盘状态：每个坐标上的棋子归属
    @Published private(set) var board: [TriangleCoordinate: Player]
    /// 当前行动方
    @Published private(set) var currentPlayer: Player
    /// 游戏是否已结束
    @Published private(set) var isGameOver: Bool = false
    /// 可用的合法落子位置（实时计算）
    @Published private(set) var legalMoves: Set<TriangleCoordinate> = []
    //动画状态
    @Published var isAnimating = false
        private let animationDuration: Double = 0.6  // 必须与 TriangleView 中的动画时长一致
        private var pendingAnimationWorkItem: DispatchWorkItem?
    // MARK: - 私有属性
    /// 棋盘几何定义，用于查询邻居等
     let geometry: BoardGeometry
    /// 历史记录，用于实现撤销功能
    var moveHistory: [(move: TriangleCoordinate, flipped: [TriangleCoordinate], player: Player)] = []
    
    // MARK: - 初始化
    /// 使用指定的棋盘几何和初始布局创建游戏状态
    init(geometry: BoardGeometry, initialOccupation: [TriangleCoordinate: Player]? = nil) {
        self.geometry = geometry
        // 初始化棋盘：所有位置默认为空
        var initialBoard: [TriangleCoordinate: Player] = [:]
        for coord in geometry.allCoordinates {
            initialBoard[coord] = .empty
        }
        // 应用自定义初始布局，或使用几何体提供的默认布局
        let layoutToApply = initialOccupation ?? geometry.initialOccupation
        for (coord, player) in layoutToApply {
            // 确保坐标在棋盘内df
            if geometry.allCoordinates.contains(coord) {
                initialBoard[coord] = player
            }
        }
        self.board = initialBoard
        
        // 默认由黑方开始（可根据规则调整）
        self.currentPlayer = .black
        
        // 计算初始合法移动
        self.recalculateLegalMoves()
        
        // 检查初始状态是否可能已结束
        self.checkGameOver()
    }
    
    // MARK: - 核心游戏逻辑
    
    /// 计算当前玩家的所有合法落子位置
    private func recalculateLegalMoves() {
        var moves = Set<TriangleCoordinate>()
        
        for coord in geometry.allCoordinates where board[coord] == .empty {
            let flipped = flippedCoordinatesIfPlace(at: coord, by: currentPlayer)
            if !flipped.isEmpty {
                moves.insert(coord)
            }
        }
        legalMoves = moves
    }
    /// **核心算法**：模拟在给定位置落子，返回将被翻转的棋子坐标数组。
    /// 如果返回数组为空，则表示落子无效。
    func flippedCoordinatesIfPlace(at coordinate: TriangleCoordinate, by player: Player) -> [TriangleCoordinate] {
        guard board[coordinate] == .empty else { return [] }
        
        var flipped: [TriangleCoordinate] = []
        let opponent = player.opponent
        
        // 定义6个方向的搜索函数
        let directions: [(Int, Int, Bool) -> (Int, Int, Bool)] = [
            // 水平左：q--，朝向翻转
            { (q, r, isUp) in return (q-1, r, !isUp) },
            // 水平右：q++，朝向翻转
            { (q, r, isUp) in return (q+1, r, !isUp) },
            // 左上：交替 q--, r++
            { (q, r, isUp) in
                if isUp {
                    return (q-1, r, !isUp)  // 第一步：q--
                } else {
                    return (q, r+1, !isUp)  // 第二步：r++
                }
            },
            // 左下：交替 r--, q--
            { (q, r, isUp) in
                if isUp {
                    return (q, r-1, !isUp)  // 第一步：r--
                } else {
                    return (q-1, r, !isUp)  // 第二步：q++
                }
            },
            // 右上：交替 q++, r++
            { (q, r, isUp) in
                if isUp {
                    return (q+1, r, !isUp)  // 第一步：q++
                } else {
                    return (q, r+1, !isUp)  // 第二步：r++
                }
            },
            // 右下：交替 r--, q++
            { (q, r, isUp) in
                if isUp {
                    return (q, r-1, !isUp)  // 第一步：q++
                } else {
                    return (q+1, r, !isUp)  // 第二步：r--
                }
            }
        ]
        
        // 检查每个方向
        for direction in directions {
            var toFlip: [TriangleCoordinate] = []
            var currentQ = coordinate.q
            var currentR = coordinate.r
            var currentIsUp = coordinate.isPointingUp
            
            // 沿着这个方向前进
            while true {
                // 应用方向函数得到下一个坐标
                let (nextQ, nextR, nextIsUp) = direction(currentQ, currentR, currentIsUp)
                let nextCoord = TriangleCoordinate(q: nextQ, r: nextR, isPointingUp: nextIsUp)
                
                // 检查是否在棋盘内
                guard geometry.allCoordinates.contains(nextCoord) else { break }
                
                let nextPlayer = board[nextCoord]
                
                if nextPlayer == opponent {
                    // 对手棋子，添加到可能翻转的列表
                    toFlip.append(nextCoord)
                    // 更新当前位置继续前进
                    currentQ = nextQ
                    currentR = nextR
                    currentIsUp = nextIsUp
                } else if nextPlayer == player && !toFlip.isEmpty {
                    // 己方棋子！成功夹击，这条线上的对手棋子都要翻转
                    flipped.append(contentsOf: toFlip)
                    break
                } else {
                    // 空位或无效，这条线无效
                    break
                }
            }
        }
        
        // 使用Set去除重复坐标
        return Array(Set(flipped))
    }
   
    /// 执行落子操作
    // 修改 makeMove 方法
        func makeMove(at coordinate: TriangleCoordinate) -> Bool {
            guard legalMoves.contains(coordinate) else {
                print("非法落子位置：\(coordinate)")
                return false
            }

            let flipped = flippedCoordinatesIfPlace(at: coordinate, by: currentPlayer)
            guard !flipped.isEmpty else {
                print("逻辑错误：合法落子但未翻转任何棋子")
                return false
            }

            // 记录历史（用于撤销）
            moveHistory.append((move: coordinate, flipped: flipped, player: currentPlayer))

            // 更新棋盘：放置己方棋子并翻转对手棋子
            board[coordinate] = currentPlayer
            for flippedCoord in flipped {
                board[flippedCoord] = currentPlayer
            }

            // 取消之前的延迟任务（防止多次点击）
            pendingAnimationWorkItem?.cancel()

            // 创建新的延迟任务
            let workItem = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                // 切换玩家
                self.currentPlayer = self.currentPlayer.opponent
                // 重新计算合法移动
                self.recalculateLegalMoves()
                // 检查游戏结束
                self.checkGameOver()
                // 动画结束
                self.isAnimating = false
                self.pendingAnimationWorkItem = nil
            }
            pendingAnimationWorkItem = workItem

            // 设置动画状态
            isAnimating = true

            // 延迟执行
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration, execute: workItem)

            //print("落子成功：\(coordinate)，翻转了 \(flipped.count) 个棋子")
            return true
        }

    
    /// 检查游戏是否应结束（双方都无合法移动时）
    private func checkGameOver() {
        // 如果当前玩家无棋可下，尝试让对方走
        if legalMoves.isEmpty {
            let opponent = currentPlayer.opponent
            // 临时检查对手是否有棋可下
            var opponentHasMoves = false
            for coord in geometry.allCoordinates where board[coord] == .empty {
                if !flippedCoordinatesIfPlace(at: coord, by: opponent).isEmpty {
                    opponentHasMoves = true
                    break
                }
            }
            
            // 如果对手也无棋可下，则游戏结束
            if !opponentHasMoves {
                isGameOver = true
                print("游戏结束！")
            } else {
                // 对手有棋可下，则跳过当前玩家
                print("\(currentPlayer) 无棋可下，回合跳过")
                currentPlayer = opponent
                recalculateLegalMoves()
            }
        }
    }
    
    /// 计算双方棋子数量
    func countPieces() -> (black: Int, white: Int) {
        var blackCount = 0
        var whiteCount = 0
        
        for (_, player) in board {
            switch player {
            case .black: blackCount += 1
            case .white: whiteCount += 1
            case .empty: break
            }
        }
        
        return (blackCount, whiteCount)
    }
    
    /// 获取获胜方（如果游戏结束）
    func winner() -> Player? {
        guard isGameOver else { return nil }
        let counts = countPieces()
        if counts.black > counts.white {
            return .black
        } else if counts.white > counts.black {
            return .white
        } else {
            return nil // 平局
        }
    }
    
    // MARK: - 游戏辅助功能
    /// 撤销上一步操作
    func undoMove() -> Bool {
        guard let lastMove = moveHistory.popLast() else {
            print("没有可以撤销的步骤")
            return false
        }
        guard !isAnimating else {
            return false
        }
        
        // 1. 恢复当前玩家
        currentPlayer = lastMove.player
        
        // 2. 移除放置的棋子
        board[lastMove.move] = .empty
        
        // 3. 恢复被翻转的棋子
        for flippedCoord in lastMove.flipped {
            board[flippedCoord] = lastMove.player.opponent
        }
        
        // 4. 重新计算合法移动
        recalculateLegalMoves()
        isGameOver = false
        
        print("已撤销在 \(lastMove.move) 的落子")
        return true
    }
    
    /// 重新开始游戏
    func restart() {
        // 重新初始化棋盘
        var newBoard: [TriangleCoordinate: Player] = [:]
        for coord in geometry.allCoordinates {
            newBoard[coord] = .empty
        }
        for (coord, player) in geometry.initialOccupation {
            if geometry.allCoordinates.contains(coord) {
                newBoard[coord] = player
            }
        }
        
        board = newBoard
        currentPlayer = .black
        moveHistory.removeAll()
        isGameOver = false
        recalculateLegalMoves()
        
        print("游戏已重新开始")
    }
    //预览
    func previewFlipped(at coordinate: TriangleCoordinate) -> [TriangleCoordinate] {
        return flippedCoordinatesIfPlace(at: coordinate, by: currentPlayer)
    }
}

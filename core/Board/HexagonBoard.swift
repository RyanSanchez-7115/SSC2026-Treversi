// MARK: - 通用六边形棋盘

struct HexagonBoard: BoardGeometry {
    
    let radius: Int
    var displayName: String { "经典六边形" }
    var description: String { "三角密铺的古老契约。" }
    
    var allCoordinates: Set<TriangleCoordinate> {
        var coords = Set<TriangleCoordinate>()
        for r in 0...(radius - 1){
            for q in -(radius*2 - 1 - r)...(radius*2 - 1 - r) {
                let s = -q - r
                coords.insert(TriangleCoordinate(q: q, r: r, isPointingUp: s % 2 == 0 ? false : true))
                }
            }
        for r in (-radius)...(-1) {
            for q in -(radius*2 + r)...(radius*2 + r) {
                let s = -q - r
                coords.insert(TriangleCoordinate(q: q, r: r, isPointingUp: s % 2 == 0 ? false : true))
            }
        }
        return coords
        }
    
    // MARK: - 邻居计算
    func neighbors(of coordinate: TriangleCoordinate) -> Set<TriangleCoordinate> {
        let (q, r, isUp) = (coordinate.q, coordinate.r, coordinate.isPointingUp)
        
        if isUp {
            // 朝上三角形的三个朝下邻居
            return [
                TriangleCoordinate(q: q, r: r - 1, isPointingUp: false),  // 正下方
                TriangleCoordinate(q: q - 1, r: r, isPointingUp: false),  // 左下方
                TriangleCoordinate(q: q + 1, r: r, isPointingUp: false)   // 右下方
            ]
        } else {
            // 朝下三角形的三个朝上邻居
            return [
                TriangleCoordinate(q: q, r: r + 1, isPointingUp: true),   // 正上方
                TriangleCoordinate(q: q - 1, r: r, isPointingUp: true),   // 左上方
                TriangleCoordinate(q: q + 1, r: r, isPointingUp: true)    // 右上方
            ]
        }
    }
        
    
    var initialOccupation: [TriangleCoordinate: Player] {
        
        var occupation: [TriangleCoordinate: Player] = [:]
        occupation[TriangleCoordinate(q: -1, r: -1, isPointingUp: false)] = .black
        occupation[TriangleCoordinate(q: 0, r: 0, isPointingUp: false)] = .black
        occupation[TriangleCoordinate(q: 1, r: -1, isPointingUp: false)] = .black
        occupation[TriangleCoordinate(q: -1, r: 0, isPointingUp: true)] = .white
        occupation[TriangleCoordinate(q: 1, r: 0, isPointingUp: true)] = .white
        occupation[TriangleCoordinate(q: 0, r: -1, isPointingUp: true)] = .white
        
        return occupation
    }
}

extension HexagonBoard {
    // 预定义的布局数组
    static let layouts: [[TriangleCoordinate: Player]] = [
        // 布局0：经典开局（你之前设计的6个棋子）
        [
            TriangleCoordinate(q: -1, r: -1, isPointingUp: false): .black,
            TriangleCoordinate(q: 0, r: 0, isPointingUp: false): .black,
            TriangleCoordinate(q: 1, r: -1, isPointingUp: false): .black,
            TriangleCoordinate(q: -1, r: 0, isPointingUp: true): .white,
            TriangleCoordinate(q: 1, r: 0, isPointingUp: true): .white,
            TriangleCoordinate(q: 0, r: -1, isPointingUp: true): .white
        ],
        // 布局1：非对称布局
        [
           
            //TriangleCoordinate(q: 0, r: 0, isPointingUp: false): .black,
            TriangleCoordinate(q: 1, r: -1, isPointingUp: false): .black,
            TriangleCoordinate(q: 1, r: 0, isPointingUp: true): .black,
            TriangleCoordinate(q: -1, r: 0, isPointingUp: true): .white,
            TriangleCoordinate(q: 0, r: -1, isPointingUp: true): .white,
            
        ],
        // 布局2：激进布局（可自行设计）
        [
            TriangleCoordinate(q: -1, r: -1, isPointingUp: false): .white,
            TriangleCoordinate(q: 1, r: -1, isPointingUp: false): .white,
            TriangleCoordinate(q: -2, r: 0, isPointingUp: false): .white,
            TriangleCoordinate(q: -1, r: 0, isPointingUp: true): .black,
  
        ]
    ]
    
    static let layoutNames: [String] = ["经典", "对称", "激进"]
}


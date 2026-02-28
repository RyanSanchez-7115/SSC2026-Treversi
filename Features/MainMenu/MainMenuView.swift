import SwiftUI

struct MainMenuView: View {
    @State private var pieceStates: [TriangleCoordinate: (color: Color, isRevealed: Bool)] = [:]
    @State private var currentLetterIndex = 0
    @State private var timer: Timer?

    // 生成棋盘所有坐标（与之前相同）
    private var demoAllCoordinates: Set<TriangleCoordinate> {
        var coords = Set<TriangleCoordinate>()
        for r in 0...2 {
            for q in -(20 - r)...(20 - r) {
                let s = -q - r
                coords.insert(TriangleCoordinate(q: q, r: r, isPointingUp: s % 2 != 0 ? false : true))
            }
        }
        for r in (-3)...(-1) {
            for q in -(21 + r)...(21 + r) {
                let s = -q - r
                coords.insert(TriangleCoordinate(q: q, r: r, isPointingUp: s % 2 != 0 ? false : true))
            }
        }
        return coords
    }

    // 辅助函数：生成单个坐标
    private func coord(q: Int, r: Int) -> TriangleCoordinate {
        let s = -q - r
        let isUp = (s % 2 != 0) ? false : true
        return TriangleCoordinate(q: q, r: r, isPointingUp: isUp)
    }

    // 辅助函数：生成Q范围数组
    private func coordsInQRange(qRange: ClosedRange<Int>, r: Int) -> [TriangleCoordinate] {
        return qRange.map { coord(q: $0, r: r) }
    }

    // 辅助函数：生成R范围数组
    private func coordsInRRange(rRange: ClosedRange<Int>, q: Int) -> [TriangleCoordinate] {
        return rRange.map { coord(q: q, r: $0) }
    }

    // 按字母顺序定义每个字母的坐标和颜色
    private var letters: [(coords: [TriangleCoordinate], color: Color)] {
        [
            (tCoords, .red),
            (rCoords, .orange),
            (eCoords, .yellow),
            (vCoords, .green),
            (e2Coords, .blue),
            (r2Coords, .purple),
            (sCoords, .pink),
            (iCoords, .cyan)
        ]
    }

    // 以下每个字母的坐标计算属性
    private var tCoords: [TriangleCoordinate] {
        var coords: [TriangleCoordinate] = []
        coords += coordsInQRange(qRange: -16...(-13), r: 1)
        coords += coordsInRRange(rRange: -2...0, q: -14)
        return coords
    }

    private var rCoords: [TriangleCoordinate] {
        var coords: [TriangleCoordinate] = []
        coords += coordsInQRange(qRange: -12...(-9), r: 1)
        coords += coordsInRRange(rRange: -2...0, q: -12)
        for q in -10...(-9) {
            for r in -1...0 {
                coords.append(coord(q: q, r: r))
            }
        }
        coords.append(coord(q: -9, r: -2))
        coords.append(coord(q: -8, r: -2))
        return coords
    }

    private var eCoords: [TriangleCoordinate] {
        var coords: [TriangleCoordinate] = []
        coords += coordsInQRange(qRange: -7...(-4), r: 1)
        for q in -7...(-6) {
            for r in -1...0 {
                coords.append(coord(q: q, r: r))
            }
        }
        coords += coordsInQRange(qRange: -7...(-4), r: -2)
        return coords
    }

    private var vCoords: [TriangleCoordinate] {
        var coords: [TriangleCoordinate] = []
        coords.append(coord(q: -3, r: 1))
        coords.append(coord(q: 1, r: 1))
        coords += coordsInQRange(qRange: -3...(-2), r: 0)
        coords += coordsInQRange(qRange: 0...1, r: 0)
        coords += coordsInQRange(qRange: -2...0, r: -1)
        coords.append(coord(q: -1, r: -2))
        return coords
    }

    private var e2Coords: [TriangleCoordinate] {
        var coords: [TriangleCoordinate] = []
        coords += coordsInQRange(qRange: 2...5, r: 1)
        for q in 3...4 {
            for r in -1...0 {
                coords.append(coord(q: q, r: r))
            }
        }
        coords += coordsInQRange(qRange: 2...5, r: -2)
        return coords
    }

    private var r2Coords: [TriangleCoordinate] {
        var coords: [TriangleCoordinate] = []
        coords.append(coord(q: 6, r: 1))
        for q in 8...9 {
            for r in -1...1 {
                coords.append(coord(q: q, r: r))
            }
        }
        coords += coordsInQRange(qRange: 9...10, r: -2)
        return coords
    }

    private var sCoords: [TriangleCoordinate] {
        var coords: [TriangleCoordinate] = []
        coords += coordsInQRange(qRange: 11...14, r: 1)
        coords += coordsInQRange(qRange: 11...12, r: 0)
        coords += coordsInQRange(qRange: 12...13, r: -1)
        coords += coordsInQRange(qRange: 11...13, r: -2)
        return coords
    }

    private var iCoords: [TriangleCoordinate] {
        coordsInRRange(rRange: -2...1, q: 16)
    }

    var body: some View {
        NavigationStack {
            VStack {
                
                DemoBoardView(
                    allCoordinates: demoAllCoordinates,
                    colorForCoordinate: { coord in
                        if let state = pieceStates[coord], state.isRevealed {
                            return state.color
                        }
                        return nil
                    }
                )
                .aspectRatio(contentMode: .fit)

                Text("Welcome To Treversi")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                VStack(spacing: 20) {
                    NavigationLink(destination: SettingView()) {
                        Text("Start")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    NavigationLink(destination: AboutView()) {
                        Text("About Treversi")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.cyan)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 40)

                Spacer()
            }
            .padding(.top, 30)
            .navigationBarHidden(true)
            .onAppear {
                startRevealAnimation()
            }
            .onDisappear {
                timer?.invalidate()
            }
        }
    }

    private func startRevealAnimation() {
        // 初始化 pieceStates：所有字母坐标为未显示
        var states: [TriangleCoordinate: (color: Color, isRevealed: Bool)] = [:]
        for letter in letters {
            for coord in letter.coords {
                states[coord] = (color: letter.color, isRevealed: false)
            }
        }
        pieceStates = states
        currentLetterIndex = 0

        timer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { _ in
            DispatchQueue.main.async {
                if currentLetterIndex < letters.count {
                    let letterCoords = letters[currentLetterIndex].coords
                    for coord in letterCoords {
                        if var state = pieceStates[coord] {
                            state.isRevealed = true
                            pieceStates[coord] = state
                        }
                    }
                    currentLetterIndex += 1
                } else {
                    timer?.invalidate()
                }
            }
        }
    }
}

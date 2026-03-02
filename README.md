# Treversi: Shapes of Strategy

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2016.0%2B-lightgrey)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

**Treversi** reimagines the classic game of Reversi (Othello) by replacing the square board with a **triangular tiling**, unlocking **six flipping directions** instead of four. Combined with special pieces, multiple board shapes, and extensive customisation, every game becomes a fresh strategic challenge.

---

## ✨ Features

- **Triangular grid** – 6 directions for deeper strategy.
- **Multiple boards** – Classic Hexagon, Diamond Field, Trianguland, each with its own geometry.
- **Diverse starting layouts** – Pre‑set openings for different play styles.
- **Special pieces** – Directional Tile (purple, arrow‑locked) and Neutral Tile (orange, usable by both players). Can be toggled on/off.
- **Highly customisable** – Board size, starting layout, legal‑move highlight, preview, undo – mix and match freely.
- **Polished animations** – Every flip is frame‑optimised, with a satisfying 90° color switch.
- **Performance** – State management and caching ensure smooth navigation.
- **Accessibility** – Clear visual feedback, long‑press preview, and highlights for beginners.

---

## 🎮 Rules

1. The board is a triangular tiling; each triangle represents a piece.
2. Black and White take turns placing a piece only where it can flip opponent pieces.
3. After placing, any straight line of opponent pieces between the new piece and another same‑color piece is flipped.
4. Game ends when neither player can move; the player with more pieces wins.
5. **Directional Piece** (purple with arrow): cannot be captured; can only be used to create flips along the arrow’s direction.
6. **Neutral Piece** (orange with asterisk): cannot be captured; both players can use it to form flips.

---

## 🧠 Philosophy & Design

Treversi embodies three Apple values:

- **Innovation** – Transplanting Reversi onto a triangular grid, introducing special pieces, and offering multiple board designs.
- **Design** – Carefully tuned flipping animation, a main menu logo spelled out by flipping triangles, and intuitive interactions.
- **Inclusivity** – Multiple board types, adjustable difficulty, optional hints, and undo make the game accessible to all.

Beyond the game itself, Treversi aims to convey a life philosophy: just like the volatile game of Reversi, even a seemingly hopeless position can turn around. Don’t give up – the tide can always change.

---

## 🚀 Getting Started

### Prerequisites
- Xcode 14.0+
- iOS 16.0+
- Swift 5.9

### Installation

#### Option 1: Clone and open as a Swift Package (recommended)
```bash
git clone https://github.com/yourusername/Treversi.git
cd Treversi
```
If you prefer the classic `.swiftpm` folder experience, rename the cloned folder to `Treversi.swiftpm`:
```bash
mv Treversi Treversi.swiftpm
```
Then double-click `Treversi.swiftpm` – it will open in Xcode as a full project, ready to run.

#### Option 2: Open via terminal
If you keep the folder name as is, simply run:
```bash
xed .
```
from inside the project directory. This tells Xcode to open the folder as a Swift Package.

#### Option 3: Open from Xcode
Launch Xcode, select **File > Open**, choose the project folder (the one containing `Package.swift`), and click **Open**.

### First Run – Signing
The `Package.swift` file uses a placeholder `teamIdentifier: "YOUR_TEAM_ID"`. Before running on a device or simulator, you need to set your own development team:

1. In Xcode, select the `Treversi` project in the Project Navigator.
2. Go to the **Signing & Capabilities** tab.
3. Under **Team**, choose your personal team (or your Apple Developer account). Xcode will automatically update the signing settings.
4. Now you can build and run (`Cmd+R`) on the simulator or your device.

---

## 🤝 Contributing

Contributions are welcome! If you have ideas for new boards, special pieces, or improvements, feel free to open an issue or submit a pull request. Please follow the [Conventional Commits](https://www.conventionalcommits.org/) specification for commit messages.

---

## 📄 License

This project is licensed under the MIT License – see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgements

- Thanks to the advancement of AI technology, which enabled a programming beginner to implement complex geometric logic.
- Thanks to the Swift Student Challenge for providing the opportunity to turn ideas into reality.
- And most importantly, thanks to everyone who plays Treversi – your experience is my greatest motivation.

---

**Built with SwiftUI**  
For Swift Student Challenge 2026  
by **刁泓宁 (Hongning Diao)**

---

# Treversi：形状的策略（中文）

## ✨ 功能特色

- **三角形网格** – 提供六个翻转方向，策略更深。
- **多种棋盘** – 经典六边形、菱形战场、三角之地。
- **多样化开局** – 预设多种开局布局，适应不同玩法。
- **特殊棋子** – 方向棋子（紫色带箭头，不可被翻转，仅沿箭头方向起作用）和中性棋子（橙色带星号，双方均可使用），可开关。
- **高度可定制** – 棋盘大小、开局布局、合法落子提示、预览、悔棋——自由组合。
- **精致动画** – 每颗棋子的翻转都经过优化，90°色彩切换带来满足感。
- **性能优化** – 状态管理和缓存让切换流畅无卡顿。
- **包容性设计** – 清晰的视觉反馈、长按预览和高亮提示，帮助新手轻松上手。

## 🎮 游戏规则

1. 棋盘由三角形镶嵌而成，每个三角形代表一枚棋子。
2. 黑白双方轮流落子，且必须落在能翻转对方棋子的位置。
3. 落子后，新棋子与同色棋子之间直线上的所有对方棋子被翻转。
4. 当双方均无合法落子时游戏结束，棋子多者获胜。
5. **方向棋子**（紫色带箭头）：不可被翻转；只能沿箭头方向参与翻转。
6. **中性棋子**（橙色带星号）：不可被翻转；双方均可利用它形成翻转。

## 🧠 理念与设计

Treversi 体现了三项苹果价值观：

- **创新** – 将黑白棋移植到三角形网格，引入特殊棋子，并设计多种棋盘形态。
- **设计** – 精心调校的翻转动画，主菜单中由三角形棋子逐个翻转拼出的标志，以及直观的交互。
- **包容性** – 多种棋盘类型、可调节难度、可选提示和悔棋，让所有人享受游戏。

除了游戏本身，Treversi 还想传递一种人生哲学：就像黑白棋那跌宕起伏的局势一样，看似绝望的处境也可能在最后一刻翻盘。不要放弃——局势总会有转机。

## 🚀 开始使用

### 环境要求
- Xcode 14.0+
- iOS 16.0+
- Swift 5.9

### 安装步骤

#### 方法一：克隆后以 Swift Package 方式打开（推荐）
```bash
git clone https://github.com/yourusername/Treversi.git
cd Treversi
```
如果你想保留熟悉的 `.swiftpm` 文件夹体验，可以将克隆的文件夹重命名：
```bash
mv Treversi Treversi.swiftpm
```
然后双击 `Treversi.swiftpm` 文件夹，它会在 Xcode 中作为完整项目打开，直接可以运行。

#### 方法二：通过终端打开
如果不重命名，在项目目录中执行：
```bash
xed .
```
Xcode 就会打开当前文件夹作为 Swift Package 项目。

#### 方法三：从 Xcode 打开
启动 Xcode，选择 **文件 > 打开**，选中项目文件夹（包含 `Package.swift` 的那个），点击打开。

### 首次运行 – 签名设置
`Package.swift` 中使用的是占位符 `teamIdentifier: "YOUR_TEAM_ID"`。在运行到模拟器或真机之前，你需要设置自己的开发团队：

1. 在 Xcode 的项目导航器中选中 `Treversi` 项目。
2. 进入 **Signing & Capabilities** 标签页。
3. 在 **Team** 下拉菜单中选择你的个人团队（或开发者账号）。Xcode 会自动更新签名设置。
4. 现在你可以按 `Cmd+R` 在模拟器或真机上编译运行了。

## 🤝 贡献指南

欢迎贡献！如果你有新棋盘、新特殊棋子的想法，或者任何改进建议，请提交 Issue 或 Pull Request。提交信息请遵循 [Conventional Commits](https://www.conventionalcommits.org/) 规范。

## 📄 许可证

本项目采用 MIT 许可证 – 详见 [LICENSE](LICENSE) 文件。

## 🙏 致谢

- 感谢 AI 技术的进步，让编程初学者也能实现如此复杂的几何逻辑。
- 感谢 Swift 学生挑战赛，让我有机会将脑中的想法变为现实。
- 最重要的是，感谢每一位玩 Treversi 的玩家——你们的体验是我最大的动力。

---

**使用 SwiftUI 构建**  
献给 Swift Student Challenge 2026  
刁泓宁 著

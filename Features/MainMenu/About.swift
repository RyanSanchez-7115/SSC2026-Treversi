import SwiftUI

/**
 * @struct AboutView
 * @brief A view that displays detailed information about the Treversi app.
 * @details This view presents the app's concept, features, rules, design philosophy, and acknowledgements.
 *          It is structured using a `ScrollView` and composed of several reusable card and row components.
 *          The layout is refactored into computed properties for each section to improve readability.
 */
struct AboutView: View {
    /// A reusable gradient for titles to ensure consistency across sections.
    private let titleGradient = LinearGradient(
        colors: [.blue, .purple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                titleSection
                inspirationSection
                appleValuesSection
                coreFeaturesSection
                rulesSection
                uniquenessSection
                philosophySection
                acknowledgementsSection
                footerSection
            }
            .padding(24)
        }
        .navigationTitle("About Treversi")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Content Sections

    /// The main title and subtitle of the about page.
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 40) {
                Text("Treversi :")
                    .font(.system(size: 52, weight: .black, design: .rounded))
                    .foregroundStyle(titleGradient)
                
                Text("Shapes of Strategy")
                    .font(.system(size: 45, weight: .black).italic())
                    .foregroundStyle(LinearGradient(
                        colors: [.yellow, .green, .cyan],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
            }
            Text("Redefining the strategic depth of classic Reversi with new geometry and rules.")
                .font(.title3)
                .foregroundColor(.primary)
                .fontWeight(.medium)
        }
        .padding(.top, 16)
    }
    
    /// The section explaining the inspiration and motivation behind the game.
    private var inspirationSection: some View {
        AboutCard(
            icon: "lightbulb.fill",
            title: "Inspiration & Motivation",
            content: """
                My fascination with traditional Reversi began with its "volatility"—the ever-shifting momentum, the ebb and flow of control, and the suspense that you can never determine the final outcome from the current count. But after playing for a long time, I realized the rules were somewhat fixed, with too few flipping directions (only 4).
                
                While learning about cubic coordinate systems, a thought struck me: what if we replaced square pieces with equilateral triangles? A triangular-tiled board naturally provides 6 flipping directions, instantly expanding strategic dimensions. So I introduced two special pieces—the Directional Tile and the Neutral Tile—designed multiple board types and starting layouts, making every game feel fresh.
                
                After finishing my first test game, gazing at the geometric patterns formed by the black and white pieces, I realized: this is not just a game, it’s a dynamic piece of art.
                """,
            titleGradient: titleGradient
        )
    }
    
    /// The section highlighting how the app embodies Apple's values.
    private var appleValuesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Apple Values Embodied")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(titleGradient)
                .padding(.horizontal)
            
            ValueCard(
                icon: "sparkles",
                title: "Innovation",
                description: "Transplanting classic Reversi rules onto a triangular-tiled geometric board (form innovation); multiple board designs and starting layouts (gameplay innovation); introducing Directional and Neutral pieces (rule innovation).",
                titleGradient: titleGradient
            )
            
            ValueCard(
                icon: "paintpalette",
                title: "Design",
                description: "Carefully tuned flipping animation—color switches instantly at 90°, mimicking the texture of flipping a physical coin; the “TREVERSI” logo on the main menu, spelled out by triangular pieces flipping one by one, is uniquely stylish; long-press preview and timely highlights make interactions intuitive and smooth.",
                titleGradient: titleGradient
            )
            
            ValueCard(
                icon: "person.fill.checkmark",
                title: "Inclusivity",
                description: "Supports multiple board types, sizes, and diverse starting layouts; offers legal-move highlighting, flip preview, and undo to help beginners; players can choose whether to include special pieces; cache optimization ensures seamless switching.",
                titleGradient: titleGradient
            )
        }
    }
    
    /// The section listing the core features of the game.
    private var coreFeaturesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Core Features")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(titleGradient)
                .padding(.horizontal)
            
            FeatureRow(icon: "square.grid.3x3.fill", text: "Multiple Boards: Classic Hexagon, Diamond Field, Trianguland")
            FeatureRow(icon: "square.stack.fill", text: "Multiple Starting Layouts: each board comes with several pre‑set openings of different strategies and experiences")
            FeatureRow(icon: "star.square.fill", text: "Special‑Piece System: Directional and Neutral tiles, can be toggled on/off")
            FeatureRow(icon: "slider.horizontal.3", text: "Highly Customizable: board size, starting layout, feature switches (legal‑move highlight, preview, undo) all free to combine")
            FeatureRow(icon: "film.fill", text: "Polished Flipping Animation: every piece’s flip has been frame‑optimised")
            FeatureRow(icon: "gauge.medium", text: "Performance Optimisation: state management and caching make switching buttery‑smooth")
        }
    }
    
    /// The section explaining the game rules.
    private var rulesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Game Rules")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(titleGradient)
                .padding(.horizontal)
            
            RuleRow(icon: "1.circle.fill", text: "The board is a triangular tiling; each triangle represents a piece.")
            RuleRow(icon: "2.circle.fill", text: "Black and White take turns placing a piece only where it can flip opponent pieces.")
            RuleRow(icon: "3.circle.fill", text: "After placing, any straight line of opponent pieces between the new piece and another same‑color piece is flipped.")
            RuleRow(icon: "4.circle.fill", text: "Game ends when neither player can move; the player with more pieces wins.")
            RuleRow(icon: "5.circle.fill", text: "Directional Piece (purple with arrow): cannot be captured; can only be used to create flips along the arrow’s direction.")
            RuleRow(icon: "6.circle.fill", text: "Neutral Piece (orange with asterisk) cannot be captured; both players can use it to form flips.")
        }
    }
    
    /// The section describing what makes the game unique.
    private var uniquenessSection: some View {
        AboutCard(
            icon: "star.fill",
            title: "What Makes It Unique",
            content: """
                A fresh take on traditional Reversi, offering both strategic depth and freedom of choice, all wrapped in an “intuitive” experience.
                Players can not only challenge classic Reversi but also become their own game designers by customising the rules.
                """,
            titleGradient: titleGradient
        )
    }
    
    /// The section on the educational value and life philosophy embedded in the game.
    private var philosophySection: some View {
        AboutCard(
            icon: "heart.fill",
            title: "Educational Value & Life Philosophy",
            content: """
                While placing pieces, players must consider triangle orientation, neighbour relationships, and the six ray directions, subtly training spatial imagination and logical reasoning. The board’s coordinate system (cubic coordinates) also offers a tangible example for understanding 3D coordinate projections.
                
                But what fascinates me most is the philosophy inherent in Reversi: life’s ups and downs are like the volatile game situation. A seemingly hopeless position may turn the tables in the end. Treversi aims to convey this belief—don’t give up when you’re down, because the tide can always turn.
                """,
            titleGradient: titleGradient
        )
    }
    
    /// The acknowledgements section.
    private var acknowledgementsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Acknowledgements")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(titleGradient)
                .padding(.horizontal)
            
            Text("I am grateful for the advancement of AI technology, which enabled a programming beginner like me to implement such complex geometric logic and animations with assistance; for the Swift Student Challenge, which gave me the opportunity to turn ideas in my head into reality; and above all, for everyone who plays this game—whether you find joy, strategic thought, or an interest in geometry, your experience is my greatest motivation.")
                .font(.body.weight(.medium))
                .foregroundColor(.primary)
                .padding(.horizontal)
                .lineSpacing(4)
        }
    }
    
    /// The footer section with credits and other info.
    private var footerSection: some View {
        VStack(spacing: 8) {
            Spacer(minLength: 40)
            Text("Built with SwiftUI")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("For Swift Student Challenge 2026")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("by 刁泓宁 (Hongning Diao)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

// MARK: - Helper Components

/**
 * @struct AboutCard
 * @brief A reusable card component for displaying a section with an icon, title, and content.
 */
struct AboutCard: View {
    let icon: String
    let title: String
    let content: String
    let titleGradient: LinearGradient
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.accentColor)
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(titleGradient)
            }
            
            Text(content)
                .font(.body.weight(.medium))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(4)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

/**
 * @struct ValueCard
 * @brief A reusable card for displaying a value proposition (e.g., Innovation, Design).
 */
struct ValueCard: View {
    let icon: String
    let title: String
    let description: String
    let titleGradient: LinearGradient
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(titleGradient)
                Text(description)
                    .font(.body.weight(.medium))
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(4)
            }
        }
        .padding(.horizontal)
    }
}

/**
 * @struct FeatureRow
 * @brief A reusable row for displaying a single game feature with an icon and text.
 */
struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.accentColor)
                .frame(width: 28)
            Text(text)
                .font(.body.weight(.medium))
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.horizontal)
    }
}

/**
 * @struct RuleRow
 * @brief A reusable row for displaying a single game rule with a numbered icon and text.
 */
struct RuleRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.accentColor)
                .frame(width: 28)
            Text(text)
                .font(.body.weight(.medium))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}

import SwiftUI

// MARK: - Pixels Design System
// Single source of truth for all design tokens.
// Usage: Color.pixels.background, Font.pixels.header, PixelsLayout.cornerRadius.block

// MARK: - Color tokens

extension Color {
    static let pixels = PixelsColors()
}

struct PixelsColors {

    // MARK: Canvas
    /// Warm creamy parchment — the app canvas
    let background      = Color(hex: "#FDF6F0")
    /// Warm surface for cards, stats, duration scroller
    let surface         = Color(hex: "#F5EDE8")

    // MARK: Accent
    /// Dusty rose — selected states, active tab, save button
    let accent          = Color(hex: "#F2B8B5")
    /// Pressed / stronger accent
    let accentDark      = Color(hex: "#E8968F")

    // MARK: Text
    /// Headers, block titles, primary content
    let textPrimary     = Color(hex: "#2C1A14")
    /// Taglines, eyebrow labels
    let textSecondary   = Color(hex: "#8C7068")
    /// Time labels, period labels, muted UI, section eyebrows
    let textTertiary    = Color(hex: "#C4A89E")
    /// Empty field placeholder — lighter than tertiary
    let textPlaceholder = Color(hex: "#D8C4BC")

    // MARK: Borders
    /// Dividers, zone separators (0.5px)
    let borderDefault   = Color(hex: "#EAE0D8")
    /// Date strip bottom border, duration scroller highlight (1.5px)
    let borderStrong    = Color(hex: "#E0D0C8")
    /// Surface card borders
    let borderSurface   = Color(hex: "#E8D8D0")
    /// Dashed border on empty slots
    let borderEmpty     = Color(hex: "#D8C4BC")

    // MARK: Activity block fills
    let healthFill      = Color(hex: "#FBCDD5")
    let learningFill    = Color(hex: "#BDDCE8")
    let foodFill        = Color(hex: "#FFD4A8")
    let workFill        = Color(hex: "#C8DDB8")
    let socialFill      = Color(hex: "#F9C4D4")
    let restFill        = Color(hex: "#FFD4A8")
    let personalFill    = Color(hex: "#D4C4E8")
    let otherFill       = Color(hex: "#D8D8D8")

    // MARK: Activity block borders / icon tints
    let healthBorder    = Color(hex: "#E8968F")
    let learningBorder  = Color(hex: "#90C0D8")
    let foodBorder      = Color(hex: "#F0B878")
    let workBorder      = Color(hex: "#A0C090")
    let socialBorder    = Color(hex: "#F0A0B8")
    let restBorder      = Color(hex: "#F0B878")
    let personalBorder  = Color(hex: "#B8A8D0")
    let otherBorder     = Color(hex: "#C0C0C0")

    // MARK: Year view
    /// Unlogged / future days at 28% opacity
    var futureDot: Color { Color(hex: "#E0D5CC").opacity(0.28) }

    // MARK: Tab bar
    /// Tab bar pill background — matches canvas, subtle border only
    let tabBarBackground = Color(hex: "#FDF6F0")
    /// Active tab icon and label
    let tabBarActive     = Color(hex: "#F2B8B5")
    /// Inactive tab icon and label
    let tabBarInactive   = Color(hex: "#C4A89E")
}

// MARK: - Typography

extension Font {
    static let pixels = PixelsFonts()
}

struct PixelsFonts {
    // MARK: Today tab
    /// "Your day, in colour." — large bold header
    let header          = Font.system(.largeTitle, design: .rounded).weight(.bold)
    /// Section titles inside cards
    let title           = Font.system(.title3, design: .rounded).weight(.bold)
    /// Activity block main label
    let blockTitle      = Font.system(.subheadline, design: .default).weight(.bold)
    /// Activity block category subtitle
    let blockSubtitle   = Font.system(.caption, design: .default).weight(.regular)

    // MARK: Navigation / UI
    /// Time display in Add Activity (09:00, 10:00, 1h)
    let timeDisplay     = Font.system(.body, design: .default).weight(.semibold).monospacedDigit()
    /// All eyebrow / section labels (uppercase in view)
    let eyebrow         = Font.system(size: 10, weight: .regular, design: .default)
    /// Standard body text
    let body            = Font.system(.body, design: .default).weight(.regular)
    /// Tab bar labels, category grid labels, legend pills
    let caption         = Font.system(size: 10, weight: .regular, design: .default)
    /// Date strip day name
    let dateLabel       = Font.system(.caption2, design: .default).weight(.regular)
    /// Date strip day number
    let dateNumber      = Font.system(.callout, design: .default).weight(.bold)
    /// Time column labels (00:00, 01:00…) — monospaced
    let timeLabel       = Font.system(.caption2, design: .default).monospacedDigit()
}

// MARK: - Spacing & Layout

enum PixelsLayout {

    enum Spacing {
        /// Standard horizontal margin — all screens
        static let margin: CGFloat = 16
        /// Gap between week pixel cells
        static let weekCellGap: CGFloat = 2
        /// Gap between month pixel cells
        static let monthCellGap: CGFloat = 3
        /// Gap between year pixel cells (horizontal and vertical)
        static let yearCellGap: CGFloat = 1.5
    }

    enum CornerRadius {
        /// Activity blocks
        static let block: CGFloat = 12
        /// Date strip day cells
        static let dateCell: CGFloat = 10
        /// Stats cards, surface cards
        static let card: CGFloat = 10
        /// Legend pills (full pill)
        static let pill: CGFloat = 20
        /// Category grid icons in Add Activity
        static let categoryIcon: CGFloat = 13
        /// Duration scroller container
        static let scroller: CGFloat = 14
        /// Duration selected value pill
        static let scrollerSelected: CGFloat = 10
        /// Tab bar pill
        static let tabBar: CGFloat = 40
        /// Week pixel cells
        static let weekCell: CGFloat = 6
        /// Month pixel cells
        static let monthCell: CGFloat = 4
        /// Year pixel cells
        static let yearCell: CGFloat = 2
        /// Subcategory pills in Add Activity
        static let subcategoryPill: CGFloat = 10
    }

    enum BorderWidth {
        /// Standard dividers and zone separators
        static let `default`: CGFloat = 0.5
        /// Date strip bottom border (stronger handoff to content)
        static let strong: CGFloat = 1.5
        /// Selected category icon in Add Activity
        static let selectedCategory: CGFloat = 2.0
    }

    enum Size {
        /// Default time grid row height
        static let rowHeightDefault: CGFloat = 56
        /// Minimum row height (pinch to zoom)
        static let rowHeightMin: CGFloat = 32
        /// Maximum row height (pinch to zoom)
        static let rowHeightMax: CGFloat = 80
        /// Time label column width
        static let timeLabelWidth: CGFloat = 52
        /// Week pixel cell
        static let weekCell = CGSize(width: 44, height: 58)
        /// Month pixel cell
        static let monthCell = CGSize(width: 32, height: 32)
        /// Category icon in Add Activity
        static let categoryIcon = CGSize(width: 52, height: 52)
    }
}

// MARK: - Category helpers

/// Maps a category name to its design system fill and border colors.
/// Use for activity blocks, category icons, legend dots.
struct CategoryAppearance {
    let fill: Color
    let border: Color
}

extension PixelsColors {
    func appearance(for categoryName: String) -> CategoryAppearance {
        switch categoryName.lowercased() {
        case "health":   return CategoryAppearance(fill: healthFill,   border: healthBorder)
        case "learning": return CategoryAppearance(fill: learningFill, border: learningBorder)
        case "food":     return CategoryAppearance(fill: foodFill,     border: foodBorder)
        case "work":     return CategoryAppearance(fill: workFill,     border: workBorder)
        case "social":   return CategoryAppearance(fill: socialFill,   border: socialBorder)
        case "rest":     return CategoryAppearance(fill: restFill,     border: restBorder)
        case "personal": return CategoryAppearance(fill: personalFill, border: personalBorder)
        default:         return CategoryAppearance(fill: otherFill,    border: otherBorder)
        }
    }
}

// MARK: - Eyebrow label modifier
// Usage: Text("Category").pixelsEyebrow()

struct PixelsEyebrowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.pixels.eyebrow)
            .foregroundColor(.pixels.textTertiary)
            .textCase(.uppercase)
            .kerning(0.6)
    }
}

extension View {
    func pixelsEyebrow() -> some View {
        modifier(PixelsEyebrowModifier())
    }
}

// MARK: - Divider

/// Standard 0.5px warm divider. Usage: PixelsDivider()
struct PixelsDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.pixels.borderDefault)
            .frame(height: PixelsLayout.BorderWidth.default)
    }
}

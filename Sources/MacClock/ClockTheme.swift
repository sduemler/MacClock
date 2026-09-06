import SwiftUI

/// Color schemes for the Digital and Analog faces. Half dark, half light.
enum ClockTheme: String, CaseIterable, Identifiable {
    // Dark
    case midnight
    case slate
    case ember
    // Light
    case paper
    case cloud
    case sage

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .midnight: return "Midnight"
        case .slate: return "Slate"
        case .ember: return "Ember"
        case .paper: return "Paper"
        case .cloud: return "Cloud"
        case .sage: return "Sage"
        }
    }

    var isDark: Bool {
        switch self {
        case .midnight, .slate, .ember: return true
        case .paper, .cloud, .sage: return false
        }
    }

    static var dark: [ClockTheme] { allCases.filter { $0.isDark } }
    static var light: [ClockTheme] { allCases.filter { !$0.isDark } }

    /// Page background.
    var background: Color {
        switch self {
        case .midnight: return Color(red: 0.00, green: 0.00, blue: 0.00)
        case .slate: return Color(red: 0.11, green: 0.13, blue: 0.17)
        case .ember: return Color(red: 0.09, green: 0.06, blue: 0.05)
        case .paper: return Color(red: 0.96, green: 0.94, blue: 0.90)
        case .cloud: return Color(red: 0.93, green: 0.95, blue: 0.97)
        case .sage: return Color(red: 0.90, green: 0.93, blue: 0.89)
        }
    }

    /// Time digits, hands, numerals.
    var foreground: Color {
        switch self {
        case .midnight: return Color(red: 1.00, green: 1.00, blue: 1.00)
        case .slate: return Color(red: 0.93, green: 0.94, blue: 0.96)
        case .ember: return Color(red: 0.98, green: 0.85, blue: 0.70)
        case .paper: return Color(red: 0.13, green: 0.11, blue: 0.09)
        case .cloud: return Color(red: 0.11, green: 0.16, blue: 0.27)
        case .sage: return Color(red: 0.14, green: 0.20, blue: 0.16)
        }
    }

    /// Date line, minor ticks, AM/PM.
    var secondary: Color {
        switch self {
        case .midnight: return Color(white: 0.62)
        case .slate: return Color(red: 0.60, green: 0.65, blue: 0.73)
        case .ember: return Color(red: 0.72, green: 0.56, blue: 0.44)
        case .paper: return Color(red: 0.48, green: 0.43, blue: 0.37)
        case .cloud: return Color(red: 0.45, green: 0.51, blue: 0.62)
        case .sage: return Color(red: 0.42, green: 0.50, blue: 0.44)
        }
    }

    /// Small highlight: colon, center cap, hour markers.
    var accent: Color {
        switch self {
        case .midnight: return Color(red: 0.98, green: 0.78, blue: 0.24)
        case .slate: return Color(red: 0.36, green: 0.62, blue: 0.98)
        case .ember: return Color(red: 0.96, green: 0.42, blue: 0.20)
        case .paper: return Color(red: 0.72, green: 0.24, blue: 0.16)
        case .cloud: return Color(red: 0.18, green: 0.47, blue: 0.84)
        case .sage: return Color(red: 0.24, green: 0.56, blue: 0.38)
        }
    }

    /// Analog dial fill, slightly separated from the background.
    var dial: Color {
        switch self {
        case .midnight: return Color(white: 0.09)
        case .slate: return Color(red: 0.15, green: 0.17, blue: 0.22)
        case .ember: return Color(red: 0.14, green: 0.09, blue: 0.07)
        case .paper: return Color(red: 0.99, green: 0.98, blue: 0.95)
        case .cloud: return Color(red: 1.00, green: 1.00, blue: 1.00)
        case .sage: return Color(red: 0.96, green: 0.98, blue: 0.95)
        }
    }
}

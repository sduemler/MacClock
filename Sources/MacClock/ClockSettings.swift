import Foundation
import Combine

enum ClockFace: String, CaseIterable, Identifiable {
    case sansDigital
    case sevenSegment
    case vfd
    case flipClock
    case classicAnalog

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .sansDigital: return "Digital"
        case .sevenSegment: return "LED"
        case .vfd: return "VFD"
        case .flipClock: return "Flip"
        case .classicAnalog: return "Analog"
        }
    }
}

/// User preferences, persisted to UserDefaults.
@MainActor
final class ClockSettings: ObservableObject {
    static let shared = ClockSettings()

    private let defaults = UserDefaults.standard

    @Published var face: ClockFace {
        didSet { defaults.set(face.rawValue, forKey: Keys.face) }
    }
    @Published var theme: ClockTheme {
        didSet { defaults.set(theme.rawValue, forKey: Keys.theme) }
    }
    @Published var use24Hour: Bool {
        didSet { defaults.set(use24Hour, forKey: Keys.use24Hour) }
    }
    @Published var showDate: Bool {
        didSet { defaults.set(showDate, forKey: Keys.showDate) }
    }
    @Published var alwaysOnTop: Bool {
        didSet { defaults.set(alwaysOnTop, forKey: Keys.alwaysOnTop) }
    }
    /// Localized name of the display the clock should fill. Empty string = preview window.
    @Published var targetDisplayName: String {
        didSet { defaults.set(targetDisplayName, forKey: Keys.targetDisplayName) }
    }

    private enum Keys {
        static let face = "face"
        static let theme = "theme"
        static let use24Hour = "use24Hour"
        static let showDate = "showDate"
        static let alwaysOnTop = "alwaysOnTop"
        static let targetDisplayName = "targetDisplayName"
    }

    private init() {
        face = ClockFace(rawValue: defaults.string(forKey: Keys.face) ?? "") ?? .sansDigital
        theme = ClockTheme(rawValue: defaults.string(forKey: Keys.theme) ?? "") ?? .midnight
        use24Hour = defaults.bool(forKey: Keys.use24Hour)
        showDate = defaults.object(forKey: Keys.showDate) as? Bool ?? true
        alwaysOnTop = defaults.bool(forKey: Keys.alwaysOnTop)
        targetDisplayName = defaults.string(forKey: Keys.targetDisplayName) ?? ClockSettings.unset
    }

    /// Sentinel meaning "no display chosen yet" so first launch can auto-pick.
    static let unset = "\u{0}unset"
    var hasChosenDisplay: Bool { targetDisplayName != ClockSettings.unset }
}

import SwiftUI

/// Switches between faces. Redraws only when the model's `now` changes or a setting changes.
struct ClockRootView: View {
    @EnvironmentObject private var model: ClockModel
    @EnvironmentObject private var settings: ClockSettings

    var body: some View {
        FaceView(face: settings.face, theme: settings.theme, date: model.now, use24Hour: settings.use24Hour, showDate: settings.showDate)
            .ignoresSafeArea()
    }
}

struct FaceView: View {
    let face: ClockFace
    let theme: ClockTheme
    let date: Date
    let use24Hour: Bool
    let showDate: Bool

    var body: some View {
        let parts = TimeParts(date, use24Hour: use24Hour)
        ZStack {
            switch face {
            case .sansDigital:
                theme.background
                SansDigitalFace(parts: parts, showDate: showDate, theme: theme)
            case .sevenSegment:
                SevenSegmentFace(parts: parts, showDate: showDate, palette: .led)
            case .vfd:
                SevenSegmentFace(parts: parts, showDate: showDate, palette: .vfd)
            case .flipClock:
                FlipClockFace(parts: parts, showDate: showDate)
            case .classicAnalog:
                theme.background
                AnalogFace(parts: parts, showDate: showDate, theme: theme)
            }
        }
    }
}

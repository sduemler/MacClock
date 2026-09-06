import SwiftUI

/// Clean sans-serif digital face: big time, small meridiem, date underneath.
struct SansDigitalFace: View {
    let parts: TimeParts
    let showDate: Bool
    let theme: ClockTheme

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            // Fit "12:34" comfortably: ~2.9 em wide for SF Pro semibold digits.
            let timeSize = min(h * (showDate ? 0.5 : 0.58), w / 3.1)
            let smallSize = timeSize * 0.22

            VStack(spacing: timeSize * 0.02) {
                HStack(alignment: .lastTextBaseline, spacing: timeSize * 0.08) {
                    Text(parts.timeString)
                        .font(.system(size: timeSize, weight: .semibold, design: .default))
                        .monospacedDigit()
                        .foregroundStyle(theme.foreground)
                    if !parts.use24Hour {
                        Text(parts.meridiem)
                            .font(.system(size: smallSize, weight: .medium))
                            .foregroundStyle(theme.accent)
                            .padding(.bottom, timeSize * 0.02)
                    }
                }
                .lineLimit(1)
                .minimumScaleFactor(0.4)

                if showDate {
                    Text(parts.dateLong)
                        .font(.system(size: smallSize, weight: .regular))
                        .foregroundStyle(theme.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
            }
            .frame(width: w, height: h)
        }
    }
}

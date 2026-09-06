import SwiftUI

/// Split-flap clock like the 1970s flip clock radios: two dark cards, hours and
/// minutes, each with a hinge line across the middle.
struct FlipClockFace: View {
    let parts: TimeParts
    let showDate: Bool

    private static let background = Color(red: 0.05, green: 0.05, blue: 0.05)
    private static let cardTop = Color(white: 0.21)
    private static let cardBottom = Color(white: 0.14)
    private static let ink = Color(white: 0.94)

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let cardH = min(h * (showDate ? 0.56 : 0.66), w / 2.75)
            let cardW = cardH * 1.18
            let gap = cardH * 0.12

            ZStack {
                FlipClockFace.background
                VStack(spacing: cardH * 0.14) {
                    HStack(spacing: gap) {
                        card(text: hourText, size: CGSize(width: cardW, height: cardH),
                             corner: parts.use24Hour ? nil : parts.meridiem)
                        card(text: String(format: "%02d", parts.minute), size: CGSize(width: cardW, height: cardH), corner: nil)
                    }
                    if showDate {
                        Text(parts.dateLong.uppercased())
                            .font(.system(size: cardH * 0.11, weight: .semibold))
                            .tracking(cardH * 0.012)
                            .foregroundStyle(Color(white: 0.5))
                    }
                }
            }
            .frame(width: w, height: h)
        }
    }

    private var hourText: String {
        parts.use24Hour ? String(format: "%02d", parts.displayHour) : String(parts.displayHour)
    }

    private func card(text: String, size: CGSize, corner: String?) -> some View {
        let radius = size.height * 0.07
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)
        return ZStack {
            shape.fill(LinearGradient(colors: [FlipClockFace.cardTop, FlipClockFace.cardBottom],
                                      startPoint: .top, endPoint: .bottom))

            // Lower leaf sits a touch darker, as if in shadow under the upper leaf.
            VStack(spacing: 0) {
                Color.clear
                Color.black.opacity(0.22)
            }
            .clipShape(shape)

            Text(text)
                .font(.system(size: size.height * 0.88, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(FlipClockFace.ink)
                .minimumScaleFactor(0.5)
                .lineLimit(1)

            // Hinge line and side pins
            Rectangle()
                .fill(Color.black)
                .frame(height: max(1, size.height * 0.022))
            HStack {
                hingePin(size: size)
                Spacer()
                hingePin(size: size)
            }

            if let corner {
                VStack {
                    HStack {
                        Text(corner)
                            .font(.system(size: size.height * 0.11, weight: .semibold))
                            .foregroundStyle(FlipClockFace.ink.opacity(0.75))
                            .padding(.leading, size.width * 0.06)
                            .padding(.top, size.height * 0.07)
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
        .frame(width: size.width, height: size.height)
        .shadow(color: .black.opacity(0.7), radius: size.height * 0.04, y: size.height * 0.02)
    }

    private func hingePin(size: CGSize) -> some View {
        RoundedRectangle(cornerRadius: size.height * 0.01)
            .fill(Color.black)
            .frame(width: size.width * 0.035, height: size.height * 0.12)
    }
}

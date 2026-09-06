import SwiftUI

/// Colors for a segment display. LED is the red clock-radio look; VFD is the
/// cyan-green vacuum fluorescent look from later radios and hi-fi gear.
struct SegmentPalette {
    let background: Color
    let lit: Color
    let unlitOpacity: Double
    let glowOpacity: Double
    let glowRadius: CGFloat     // relative to digit height

    var unlit: Color { lit.opacity(unlitOpacity) }

    static let led = SegmentPalette(
        background: .black,
        lit: Color(red: 1.0, green: 0.23, blue: 0.12),
        unlitOpacity: 0.07,
        glowOpacity: 0.55,
        glowRadius: 0.04
    )

    static let vfd = SegmentPalette(
        background: Color(red: 0.02, green: 0.035, blue: 0.06),
        lit: Color(red: 0.58, green: 1.0, blue: 0.94),
        unlitOpacity: 0.05,
        glowOpacity: 0.7,
        glowRadius: 0.07
    )
}

/// Classic seven-segment display with unlit "ghost" segments and a soft glow.
struct SevenSegmentFace: View {
    let parts: TimeParts
    let showDate: Bool
    var palette: SegmentPalette = .led

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            // Layout in units of digit height: 4 digits @0.58 + colon 0.3 + gaps.
            let digitH = min(h * (showDate ? 0.5 : 0.6), w / 3.6)
            let digitW = digitH * 0.58
            let gap = digitH * 0.14
            let slots = parts.digitSlots

            ZStack {
                palette.background
                VStack(spacing: digitH * 0.18) {
                    HStack(alignment: .center, spacing: gap) {
                        digit(slots[0], size: CGSize(width: digitW, height: digitH))
                        digit(slots[1], size: CGSize(width: digitW, height: digitH))
                        colon(height: digitH)
                        digit(slots[2], size: CGSize(width: digitW, height: digitH))
                        digit(slots[3], size: CGSize(width: digitW, height: digitH))
                        if !parts.use24Hour {
                            meridiem(height: digitH)
                        }
                    }
                    .transformEffect(CGAffineTransform(a: 1, b: 0, c: -0.1, d: 1, tx: digitH * 0.05, ty: 0))
                    .shadow(color: palette.lit.opacity(palette.glowOpacity), radius: digitH * palette.glowRadius)

                    if showDate {
                        Text("\(parts.weekdayShort.uppercased())  \(String(format: "%02d", parts.month)).\(String(format: "%02d", parts.day))")
                            .font(.system(size: digitH * 0.18, weight: .medium, design: .monospaced))
                            .foregroundStyle(palette.lit.opacity(0.8))
                            .tracking(digitH * 0.02)
                    }
                }
            }
            .frame(width: w, height: h)
        }
    }

    private func digit(_ value: Int?, size: CGSize) -> some View {
        ZStack {
            SevenSegmentShape(segments: 0x7F).fill(palette.unlit)
            SevenSegmentShape(segments: SevenSegmentShape.mask(for: value)).fill(palette.lit)
        }
        .frame(width: size.width, height: size.height)
    }

    private func colon(height: CGFloat) -> some View {
        let dot = height * 0.12
        return VStack(spacing: height * 0.28) {
            Rectangle().fill(palette.lit).frame(width: dot, height: dot)
            Rectangle().fill(palette.lit).frame(width: dot, height: dot)
        }
        .frame(width: dot, height: height)
    }

    private func meridiem(height: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: height * 0.06) {
            Text("AM")
                .foregroundStyle(parts.isPM ? palette.unlit : palette.lit)
            Text("PM")
                .foregroundStyle(parts.isPM ? palette.lit : palette.unlit)
        }
        .font(.system(size: height * 0.16, weight: .bold, design: .monospaced))
        .frame(height: height, alignment: .bottom)
        .padding(.leading, height * 0.05)
    }
}

/// Seven hexagonal segments. Bitmask: a=1 b=2 c=4 d=8 e=16 f=32 g=64.
struct SevenSegmentShape: Shape {
    let segments: UInt8

    static func mask(for digit: Int?) -> UInt8 {
        switch digit {
        case 0: return 63
        case 1: return 6
        case 2: return 91
        case 3: return 79
        case 4: return 102
        case 5: return 109
        case 6: return 125
        case 7: return 7
        case 8: return 127
        case 9: return 111
        default: return 0
        }
    }

    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let t = h * 0.15            // segment thickness
        let g = t * 0.22            // gap between segment tips
        var path = Path()

        func horizontal(cx: CGFloat, cy: CGFloat, length: CGFloat) {
            let half = length / 2
            path.move(to: CGPoint(x: cx - half, y: cy))
            path.addLine(to: CGPoint(x: cx - half + t / 2, y: cy - t / 2))
            path.addLine(to: CGPoint(x: cx + half - t / 2, y: cy - t / 2))
            path.addLine(to: CGPoint(x: cx + half, y: cy))
            path.addLine(to: CGPoint(x: cx + half - t / 2, y: cy + t / 2))
            path.addLine(to: CGPoint(x: cx - half + t / 2, y: cy + t / 2))
            path.closeSubpath()
        }
        func vertical(cx: CGFloat, cy: CGFloat, length: CGFloat) {
            let half = length / 2
            path.move(to: CGPoint(x: cx, y: cy - half))
            path.addLine(to: CGPoint(x: cx + t / 2, y: cy - half + t / 2))
            path.addLine(to: CGPoint(x: cx + t / 2, y: cy + half - t / 2))
            path.addLine(to: CGPoint(x: cx, y: cy + half))
            path.addLine(to: CGPoint(x: cx - t / 2, y: cy + half - t / 2))
            path.addLine(to: CGPoint(x: cx - t / 2, y: cy - half + t / 2))
            path.closeSubpath()
        }

        let hLen = w - t - 2 * g
        let vLen = h / 2 - t / 2 - 2 * g
        let upperY = (t / 2 + h / 2) / 2
        let lowerY = (h / 2 + h - t / 2) / 2

        if segments & 1 != 0 { horizontal(cx: w / 2, cy: t / 2, length: hLen) }          // a
        if segments & 2 != 0 { vertical(cx: w - t / 2, cy: upperY, length: vLen) }       // b
        if segments & 4 != 0 { vertical(cx: w - t / 2, cy: lowerY, length: vLen) }       // c
        if segments & 8 != 0 { horizontal(cx: w / 2, cy: h - t / 2, length: hLen) }      // d
        if segments & 16 != 0 { vertical(cx: t / 2, cy: lowerY, length: vLen) }          // e
        if segments & 32 != 0 { vertical(cx: t / 2, cy: upperY, length: vLen) }          // f
        if segments & 64 != 0 { horizontal(cx: w / 2, cy: h / 2, length: hLen) }         // g

        return path.applying(CGAffineTransform(translationX: rect.minX, y: rect.minY))
    }
}

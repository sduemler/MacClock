import SwiftUI

/// Classic round dial: numerals, minute ticks, hour and minute hands, no second hand.
struct AnalogFace: View {
    let parts: TimeParts
    let showDate: Bool
    let theme: ClockTheme

    var body: some View {
        Canvas { ctx, size in
            let r = min(size.width, size.height) / 2 * 0.92
            let c = CGPoint(x: size.width / 2, y: size.height / 2)
            let dialRect = CGRect(x: c.x - r, y: c.y - r, width: 2 * r, height: 2 * r)

            // Dial
            ctx.fill(Path(ellipseIn: dialRect), with: .color(theme.dial))
            ctx.stroke(Path(ellipseIn: dialRect.insetBy(dx: r * 0.012, dy: r * 0.012)),
                       with: .color(theme.foreground.opacity(0.85)), lineWidth: r * 0.024)

            // Ticks
            for i in 0..<60 {
                let angle = Double(i) / 60 * 2 * .pi - .pi / 2
                let major = i % 5 == 0
                let inner = r * (major ? 0.86 : 0.905)
                let outer = r * 0.95
                var tick = Path()
                tick.move(to: point(c, inner, angle))
                tick.addLine(to: point(c, outer, angle))
                ctx.stroke(tick, with: .color(major ? theme.foreground : theme.secondary.opacity(0.7)),
                           style: StrokeStyle(lineWidth: r * (major ? 0.022 : 0.008), lineCap: .round))
            }

            // Numerals
            for n in 1...12 {
                let angle = Double(n) / 12 * 2 * .pi - .pi / 2
                let pos = point(c, r * 0.72, angle)
                let text = Text("\(n)")
                    .font(.system(size: r * 0.17, weight: .medium, design: .serif))
                    .foregroundColor(theme.foreground)
                ctx.draw(text, at: pos, anchor: .center)
            }

            // Date
            if showDate {
                let text = Text("\(parts.weekdayShort.uppercased()) \(parts.day)")
                    .font(.system(size: r * 0.1, weight: .semibold, design: .serif))
                    .foregroundColor(theme.secondary)
                ctx.draw(text, at: CGPoint(x: c.x, y: c.y + r * 0.4), anchor: .center)
            }

            // Hands
            let minuteFraction = Double(parts.minute) / 60
            let hourAngle = (Double(parts.hour % 12) + minuteFraction) / 12 * 2 * .pi
            let minuteAngle = minuteFraction * 2 * .pi
            drawHand(ctx, center: c, angle: hourAngle, length: r * 0.52, tail: r * 0.1, width: r * 0.06, color: theme.foreground)
            drawHand(ctx, center: c, angle: minuteAngle, length: r * 0.8, tail: r * 0.1, width: r * 0.045, color: theme.foreground)

            // Center cap
            let cap = r * 0.05
            ctx.fill(Path(ellipseIn: CGRect(x: c.x - cap, y: c.y - cap, width: 2 * cap, height: 2 * cap)),
                     with: .color(theme.accent))
            let pin = r * 0.02
            ctx.fill(Path(ellipseIn: CGRect(x: c.x - pin, y: c.y - pin, width: 2 * pin, height: 2 * pin)),
                     with: .color(theme.dial))
        }
    }

    private func point(_ c: CGPoint, _ radius: CGFloat, _ angle: Double) -> CGPoint {
        CGPoint(x: c.x + radius * CGFloat(cos(angle)), y: c.y + radius * CGFloat(sin(angle)))
    }

    /// Angle is clockwise from 12 o'clock.
    private func drawHand(_ ctx: GraphicsContext, center: CGPoint, angle: Double,
                          length: CGFloat, tail: CGFloat, width: CGFloat, color: Color) {
        let local = Path(roundedRect: CGRect(x: -width / 2, y: -length, width: width, height: length + tail),
                         cornerRadius: width / 2)
        let transform = CGAffineTransform(translationX: center.x, y: center.y).rotated(by: CGFloat(angle))
        ctx.fill(local.applying(transform), with: .color(color))
    }
}

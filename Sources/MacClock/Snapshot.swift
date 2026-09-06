import SwiftUI
import AppKit
import ImageIO
import UniformTypeIdentifiers

/// Developer aid: renders each face to a PNG so the design can be checked
/// without a second display. `MacClock --snapshot <dir> [WxH] [HH:MM]`
@MainActor
enum Snapshot {
    static func run(arguments: [String]) {
        guard let dir = arguments.first else {
            FileHandle.standardError.write("usage: MacClock --snapshot <dir> [WxH] [HH:MM]\n".data(using: .utf8)!)
            exit(1)
        }
        var size = CGSize(width: 1280, height: 720)
        var date = Date()
        for arg in arguments.dropFirst() {
            if arg.contains("x"), let w = Double(arg.split(separator: "x")[0]), let h = Double(arg.split(separator: "x")[1]) {
                size = CGSize(width: w, height: h)
            } else if arg.contains(":") {
                let bits = arg.split(separator: ":").compactMap { Int($0) }
                if bits.count == 2 {
                    date = Calendar.current.date(bySettingHour: bits[0], minute: bits[1], second: 0, of: Date()) ?? date
                }
            }
        }

        try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)

        var jobs: [(name: String, face: ClockFace, theme: ClockTheme, use24: Bool)] = []
        for theme in ClockTheme.allCases {
            jobs.append(("sansDigital-\(theme.rawValue)", .sansDigital, theme, false))
            jobs.append(("classicAnalog-\(theme.rawValue)", .classicAnalog, theme, false))
        }
        jobs.append(("sansDigital-midnight-24h", .sansDigital, .midnight, true))
        for face in [ClockFace.sevenSegment, .vfd, .flipClock] {
            jobs.append((face.rawValue, face, .midnight, false))
            jobs.append((face.rawValue + "-24h", face, .midnight, true))
        }

        for job in jobs {
            let view = FaceView(face: job.face, theme: job.theme, date: date, use24Hour: job.use24, showDate: true)
                .frame(width: size.width, height: size.height)
            let renderer = ImageRenderer(content: view)
            renderer.scale = 1
            renderer.proposedSize = ProposedViewSize(size)
            guard let image = renderer.cgImage else {
                print("failed to render \(job.name)")
                continue
            }
            let url = URL(fileURLWithPath: dir).appendingPathComponent(job.name + ".png")
            write(image, to: url)
            print("wrote \(url.path)")
        }
    }

    private static func write(_ image: CGImage, to url: URL) {
        guard let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else { return }
        CGImageDestinationAddImage(dest, image, nil)
        CGImageDestinationFinalize(dest)
    }
}

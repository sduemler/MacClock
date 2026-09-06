import AppKit

// Entry point. `MacClock --snapshot <dir> [WxH] [HH:MM]` renders every face to PNG
// files and exits; anything else launches the menu bar app.
if let index = CommandLine.arguments.firstIndex(of: "--snapshot") {
    _ = NSApplication.shared
    let rest = Array(CommandLine.arguments[(index + 1)...])
    MainActor.assumeIsolated {
        Snapshot.run(arguments: rest)
    }
    exit(0)
} else {
    MacClockApp.main()
}

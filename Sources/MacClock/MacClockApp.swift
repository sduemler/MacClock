import SwiftUI
import AppKit
import ServiceManagement

struct MacClockApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate

    var body: some Scene {
        MenuBarExtra {
            MenuContent()
        } label: {
            Image(systemName: "clock")
        }
        .menuBarExtraStyle(.menu)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var windowController: ClockWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // No Dock icon; the menu bar item is the only UI besides the clock window.
        NSApp.setActivationPolicy(.accessory)
        windowController = ClockWindowController(model: ClockModel.shared, settings: ClockSettings.shared)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}

struct MenuContent: View {
    @ObservedObject private var settings = ClockSettings.shared
    @State private var launchAtLogin = LaunchAtLogin.isEnabled

    var body: some View {
        Picker("Clock Face", selection: $settings.face) {
            ForEach(ClockFace.allCases) { face in
                Text(face.displayName).tag(face)
            }
        }

        Picker("Color Scheme", selection: $settings.theme) {
            ForEach(ClockTheme.dark) { theme in
                Text(theme.displayName).tag(theme)
            }
            Divider()
            ForEach(ClockTheme.light) { theme in
                Text(theme.displayName).tag(theme)
            }
        }

        Picker("Display", selection: $settings.targetDisplayName) {
            Text("Preview Window").tag("")
            Divider()
            ForEach(NSScreen.screens, id: \.localizedName) { screen in
                Text(screen.localizedName).tag(screen.localizedName)
            }
        }

        Divider()

        Toggle("24-Hour Time", isOn: $settings.use24Hour)
        Toggle("Show Date", isOn: $settings.showDate)
        Toggle("Always on Top", isOn: $settings.alwaysOnTop)
        Toggle("Launch at Login", isOn: Binding(
            get: { launchAtLogin },
            set: { enabled in
                LaunchAtLogin.set(enabled)
                launchAtLogin = LaunchAtLogin.isEnabled
            }
        ))

        Divider()

        Button("Quit MacClock") {
            NSApp.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}

enum LaunchAtLogin {
    static var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    static func set(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            // Fails when running outside an .app bundle (e.g. `swift run`); harmless.
            NSLog("Launch at login change failed: \(error.localizedDescription)")
        }
    }
}

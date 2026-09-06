import AppKit
import SwiftUI
import Combine

/// Owns the single clock window and keeps it parked on the chosen display.
@MainActor
final class ClockWindowController {
    private let window: ClockWindow
    private let settings: ClockSettings
    private var cancellables = Set<AnyCancellable>()
    private var observers: [NSObjectProtocol] = []
    private var previewWindowPlaced = false

    static let previewSize = NSSize(width: 1280, height: 720)

    init(model: ClockModel, settings: ClockSettings) {
        self.settings = settings

        window = ClockWindow(
            contentRect: NSRect(origin: .zero, size: ClockWindowController.previewSize),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.isReleasedWhenClosed = false
        window.backgroundColor = .black
        window.isOpaque = true
        window.hasShadow = false
        window.title = "MacClock"
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]
        window.isMovableByWindowBackground = true
        window.animationBehavior = .none

        let root = ClockRootView()
            .environmentObject(model)
            .environmentObject(settings)
        window.contentView = NSHostingView(rootView: root)

        if !settings.hasChosenDisplay {
            settings.targetDisplayName = ClockWindowController.guessDockDisplay()?.localizedName ?? ""
        }

        settings.$targetDisplayName
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.place() }
            .store(in: &cancellables)
        settings.$alwaysOnTop
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.place() }
            .store(in: &cancellables)

        observers.append(NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.place() }
        })

        place()
    }

    /// On first launch with several displays attached, the smallest non-main
    /// screen is almost certainly the dock's panel.
    private static func guessDockDisplay() -> NSScreen? {
        let candidates = NSScreen.screens.filter { $0 != NSScreen.main }
        return candidates.min { a, b in
            a.frame.width * a.frame.height < b.frame.width * b.frame.height
        }
    }

    private func targetScreen() -> NSScreen? {
        let name = settings.targetDisplayName
        guard !name.isEmpty, name != ClockSettings.unset else { return nil }
        return NSScreen.screens.first { $0.localizedName == name }
    }

    func place() {
        window.level = settings.alwaysOnTop ? .floating : .normal

        if let screen = targetScreen() {
            window.styleMask = [.borderless]
            window.setFrame(screen.frame, display: true)
            window.orderFrontRegardless()
        } else {
            // Target display absent (or preview chosen): show a normal resizable window.
            window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
            window.title = "MacClock"
            if !previewWindowPlaced {
                window.setContentSize(ClockWindowController.previewSize)
                window.center()
                previewWindowPlaced = true
            }
            window.makeKeyAndOrderFront(nil)
        }
    }
}

final class ClockWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

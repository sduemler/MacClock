import AppKit
import Combine

/// Publishes the current time, updating exactly once per minute (plus on wake,
/// clock changes, and time zone changes). Nothing in the app redraws between ticks.
@MainActor
final class ClockModel: ObservableObject {
    static let shared = ClockModel()

    @Published private(set) var now = Date()

    private var timer: Timer?
    private var observers: [NSObjectProtocol] = []

    private init() {
        scheduleNextTick()

        let workspace = NSWorkspace.shared.notificationCenter
        observers.append(workspace.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        })
        let center = NotificationCenter.default
        for name in [Notification.Name.NSSystemClockDidChange, .NSSystemTimeZoneDidChange, .NSCalendarDayChanged] {
            observers.append(center.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                Task { @MainActor in self?.refresh() }
            })
        }
    }

    func refresh() {
        now = Date()
        scheduleNextTick()
    }

    private func scheduleNextTick() {
        timer?.invalidate()
        let current = Date()
        let nextMinute = Calendar.current.nextDate(
            after: current,
            matching: DateComponents(second: 0),
            matchingPolicy: .nextTime
        ) ?? current.addingTimeInterval(60)

        // Fire a hair after the boundary so the displayed minute has definitely rolled over.
        let fireDate = nextMinute.addingTimeInterval(0.05)
        let t = Timer(fire: fireDate, interval: 0, repeats: false) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
        t.tolerance = 0.25
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }
}

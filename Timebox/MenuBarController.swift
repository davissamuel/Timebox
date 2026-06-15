import AppKit
import UserNotifications

class MenuBarController: NSObject {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover?
    private let overlayWindow = TimerOverlayWindow()
    private var timer: Timer?
    private var duration: TimeInterval = 0
    private var elapsed: TimeInterval = 0

    override init() {
        super.init()
        setupStatusItem()
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        Task {
            try? await center.requestAuthorization(options: [.alert])
        }
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "timer", accessibilityDescription: "Timebox")
            button.action = #selector(statusItemClicked)
            button.target = self
        }
    }

    @objc private func statusItemClicked() {
        if let existing = popover, existing.isShown {
            existing.performClose(nil)
            return
        }

        guard let button = statusItem.button else { return }

        let vc = TimerInputViewController(isRunning: timer != nil)
        vc.onStart = { [weak self] minutes in self?.startTimer(duration: minutes * 60) }
        vc.onStop = { [weak self] in self?.stopTimer() }

        let p = NSPopover()
        p.contentViewController = vc
        p.behavior = .transient
        popover = p
        p.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
    }

    private func startTimer(duration: TimeInterval) {
        stopTimer()
        self.duration = duration
        self.elapsed = 0

        overlayWindow.reset()
        overlayWindow.orderFront(nil)

        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        overlayWindow.orderOut(nil)
    }

    private func tick() {
        elapsed += 0.05
        let progress = min(elapsed / duration, 1.0)
        overlayWindow.setProgress(progress)

        if progress >= 1.0 {
            finish()
        }
    }

    private func finish() {
        timer?.invalidate()
        timer = nil

        overlayWindow.pulse { [weak self] in
            self?.overlayWindow.orderOut(nil)
        }

        sendNotification()
    }

    private func sendNotification() {
        Task {
            let content = UNMutableNotificationContent()
            content.title = "Time's up!"
            content.body = "Your timebox is complete."
            content.sound = nil
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            try? await UNUserNotificationCenter.current().add(request)
        }
    }
}

extension MenuBarController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner])
    }
}

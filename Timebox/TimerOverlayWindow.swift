import AppKit

class TimerOverlayWindow: NSWindow {
    private static let barHeight: CGFloat = 5
    private let progressLayer = CALayer()
    private let rightProgressLayer = CALayer()
    private var pulseTimer: Timer?
    private var leftWidth: CGFloat = 0
    private var notchRight: CGFloat = 0
    private var rightWidth: CGFloat = 0

    init() {
        super.init(contentRect: .zero, styleMask: .borderless, backing: .buffered, defer: false)

        isOpaque = false
        backgroundColor = .clear
        level = .screenSaver
        ignoresMouseEvents = true
        collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]

        let container = NSView(frame: .zero)
        container.wantsLayer = true
        contentView = container

        progressLayer.frame = CGRect(x: 0, y: 0, width: 0, height: Self.barHeight)
        progressLayer.backgroundColor = NSColor.systemGreen.cgColor
        container.layer?.addSublayer(progressLayer)

        rightProgressLayer.frame = CGRect(x: 0, y: 0, width: 0, height: Self.barHeight)
        rightProgressLayer.backgroundColor = NSColor.systemGreen.cgColor
        container.layer?.addSublayer(rightProgressLayer)

        updateGeometry()
    }

    // The screen arrangement (resolution, notch, docked monitors) can change while this
    // long-lived login-item window sits idle, so geometry is recomputed on every run
    // instead of being cached once at launch.
    private func updateGeometry() {
        let screen = NSScreen.screens.first { $0.frame.origin == .zero } ?? NSScreen.main!
        let frame = NSRect(
            x: screen.frame.minX,
            y: screen.frame.maxY - Self.barHeight,
            width: screen.frame.width,
            height: Self.barHeight
        )
        setFrame(frame, display: false)
        contentView?.frame = NSRect(origin: .zero, size: frame.size)

        if let leftArea = screen.auxiliaryTopLeftArea,
           let rightArea = screen.auxiliaryTopRightArea {
            // maxX = x where the notch begins; minX = x where the right side resumes
            leftWidth = leftArea.maxX
            notchRight = rightArea.minX
            rightWidth = screen.frame.width - rightArea.minX
        } else {
            // No notch: single bar spans the full screen width
            leftWidth = screen.frame.width
            notchRight = screen.frame.width
            rightWidth = 0
        }

        rightProgressLayer.frame.origin.x = notchRight
    }

    func reset() {
        pulseTimer?.invalidate()
        pulseTimer = nil
        alphaValue = 1.0
        updateGeometry()
        setProgress(0)
    }

    func setProgress(_ progress: Double) {
        let totalVisible = leftWidth + rightWidth
        let fill = CGFloat(progress) * totalVisible
        let leftFill = min(fill, leftWidth)
        let rightFill = max(fill - leftWidth, 0)
        let color = barColor(for: progress).cgColor

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        progressLayer.frame.size.width = leftFill
        rightProgressLayer.frame.size.width = rightFill
        progressLayer.backgroundColor = color
        rightProgressLayer.backgroundColor = color
        CATransaction.commit()
    }

    private func barColor(for progress: Double) -> NSColor {
        if progress <= 0.7 {
            let t = CGFloat(progress / 0.7)
            return NSColor(red: t, green: 1.0, blue: 0, alpha: 1)
        } else {
            let t = CGFloat((progress - 0.7) / 0.3)
            return NSColor(red: 1.0, green: 1.0 - t, blue: 0, alpha: 1)
        }
    }

    func pulse(completion: @escaping () -> Void) {
        pulseTimer?.invalidate()
        var flashes = 0
        pulseTimer = Timer.scheduledTimer(withTimeInterval: 0.12, repeats: true) { [weak self] t in
            flashes += 1
            let visible = flashes % 2 == 0
            self?.alphaValue = visible ? 1.0 : 0.0
            if visible {
                NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .now)
            }
            if flashes >= 6 {
                t.invalidate()
                self?.pulseTimer = nil
                completion()
            }
        }
    }
}

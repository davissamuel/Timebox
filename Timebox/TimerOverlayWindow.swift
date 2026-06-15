import AppKit

class TimerOverlayWindow: NSWindow {
    private static let barHeight: CGFloat = 3
    private let progressLayer = CALayer()

    init() {
        let screen = NSScreen.screens.first { $0.frame.origin == .zero } ?? NSScreen.main!
        let frame = NSRect(
            x: screen.frame.minX,
            y: screen.frame.maxY - Self.barHeight,
            width: screen.frame.width,
            height: Self.barHeight
        )

        super.init(contentRect: frame, styleMask: .borderless, backing: .buffered, defer: false)

        isOpaque = false
        backgroundColor = .clear
        level = .screenSaver
        ignoresMouseEvents = true
        collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]

        let container = NSView(frame: NSRect(origin: .zero, size: frame.size))
        container.wantsLayer = true
        contentView = container

        progressLayer.frame = CGRect(x: 0, y: 0, width: 0, height: Self.barHeight)
        progressLayer.backgroundColor = NSColor.systemGreen.cgColor
        container.layer?.addSublayer(progressLayer)
    }

    func setProgress(_ progress: Double) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        progressLayer.frame.size.width = frame.width * CGFloat(progress)
        progressLayer.backgroundColor = barColor(for: progress).cgColor
        CATransaction.commit()
    }

    private func barColor(for progress: Double) -> NSColor {
        if progress <= 0.5 {
            let t = CGFloat(progress / 0.5)
            return NSColor(red: t, green: 1.0, blue: 0, alpha: 1)
        } else {
            let t = CGFloat((progress - 0.5) / 0.5)
            return NSColor(red: 1.0, green: 1.0 - t, blue: 0, alpha: 1)
        }
    }

    func pulse(completion: @escaping () -> Void) {
        var flashes = 0
        Timer.scheduledTimer(withTimeInterval: 0.12, repeats: true) { [weak self] t in
            flashes += 1
            self?.alphaValue = flashes % 2 == 0 ? 1.0 : 0.0
            if flashes >= 6 {
                t.invalidate()
                completion()
            }
        }
    }
}

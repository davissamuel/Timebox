import AppKit

class TimerInputViewController: NSViewController {
    var onStart: ((TimeInterval) -> Void)?
    var onStop: (() -> Void)?

    private let isRunning: Bool
    private let remaining: TimeInterval
    private let textField = NSTextField()
    private static let viewWidth: CGFloat = 240

    init(isRunning: Bool, remaining: TimeInterval = 0) {
        self.isRunning = isRunning
        self.remaining = remaining
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func loadView() {
        let height: CGFloat = isRunning ? 118 : 88
        view = NSView(frame: NSRect(x: 0, y: 0, width: Self.viewWidth, height: height))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        preferredContentSize = view.frame.size
        isRunning ? buildRunningLayout() : buildIdleLayout()
    }

    private func buildIdleLayout() {
        let presetsRow = makePresetsRow()
        presetsRow.translatesAutoresizingMaskIntoConstraints = false
        let inputRow = makeInputRow()
        inputRow.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(presetsRow)
        view.addSubview(inputRow)

        NSLayoutConstraint.activate([
            presetsRow.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            presetsRow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            presetsRow.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            presetsRow.heightAnchor.constraint(equalToConstant: 28),

            inputRow.topAnchor.constraint(equalTo: presetsRow.bottomAnchor, constant: 8),
            inputRow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            inputRow.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            inputRow.heightAnchor.constraint(equalToConstant: 28),
        ])
    }

    private func buildRunningLayout() {
        let remainingLabel = NSTextField(labelWithString: formatRemaining(remaining))
        remainingLabel.font = .monospacedDigitSystemFont(ofSize: 14, weight: .medium)
        remainingLabel.alignment = .center
        remainingLabel.translatesAutoresizingMaskIntoConstraints = false

        let inputRow = makeInputRow()
        inputRow.translatesAutoresizingMaskIntoConstraints = false

        let stopButton = NSButton(title: "Stop Timer", target: self, action: #selector(stopTapped))
        stopButton.bezelStyle = .push
        stopButton.attributedTitle = NSAttributedString(
            string: "Stop Timer",
            attributes: [.foregroundColor: NSColor.systemRed]
        )
        stopButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(remainingLabel)
        view.addSubview(inputRow)
        view.addSubview(stopButton)

        NSLayoutConstraint.activate([
            remainingLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            remainingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            remainingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            remainingLabel.heightAnchor.constraint(equalToConstant: 22),

            inputRow.topAnchor.constraint(equalTo: remainingLabel.bottomAnchor, constant: 8),
            inputRow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            inputRow.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            inputRow.heightAnchor.constraint(equalToConstant: 28),

            stopButton.topAnchor.constraint(equalTo: inputRow.bottomAnchor, constant: 8),
            stopButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            stopButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            stopButton.heightAnchor.constraint(equalToConstant: 28),
        ])
    }

    private func makePresetsRow() -> NSView {
        let container = NSView()
        let presets = [15, 25, 45, 60]
        var prevButton: NSButton?

        for minutes in presets {
            let btn = NSButton(title: "\(minutes)m", target: self, action: #selector(presetTapped(_:)))
            btn.tag = minutes
            btn.bezelStyle = .push
            btn.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(btn)

            NSLayoutConstraint.activate([
                btn.topAnchor.constraint(equalTo: container.topAnchor),
                btn.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            ])

            if let prev = prevButton {
                btn.leadingAnchor.constraint(equalTo: prev.trailingAnchor, constant: 6).isActive = true
                btn.widthAnchor.constraint(equalTo: prev.widthAnchor).isActive = true
            } else {
                btn.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
            }

            if minutes == presets.last {
                btn.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
            }

            prevButton = btn
        }

        return container
    }

    private func makeInputRow() -> NSView {
        let container = NSView()

        let label = NSTextField(labelWithString: "Minutes:")
        label.translatesAutoresizingMaskIntoConstraints = false

        textField.placeholderString = "25"
        textField.bezelStyle = .roundedBezel
        textField.translatesAutoresizingMaskIntoConstraints = false

        let startButton = NSButton(title: "Start", target: self, action: #selector(startTapped))
        startButton.bezelStyle = .push
        startButton.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(label)
        container.addSubview(textField)
        container.addSubview(startButton)

        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),

            textField.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            textField.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 8),
            textField.widthAnchor.constraint(equalToConstant: 50),

            startButton.topAnchor.constraint(equalTo: container.topAnchor),
            startButton.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            startButton.leadingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 8),
            startButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        ])

        return container
    }

    @objc private func presetTapped(_ sender: NSButton) {
        dismiss(nil)
        onStart?(TimeInterval(sender.tag) * 60)
    }

    @objc private func startTapped() {
        guard let minutes = Double(textField.stringValue), minutes > 0 else { return }
        dismiss(nil)
        onStart?(minutes * 60)
    }

    @objc private func stopTapped() {
        let alert = NSAlert()
        alert.messageText = "Stop timer?"
        alert.informativeText = "\(formatRemaining(remaining)) left on the clock."
        alert.addButton(withTitle: "Stop")
        alert.addButton(withTitle: "Keep going")
        alert.alertStyle = .warning
        guard alert.runModal() == .alertFirstButtonReturn else { return }
        dismiss(nil)
        onStop?()
    }

    private func formatRemaining(_ seconds: TimeInterval) -> String {
        let total = max(0, Int(seconds))
        return String(format: "%d:%02d remaining", total / 60, total % 60)
    }
}

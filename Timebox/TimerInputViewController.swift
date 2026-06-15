import AppKit

class TimerInputViewController: NSViewController {
    var onStart: ((TimeInterval) -> Void)?
    var onStop: (() -> Void)?

    private let isRunning: Bool
    private let textField = NSTextField()

    init(isRunning: Bool) {
        self.isRunning = isRunning
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 200, height: 60))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let label = NSTextField(labelWithString: "Minutes:")
        label.translatesAutoresizingMaskIntoConstraints = false

        textField.placeholderString = "25"
        textField.bezelStyle = .roundedBezel
        textField.translatesAutoresizingMaskIntoConstraints = false

        let startButton = NSButton(title: "Start", target: self, action: #selector(startTapped))
        startButton.bezelStyle = .push
        startButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(label)
        view.addSubview(textField)
        view.addSubview(startButton)

        var constraints: [NSLayoutConstraint] = [
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),

            textField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            textField.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 8),
            textField.widthAnchor.constraint(equalToConstant: 50),

            startButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            startButton.leadingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 8),
            startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
        ]

        if isRunning {
            let stopButton = NSButton(title: "Stop", target: self, action: #selector(stopTapped))
            stopButton.bezelStyle = .push
            stopButton.contentTintColor = .systemRed
            stopButton.translatesAutoresizingMaskIntoConstraints = false
            view.frame.size.height = 90
            view.addSubview(stopButton)
            constraints += [
                stopButton.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 8),
                stopButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ]
        }

        NSLayoutConstraint.activate(constraints)
    }

    @objc private func startTapped() {
        guard let minutes = Double(textField.stringValue), minutes > 0 else { return }
        dismiss(nil)
        onStart?(minutes)
    }

    @objc private func stopTapped() {
        dismiss(nil)
        onStop?()
    }
}

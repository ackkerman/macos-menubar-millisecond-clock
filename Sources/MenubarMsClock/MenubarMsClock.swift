import AppKit
import ServiceManagement

enum ClockFormat: String, CaseIterable {
    case hmsMilliseconds
    case hms
    case hourMinute
    case hmsSplitMilliseconds
    case msMilliseconds

    var dateFormat: String {
        switch self {
        case .hmsMilliseconds:
            return "HH:mm:ss.SSS"
        case .hms:
            return "HH:mm:ss"
        case .hourMinute:
            return "HH:mm"
        case .hmsSplitMilliseconds:
            return "HH:mm:ss\nSSS"
        case .msMilliseconds:
            return "mm:ss.SSS"
        }
    }

    var menuTitle: String {
        switch self {
        case .hmsMilliseconds:
            return "HH:mm:ss.SSS"
        case .hms:
            return "HH:mm:ss"
        case .hourMinute:
            return "HH:mm"
        case .hmsSplitMilliseconds:
            return "HH:mm:ss \\n SSS"
        case .msMilliseconds:
            return "mm:ss.SSS"
        }
    }
}

private enum DefaultsKey {
    static let clockFormat = "ClockFormat"
}

// シンプルなメニューバー常駐時計。AppKitのみを利用し、メニューは持たない。
@MainActor
@main
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var timer: DispatchSourceTimer?
    private var formatter: DateFormatter
    private var clockFormat: ClockFormat
    private weak var formatMenu: NSMenu?

    // 更新間隔を調整しやすいよう定数で保持（10ms）
    private let updateInterval: DispatchTimeInterval = .nanoseconds(10_000_000)
    private let leeway: DispatchTimeInterval = .milliseconds(1)

    override init() {
        let savedFormat = UserDefaults.standard.clockFormat ?? .hmsMilliseconds
        self.clockFormat = savedFormat
        self.formatter = makeClockFormatter(for: savedFormat)
        super.init()
    }

    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        _ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        setupStatusItem()
        setupMenu()
        startTimer()
        updateTitle()
    }

    func applicationWillTerminate(_ notification: Notification) {
        timer?.cancel()
        timer = nil
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.font = NSFont.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        statusItem?.button?.title = formatter.string(from: Date())
    }

    private func setupMenu() {
        let menu = NSMenu()
        let formatMenu = NSMenu(title: "表示形式")

        ClockFormat.allCases.enumerated().forEach { index, format in
            let item = NSMenuItem(title: format.menuTitle, action: #selector(selectFormat(_:)), keyEquivalent: "")
            item.target = self
            item.state = (format == clockFormat) ? .on : .off
            item.tag = index
            item.identifier = NSUserInterfaceItemIdentifier(format.rawValue)
            formatMenu.addItem(item)
        }

        let formatMenuItem = NSMenuItem(title: "表示形式", action: nil, keyEquivalent: "")
        formatMenuItem.submenu = formatMenu
        menu.addItem(formatMenuItem)

        let runOnStartupItem = NSMenuItem(title: "Run on Startup", action: #selector(toggleRunOnStartup(_:)), keyEquivalent: "")
        runOnStartupItem.target = self
        runOnStartupItem.state = isLaunchAtLoginEnabled ? .on : .off
        menu.addItem(runOnStartupItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit MenubarMsClock", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem?.menu = menu
        self.formatMenu = formatMenu
    }

    private func startTimer() {
        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        timer.schedule(deadline: .now(), repeating: updateInterval, leeway: leeway)
        timer.setEventHandler { [weak self] in
            self?.updateTitle()
        }
        timer.resume()
        self.timer = timer
    }

    private func updateTitle(with date: Date = Date()) {
        let text = formatter.string(from: date)
        if clockFormat == .hmsSplitMilliseconds {
            statusItem?.button?.attributedTitle = makeTwoLineTitle(from: text)
        } else {
            statusItem?.button?.attributedTitle = NSAttributedString(
                string: text,
                attributes: [.font: NSFont.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)]
            )
        }
    }

    private func updateFormatMenuSelection() {
        formatMenu?.items.forEach { item in
            let matches = item.identifier?.rawValue == clockFormat.rawValue
            item.state = matches ? .on : .off
        }
    }

    private var isLaunchAtLoginEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    @objc private func selectFormat(_ sender: NSMenuItem) {
        guard let identifier = sender.identifier?.rawValue,
              let selectedFormat = ClockFormat(rawValue: identifier),
              selectedFormat != clockFormat else {
            return
        }

        clockFormat = selectedFormat
        formatter = makeClockFormatter(for: selectedFormat)
        UserDefaults.standard.clockFormat = selectedFormat
        updateFormatMenuSelection()
        updateTitle()
    }

    @objc private func toggleRunOnStartup(_ sender: NSMenuItem) {
        let shouldEnable = sender.state == .off
        do {
            if shouldEnable {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            NSLog("[MenubarMsClock] Failed to toggle launch at login: \(error.localizedDescription)")
        }
        sender.state = isLaunchAtLoginEnabled ? .on : .off
    }

    @objc private func quit() {
        NSApp.terminate(self)
    }
}

private func makeTwoLineTitle(from text: String) -> NSAttributedString {
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .center
    paragraphStyle.minimumLineHeight = NSFont.systemFontSize + 4
    paragraphStyle.maximumLineHeight = NSFont.systemFontSize + 4
    paragraphStyle.lineBreakMode = .byWordWrapping

    return NSAttributedString(
        string: text,
        attributes: [
            .font: NSFont.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize, weight: .regular),
            .paragraphStyle: paragraphStyle
        ]
    )
}

// formatter生成を分離し、テスト可能にする。
func makeClockFormatter(for format: ClockFormat) -> DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = format.dateFormat
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone.current
    return formatter
}

private extension UserDefaults {
    var clockFormat: ClockFormat? {
        get {
            string(forKey: DefaultsKey.clockFormat).flatMap { ClockFormat(rawValue: $0) }
        }
        set {
            set(newValue?.rawValue, forKey: DefaultsKey.clockFormat)
        }
    }
}

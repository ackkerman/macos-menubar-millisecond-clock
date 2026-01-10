import AppKit

// シンプルなメニューバー常駐時計。AppKitのみを利用し、メニューは持たない。
@MainActor
@main
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var timer: DispatchSourceTimer?

    // 更新間隔を調整しやすいよう定数で保持（10ms）
    private let updateInterval: DispatchTimeInterval = .nanoseconds(10_000_000)
    private let leeway: DispatchTimeInterval = .milliseconds(1)

    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        _ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        setupStatusItem()
        startTimer()
    }

    func applicationWillTerminate(_ notification: Notification) {
        timer?.cancel()
        timer = nil
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.font = NSFont.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        statusItem?.button?.title = formattedNow()
    }

    private func startTimer() {
        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        timer.schedule(deadline: .now(), repeating: updateInterval, leeway: leeway)
        timer.setEventHandler { [weak self] in
            guard let self else { return }
            self.statusItem?.button?.title = formattedNow()
        }
        timer.resume()
        self.timer = timer
    }
}

// formatter生成を分離し、テスト可能にする。
func makeClockFormatter() -> DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss.SSS"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone.current
    return formatter
}

private func formattedNow() -> String {
    makeClockFormatter().string(from: Date())
}

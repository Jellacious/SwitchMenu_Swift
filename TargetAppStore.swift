import AppKit
import Combine

final class TargetAppStore: ObservableObject {
    private static let key = "targetAppBundleIdentifier"

    @Published var bundleIdentifier: String? {
        didSet { UserDefaults.standard.set(bundleIdentifier, forKey: Self.key) }
    }

    init() {
        bundleIdentifier = UserDefaults.standard.string(forKey: Self.key)
    }

    static func runningRegularApps() -> [NSRunningApplication] {
        NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular }
            .filter { $0.bundleIdentifier != Bundle.main.bundleIdentifier }
    }

    var runningTargetApp: NSRunningApplication? {
        guard let id = bundleIdentifier else { return nil }
        return NSWorkspace.shared.runningApplications
            .first { $0.bundleIdentifier == id }
    }
}

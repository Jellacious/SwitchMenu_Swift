import AppKit
import Combine

/// Mémorise quelle app doit reprendre le focus (et donc le Space/plein écran)
/// juste après l'ouverture de l'overlay. Choisie manuellement dans les Settings,
/// car "l'app frontmost au lancement" n'est pas fiable (peut être un intermédiaire
/// qui a servi à lancer SwitchMenu, pas le jeu lui-même).
final class TargetAppStore: ObservableObject {
    private static let key = "targetAppBundleIdentifier"

    @Published var bundleIdentifier: String? {
        didSet { UserDefaults.standard.set(bundleIdentifier, forKey: Self.key) }
    }

    init() {
        bundleIdentifier = UserDefaults.standard.string(forKey: Self.key)
    }

    /// Apps normales actuellement ouvertes (hors Dock/agents), pour le picker.
    static func runningRegularApps() -> [NSRunningApplication] {
        NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy == .regular }
            .filter { $0.bundleIdentifier != Bundle.main.bundleIdentifier }
    }

    /// L'app mémorisée, si elle est toujours en cours d'exécution.
    var runningTargetApp: NSRunningApplication? {
        guard let id = bundleIdentifier else { return nil }
        return NSWorkspace.shared.runningApplications
            .first { $0.bundleIdentifier == id }
    }
}

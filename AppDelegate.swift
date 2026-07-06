import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    var controllerManager: GameControllerManager?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Force le mode "agent" : pas d'icône dans le Dock, même si l'Info.plist
        // généré par Xcode ne reprend pas la clé LSUIElement.
        NSApp.setActivationPolicy(.accessory)
    }

    // L'app se ferme dès que la fenêtre de menu est fermée
    // => macOS la relancera au prochain appui sur HOME
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}

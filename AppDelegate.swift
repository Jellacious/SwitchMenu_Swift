import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    var controllerManager: GameControllerManager?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }

    // L'app se ferme dès que la fenêtre de menu est fermée
    // => macOS la relancera au prochain appui sur HOME
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}

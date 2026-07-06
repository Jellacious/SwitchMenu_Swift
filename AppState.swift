import AppKit
import Combine

enum AppMode {
    case menu
    case mouse
}

enum NavigationDirection {
    case up, down, left, right
}

final class AppState: ObservableObject {
    @Published var mode: AppMode = .menu
    @Published var selectedIndex: Int = 0
    @Published var isShowingSettings: Bool = false

    let shortcutStore = ShortcutStore()
    let mappingStore = KeyMappingStore()
    let targetAppStore = TargetAppStore()

    var shortcuts: [ShortcutItem] { shortcutStore.shortcuts }

    func runSelectedShortcut() {
        guard shortcuts.indices.contains(selectedIndex) else { return }
        ShortcutRunner.run(name: shortcuts[selectedIndex].name)
    }

    func navigate(_ direction: NavigationDirection) {
        let count = shortcuts.count
        guard count > 0 else { return }
        switch direction {
        case .left:
            selectedIndex = (selectedIndex - 1 + count) % count
        case .right:
            selectedIndex = (selectedIndex + 1) % count
        case .up, .down:
            break
        }
    }

    func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}

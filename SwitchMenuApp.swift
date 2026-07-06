import SwiftUI

@main
struct SwitchMenuApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var state = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(state)
                .onAppear {
                    NSApp.windows.first?.orderOut(nil)

                    appDelegate.controllerManager = GameControllerManager(appState: state)
                    DispatchQueue.main.async {
                        configureWindow(state: state)
                    }
                }
                .onChange(of: state.mode) { _, newMode in
                    // Laisse SwiftUI appliquer la nouvelle taille de contenu
                    // (via .frame dans ContentView) avant de repositionner.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                        repositionWindow(for: newMode)
                    }
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }

    private func configureWindow(state: AppState) {
        guard let window = NSApp.windows.first else { return }

        window.isRestorable = false

        window.styleMask.remove(.resizable)
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true

        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.level = .floating

        window.center()

        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)

        if let targetApp = state.targetAppStore.runningTargetApp {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                targetApp.activate(options: [.activateAllWindows])
            }
        }
    }

    private func repositionWindow(for mode: AppMode) {
        guard let window = NSApp.windows.first,
              let screen = window.screen ?? NSScreen.main else { return }

        let frame = window.frame
        let visible = screen.visibleFrame

        let origin: CGPoint
        switch mode {
        case .mouse:
            origin = CGPoint(x: visible.maxX - frame.width - 24,
                              y: visible.maxY - frame.height - 24)
        case .menu:
            origin = CGPoint(x: visible.midX - frame.width / 2,
                              y: visible.midY - frame.height / 2)
        }

        window.setFrameOrigin(origin)
    }
}

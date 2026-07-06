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
                    // Cache immédiatement la fenêtre auto-affichée par SwiftUI.
                    // Sinon elle est déjà "posée" sur le Bureau courant AVANT
                    // qu'on ait pu mettre .canJoinAllSpaces, et macOS la laisse
                    // coincée sur le Bureau 1 au lieu de suivre le jeu plein écran.
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

        // Ne pas restaurer une position précédente
        window.isRestorable = false

        window.styleMask.remove(.resizable)
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true

        // Permet à la fenêtre d'apparaître PAR-DESSUS une app en plein écran
        // (ex: un jeu) sans changer de Bureau/Space, et sur tous les Spaces.
        // Ces réglages doivent être posés AVANT le premier affichage.
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.level = .floating

        window.center()

        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)

        // Le passage à .activate ci-dessus a pu faire basculer macOS vers le
        // Bureau "natif" de la fenêtre. On redonne le focus à l'app cible
        // choisie dans les Settings juste après : comme notre fenêtre est
        // .canJoinAllSpaces + .floating, elle reste visible par-dessus, mais
        // macOS revient sur le bon Space/plein écran.
        if let targetApp = state.targetAppStore.runningTargetApp {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                targetApp.activate(options: [.activateAllWindows])
            }
        }
    }

    /// En mode souris, la fenêtre passe en petit badge dans un coin pour ne
    /// pas masquer le jeu/l'app en dessous. En mode menu, elle revient au
    /// centre de l'écran courant.
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

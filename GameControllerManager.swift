import GameController

final class GameControllerManager {
    private var controller: GCController?
    private weak var appState: AppState?
    private var mappingStore: KeyMappingStore { appState!.mappingStore }

    // Debounce du joystick gauche pour la navigation en grille
    private var stickNeutral = true
    private let stickThreshold: Float = 0.5
    private let stickReleaseThreshold: Float = 0.3

    init(appState: AppState) {
        self.appState = appState
        GCController.shouldMonitorBackgroundEvents = true
        NotificationCenter.default.addObserver(self, selector: #selector(controllerConnected),
                                                 name: .GCControllerDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(controllerDisconnected),
                                                 name: .GCControllerDidDisconnect, object: nil)
        if let existing = GCController.controllers().first {
            setupHandlers(existing)
        }
    }

    @objc private func controllerConnected(_ note: Notification) {
        guard let controller = note.object as? GCController else { return }
        setupHandlers(controller)
    }

    @objc private func controllerDisconnected(_ note: Notification) {
        controller = nil
    }

    private func setupHandlers(_ controller: GCController) {
        self.controller = controller
        guard let gamepad = controller.extendedGamepad else { return }

        gamepad.buttonHome?.pressedChangedHandler = { [weak self] _, _, pressed in
            guard pressed else { return }
            DispatchQueue.main.async { self?.appState?.quitApp() }
        }

        // Table bouton physique -> input GCControllerButtonInput
        let buttons: [ButtonIdentifier: GCControllerButtonInput] = [
            .aButton: gamepad.buttonA,
            .bButton: gamepad.buttonB,
            .xButton: gamepad.buttonX,
            .yButton: gamepad.buttonY,
            .leftShoulder: gamepad.leftShoulder,
            .rightShoulder: gamepad.rightShoulder,
            .leftTrigger: gamepad.leftTrigger,
            .rightTrigger: gamepad.rightTrigger,
            .dpadUp: gamepad.dpad.up,
            .dpadDown: gamepad.dpad.down,
            .dpadLeft: gamepad.dpad.left,
            .dpadRight: gamepad.dpad.right,
            .leftThumbstickButton: gamepad.leftThumbstickButton,
            .rightThumbstickButton: gamepad.rightThumbstickButton
        ].compactMapValues { $0 }

        for (identifier, input) in buttons {
            input.pressedChangedHandler = { [weak self] _, _, pressed in
                guard pressed else { return }
                DispatchQueue.main.async { self?.handlePress(of: identifier) }
            }
        }

        // Joystick gauche : navigation en grille (mode menu) ou curseur (mode souris)
        gamepad.leftThumbstick.valueChangedHandler = { [weak self] _, x, y in
            guard let self, let state = self.appState else { return }
            if state.mode == .mouse {
                MouseController.shared.move(dx: CGFloat(x), dy: CGFloat(y))
            } else {
                self.handleStickNavigation(x: x, y: y)
            }
        }
    }

    private func handlePress(of identifier: ButtonIdentifier) {
        guard let state = appState else { return }

        if mappingStore.capturingAction != nil {
            mappingStore.assign(button: identifier)
            return
        }

        guard let action = mappingStore.action(for: identifier) else { return }

        switch action {
        case .navigateUp: if state.mode == .menu { state.navigate(.up) }
        case .navigateDown: if state.mode == .menu { state.navigate(.down) }
        case .navigateLeft: if state.mode == .menu { state.navigate(.left) }
        case .navigateRight: if state.mode == .menu { state.navigate(.right) }
        case .select:
            if state.mode == .mouse {
                MouseController.shared.click()
            } else {
                state.runSelectedShortcut()
            }
        case .back:
            if state.mode == .mouse {
                state.mode = .menu
            } else {
                state.quitApp()
            }
        case .toggleMouseMode:
            if state.mode == .menu { state.mode = .mouse }
        }
    }

    private func handleStickNavigation(x: Float, y: Float) {
        let magnitude = max(abs(x), abs(y))

        if stickNeutral {
            guard magnitude >= stickThreshold else { return }
            if abs(x) > abs(y) {
                appState?.navigate(x > 0 ? .right : .left)
            } else {
                appState?.navigate(y > 0 ? .up : .down)
            }
            stickNeutral = false
        } else if magnitude <= stickReleaseThreshold {
            stickNeutral = true
        }
    }
}

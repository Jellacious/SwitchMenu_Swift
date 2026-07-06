import Foundation
import Combine

final class KeyMappingStore: ObservableObject {
    @Published var mapping: [ControllerAction: ButtonIdentifier]
    @Published var capturingAction: ControllerAction? = nil  // action en attente d'un appui manette

    private let fileURL: URL

    static let defaultMapping: [ControllerAction: ButtonIdentifier] = [
        .navigateUp: .dpadUp,
        .navigateDown: .dpadDown,
        .navigateLeft: .dpadLeft,
        .navigateRight: .dpadRight,
        .select: .aButton,
        .back: .bButton,
        .toggleMouseMode: .rightShoulder
    ]

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("SwitchMenu")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("mapping.json")

        if let data = try? Data(contentsOf: fileURL),
           let raw = try? JSONDecoder().decode([String: String].self, from: data) {
            var restored: [ControllerAction: ButtonIdentifier] = [:]
            for (k, v) in raw {
                if let action = ControllerAction(rawValue: k), let button = ButtonIdentifier(rawValue: v) {
                    restored[action] = button
                }
            }
            mapping = restored.isEmpty ? KeyMappingStore.defaultMapping : restored
        } else {
            mapping = KeyMappingStore.defaultMapping
        }
    }

    func button(for action: ControllerAction) -> ButtonIdentifier? {
        mapping[action]
    }

    func action(for button: ButtonIdentifier) -> ControllerAction? {
        mapping.first(where: { $0.value == button })?.key
    }

    func assign(button: ButtonIdentifier) {
        guard let action = capturingAction else { return }
        // Retire ce bouton d'une éventuelle autre action pour éviter les doublons
        mapping = mapping.filter { $0.value != button }
        mapping[action] = button
        capturingAction = nil
        save()
    }

    func resetToDefaults() {
        mapping = KeyMappingStore.defaultMapping
        save()
    }

    private func save() {
        var raw: [String: String] = [:]
        for (k, v) in mapping { raw[k.rawValue] = v.rawValue }
        if let data = try? JSONEncoder().encode(raw) {
            try? data.write(to: fileURL)
        }
    }
}

import Foundation
import Combine
import SwiftUI

struct ShortcutItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String   // doit correspondre exactement au nom du raccourci dans l'app Shortcuts
    var icon: String   // nom d'un SF Symbol
}

final class ShortcutStore: ObservableObject {
    @Published var shortcuts: [ShortcutItem] = []
    private let fileURL: URL

    static let defaults: [ShortcutItem] = [
        ShortcutItem(name: "Ouvrir Safari", icon: "safari"),
        ShortcutItem(name: "Mode Nuit", icon: "moon.fill"),
        ShortcutItem(name: "Screenshot", icon: "camera.viewfinder"),
        ShortcutItem(name: "Volume Max", icon: "speaker.wave.3.fill"),
        ShortcutItem(name: "Lancer Musique", icon: "music.note"),
        ShortcutItem(name: "Verrouiller Mac", icon: "lock.fill")
    ]

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("SwitchMenu")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("shortcuts.json")
        load()
    }

    func load() {
        if let data = try? Data(contentsOf: fileURL),
           let items = try? JSONDecoder().decode([ShortcutItem].self, from: data) {
            shortcuts = items
        } else {
            shortcuts = ShortcutStore.defaults
            save()
        }
    }

    func save() {
        if let data = try? JSONEncoder().encode(shortcuts) {
            try? data.write(to: fileURL)
        }
    }

    func add(_ item: ShortcutItem) {
        shortcuts.append(item)
        save()
    }

    func update(_ item: ShortcutItem) {
        if let i = shortcuts.firstIndex(where: { $0.id == item.id }) {
            shortcuts[i] = item
            save()
        }
    }

    func remove(at offsets: IndexSet) {
        shortcuts.remove(atOffsets: offsets)
        save()
    }

    func remove(id: UUID) {
        shortcuts.removeAll { $0.id == id }
        save()
    }

    func move(from: IndexSet, to: Int) {
        shortcuts.move(fromOffsets: from, toOffset: to)
        save()
    }
}

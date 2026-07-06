import SwiftUI
import AppKit

struct SettingsView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var tab: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Réglages")
                    .font(.title3.bold())
                Spacer()
                Button("Fermer") { dismiss() }
            }
            .padding()

            Picker("", selection: $tab) {
                Text("Raccourcis").tag(0)
                Text("Manette").tag(1)
                Text("Retour").tag(2)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.bottom, 8)

            Divider()

            if tab == 0 {
                ShortcutsSettingsTab()
                    .environmentObject(state.shortcutStore)
            } else if tab == 1 {
                ControllerMappingTab()
                    .environmentObject(state.mappingStore)
            } else {
                TargetAppSettingsTab()
                    .environmentObject(state.targetAppStore)
            }
        }
        .frame(width: 480, height: 480)
    }
}


struct ShortcutsSettingsTab: View {
    @EnvironmentObject var store: ShortcutStore
    @State private var editingItem: ShortcutItem?
    @State private var isPresentingEditor = false

    var body: some View {
        VStack(spacing: 0) {
            List {
                ForEach(store.shortcuts) { item in
                    HStack {
                        Image(systemName: item.icon)
                            .frame(width: 24)
                        Text(item.name)
                        Spacer()
                        Button {
                            editingItem = item
                            isPresentingEditor = true
                        } label: {
                            Image(systemName: "pencil")
                        }
                        .buttonStyle(.plain)
                        Button {
                            store.remove(id: item.id)
                        } label: {
                            Image(systemName: "trash")
                                .foregroundStyle(.red)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .onDelete { store.remove(at: $0) }
                .onMove { store.move(from: $0, to: $1) }
            }
            .listStyle(.inset)

            Button {
                editingItem = nil
                isPresentingEditor = true
            } label: {
                Label("Ajouter un raccourci", systemImage: "plus")
                    .frame(maxWidth: .infinity)
            }
            .padding()
        }
        .sheet(isPresented: $isPresentingEditor) {
            ShortcutEditorView(item: editingItem) { result in
                if let existing = editingItem {
                    var updated = existing
                    updated.name = result.name
                    updated.icon = result.icon
                    store.update(updated)
                } else {
                    store.add(result)
                }
            }
        }
    }
}

struct ShortcutEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var icon: String
    let onSave: (ShortcutItem) -> Void

    init(item: ShortcutItem?, onSave: @escaping (ShortcutItem) -> Void) {
        _name = State(initialValue: item?.name ?? "")
        _icon = State(initialValue: item?.icon ?? "star")
        self.onSave = onSave
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(name.isEmpty ? "Nouveau raccourci" : "Modifier le raccourci")
                .font(.headline)

            VStack(alignment: .leading, spacing: 4) {
                Text("Nom du raccourci (doit correspondre à l'app Shortcuts)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("Ex : Ouvrir Safari", text: $name)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Icône (nom SF Symbol)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack {
                    TextField("Ex : safari", text: $icon)
                        .textFieldStyle(.roundedBorder)
                    Image(systemName: icon)
                        .frame(width: 30, height: 30)
                }
            }

            Text("Astuce : cherche un nom d'icône sur l'app SF Symbols d'Apple.")
                .font(.caption2)
                .foregroundStyle(.tertiary)

            Spacer()

            HStack {
                Spacer()
                Button("Annuler") { dismiss() }
                Button("Enregistrer") {
                    onSave(ShortcutItem(name: name, icon: icon))
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(24)
        .frame(width: 400, height: 300)
    }
}


struct ControllerMappingTab: View {
    @EnvironmentObject var mappingStore: KeyMappingStore

    var body: some View {
        VStack(spacing: 0) {
            List {
                ForEach(ControllerAction.allCases) { action in
                    HStack {
                        Text(action.displayName)
                        Spacer()
                        if mappingStore.capturingAction == action {
                            Text("Appuie sur un bouton…")
                                .foregroundStyle(Color.accentColor)
                                .font(.caption)
                        } else {
                            Text(mappingStore.button(for: action)?.displayName ?? "Non assigné")
                                .foregroundStyle(.secondary)
                            Button("Remapper") {
                                mappingStore.capturingAction = action
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }
            .listStyle(.inset)

            HStack {
                Text("HOME ferme toujours l'app (non modifiable)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Spacer()
                Button("Réinitialiser") { mappingStore.resetToDefaults() }
            }
            .padding()
        }
    }
}


struct TargetAppSettingsTab: View {
    @EnvironmentObject var targetAppStore: TargetAppStore
    @State private var runningApps: [NSRunningApplication] = []

    var body: some View {
        VStack(spacing: 0) {
            Text("App vers laquelle revenir après ouverture (le jeu en plein écran)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding([.horizontal, .top])

            List {
                ForEach(runningApps, id: \.processIdentifier) { app in
                    HStack {
                        if let icon = app.icon {
                            Image(nsImage: icon).resizable().frame(width: 20, height: 20)
                        }
                        Text(app.localizedName ?? app.bundleIdentifier ?? "?")
                        Spacer()
                        if app.bundleIdentifier == targetAppStore.bundleIdentifier {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        targetAppStore.bundleIdentifier = app.bundleIdentifier
                    }
                }
            }
            .listStyle(.inset)

            Button {
                runningApps = TargetAppStore.runningRegularApps()
            } label: {
                Label("Rafraîchir la liste", systemImage: "arrow.clockwise")
                    .frame(maxWidth: .infinity)
            }
            .padding()
        }
        .onAppear {
            runningApps = TargetAppStore.runningRegularApps()
        }
    }
}

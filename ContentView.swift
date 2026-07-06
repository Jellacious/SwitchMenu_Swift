import SwiftUI

struct ContentView: View {
    @EnvironmentObject var state: AppState

    private var isCompact: Bool { state.mode == .mouse }

    var body: some View {
        ZStack {
            Color(red: 0.02, green: 0.02, blue: 0.05)
                .ignoresSafeArea()

            if isCompact {
                MouseModeOverlay()
            } else {
                VStack(spacing: 0) {
                    header

                    Spacer(minLength: 0)

                    if state.shortcuts.isEmpty {
                        emptyState
                    } else {
                        shortcutRow
                    }

                    Spacer(minLength: 0)

                    footer
                }
            }
        }
        .frame(width: isCompact ? 210 : 640, height: isCompact ? 60 : 360)
        .clipShape(RoundedRectangle(cornerRadius: isCompact ? 14 : 0))
        .sheet(isPresented: $state.isShowingSettings) {
            SettingsView()
                .environmentObject(state)
        }
    }

    private var header: some View {
        HStack {
            Text("SWITCHMENU")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .tracking(2)
                .foregroundStyle(.white.opacity(0.6))
            Spacer()
            Button {
                state.isShowingSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 13))
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white.opacity(0.4))
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }

    private var shortcutRow: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 18) {
                    ForEach(Array(state.shortcuts.enumerated()), id: \.element.id) { index, item in
                        ShortcutTile(item: item, isSelected: index == state.selectedIndex)
                            .id(index)
                            .onTapGesture {
                                state.selectedIndex = index
                                state.runSelectedShortcut()
                            }
                    }
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 12)
            }
            .onChange(of: state.selectedIndex) { _, newValue in
                withAnimation(.easeOut(duration: 0.2)) {
                    proxy.scrollTo(newValue, anchor: .center)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 28))
                .foregroundStyle(.white.opacity(0.3))
            Text("Aucun raccourci — ajoute-en dans les réglages")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.4))
        }
    }

    private var footer: some View {
        HStack(spacing: 20) {
            hint(symbol: "a.circle.fill", label: buttonLabel(for: .select))
            hint(symbol: "b.circle.fill", label: buttonLabel(for: .back))
            hint(symbol: "cursorarrow", label: buttonLabel(for: .toggleMouseMode))
        }
        .font(.caption2)
        .foregroundStyle(.white.opacity(0.35))
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity)
    }

    private func hint(symbol: String, label: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: symbol)
            Text(label)
        }
    }

    private func buttonLabel(for action: ControllerAction) -> String {
        state.mappingStore.button(for: action)?.displayName ?? "—"
    }
}

struct ShortcutTile: View {
    let item: ShortcutItem
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 14)
                .fill(isSelected ? Color.white.opacity(0.15) : Color.white.opacity(0.06))
                .frame(width: 88, height: 88)
                .overlay(
                    Image(systemName: item.icon)
                        .font(.system(size: 30, weight: .medium))
                        .foregroundStyle(.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color.white, lineWidth: isSelected ? 2 : 0)
                )
                .scaleEffect(isSelected ? 1.1 : 1.0)
                .shadow(color: .white.opacity(isSelected ? 0.25 : 0), radius: 12)

            Text(item.name)
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(isSelected ? 0.9 : 0.5))
                .lineLimit(1)
        }
        .animation(.easeOut(duration: 0.15), value: isSelected)
    }
}

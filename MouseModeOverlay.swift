import SwiftUI

/// Petit badge compact affiché dans un coin de l'écran pendant le mode souris,
/// pour ne pas masquer le jeu/l'app en dessous.
struct MouseModeOverlay: View {
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "cursorarrow")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 1) {
                Text("Mode souris")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
                Text("Joystick = curseur")
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.45))
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
    }
}

import Foundation

/// Action logique déclenchée par la manette (indépendante du modèle de manette)
enum ControllerAction: String, CaseIterable, Codable, Identifiable {
    case navigateUp, navigateDown, navigateLeft, navigateRight
    case select        // Lance le raccourci (menu) / clic (souris)
    case back          // Ferme l'app (menu) / quitte le mode souris
    case toggleMouseMode

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .navigateUp: return "Naviguer haut"
        case .navigateDown: return "Naviguer bas"
        case .navigateLeft: return "Naviguer gauche"
        case .navigateRight: return "Naviguer droite"
        case .select: return "Sélectionner / Clic"
        case .back: return "Fermer / Quitter souris"
        case .toggleMouseMode: return "Activer mode souris"
        }
    }
}

/// Bouton physique générique, indépendant du fabricant de la manette
enum ButtonIdentifier: String, CaseIterable, Codable, Identifiable {
    case aButton, bButton, xButton, yButton
    case leftShoulder, rightShoulder
    case leftTrigger, rightTrigger
    case dpadUp, dpadDown, dpadLeft, dpadRight
    case leftThumbstickButton, rightThumbstickButton

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .aButton: return "A"
        case .bButton: return "B"
        case .xButton: return "X"
        case .yButton: return "Y"
        case .leftShoulder: return "L"
        case .rightShoulder: return "R"
        case .leftTrigger: return "ZL"
        case .rightTrigger: return "ZR"
        case .dpadUp: return "D-pad Haut"
        case .dpadDown: return "D-pad Bas"
        case .dpadLeft: return "D-pad Gauche"
        case .dpadRight: return "D-pad Droite"
        case .leftThumbstickButton: return "Clic Joystick Gauche"
        case .rightThumbstickButton: return "Clic Joystick Droit"
        }
    }
}

import AppKit
import CoreGraphics

final class MouseController {
    static let shared = MouseController()

    private var currentPosition: CGPoint
    private let sensitivity: CGFloat = 18.0
    private let deadzone: CGFloat = 0.08

    private init() {
        var pos = NSEvent.mouseLocation
        pos.y = (NSScreen.main?.frame.height ?? 0) - pos.y
        currentPosition = pos
    }

    func move(dx: CGFloat, dy: CGFloat) {
        if abs(dx) < deadzone && abs(dy) < deadzone { return }
        currentPosition.x += dx * sensitivity
        currentPosition.y -= dy * sensitivity

        if let event = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved,
                                mouseCursorPosition: currentPosition, mouseButton: .left) {
            event.post(tap: .cghidEventTap)
        }
    }

    func click() {
        guard let down = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown,
                                  mouseCursorPosition: currentPosition, mouseButton: .left),
              let up = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp,
                                mouseCursorPosition: currentPosition, mouseButton: .left) else { return }
        down.post(tap: .cghidEventTap)
        up.post(tap: .cghidEventTap)
    }
}

import AppKit

/// Measures the camera-notch cutout of a display.
///
/// On a notched Mac the menu bar is split into two usable strips. AppKit exposes them as
/// `auxiliaryTopLeftArea` / `auxiliaryTopRightArea`; everything between the two is the notch.
struct NotchMetrics {
    let displayName: String
    let notchWidth: CGFloat

    var hasNotch: Bool { notchWidth > 1 }

    static func measure(_ screen: NSScreen) -> NotchMetrics {
        var width: CGFloat = 0
        let left = screen.auxiliaryTopLeftArea?.width ?? 0
        let right = screen.auxiliaryTopRightArea?.width ?? 0
        if left > 0, right > 0 {
            width = max(0, screen.frame.width - left - right)
        }
        return NotchMetrics(displayName: screen.localizedName, notchWidth: width.rounded())
    }

    /// The notched display, if one is currently attached (lid open).
    static func notchedScreen() -> NSScreen? {
        NSScreen.screens.first { measure($0).hasNotch }
    }

    /// Metrics for the notched display, or a zero-width placeholder describing what we found.
    static func current() -> NotchMetrics {
        if let screen = notchedScreen() {
            return measure(screen)
        }
        let name = NSScreen.main?.localizedName ?? "Unknown display"
        return NotchMetrics(displayName: name, notchWidth: 0)
    }
}

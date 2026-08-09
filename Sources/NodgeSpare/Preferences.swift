import Foundation

/// Small typed wrapper around `UserDefaults`. Nothing here is secret or large,
/// so plain defaults are the right storage.
final class Preferences {
    static let shared = Preferences()

    private let defaults = UserDefaults.standard

    private enum Key {
        static let enabled = "spacerEnabled"
        static let autoWidth = "autoWidth"
        static let manualWidth = "manualWidth"
        static let showOutline = "showOutline"
        static let onlyNotchedDisplays = "onlyNotchedDisplays"
    }

    private init() {
        defaults.register(defaults: [
            Key.enabled: true,
            Key.autoWidth: true,
            Key.manualWidth: 180.0,
            // On by default so the first launch is visible and the item can be found to ⌘-drag.
            Key.showOutline: true,
            Key.onlyNotchedDisplays: true,
        ])
    }

    /// Master switch for the spacer item.
    var enabled: Bool {
        get { defaults.bool(forKey: Key.enabled) }
        set { defaults.set(newValue, forKey: Key.enabled) }
    }

    /// Track the measured notch width instead of using `manualWidth`.
    var autoWidth: Bool {
        get { defaults.bool(forKey: Key.autoWidth) }
        set { defaults.set(newValue, forKey: Key.autoWidth) }
    }

    var manualWidth: CGFloat {
        get { CGFloat(defaults.double(forKey: Key.manualWidth)).clamped(to: Self.widthRange) }
        set { defaults.set(Double(newValue.clamped(to: Self.widthRange)), forKey: Key.manualWidth) }
    }

    /// Draw a dashed outline so the otherwise invisible spacer can be found and ⌘-dragged.
    var showOutline: Bool {
        get { defaults.bool(forKey: Key.showOutline) }
        set { defaults.set(newValue, forKey: Key.showOutline) }
    }

    /// Collapse the spacer when no notched display is attached (clamshell / external-only).
    var onlyNotchedDisplays: Bool {
        get { defaults.bool(forKey: Key.onlyNotchedDisplays) }
        set { defaults.set(newValue, forKey: Key.onlyNotchedDisplays) }
    }

    static let widthRange: ClosedRange<CGFloat> = 0...400
}

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

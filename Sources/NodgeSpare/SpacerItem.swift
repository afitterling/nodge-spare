import AppKit

/// A blank status item whose only job is to occupy menu bar width.
///
/// macOS lays status items out right-to-left and lets the user ⌘-drag them. Park this one
/// immediately to the right of the notch and every item to its left is pushed clear of the
/// cutout instead of being swallowed by it.
final class SpacerItem {
    private let item: NSStatusItem
    private let outlineView = SpacerOutlineView()

    init() {
        item = NSStatusBar.system.statusItem(withLength: 0)
        // Persists the user's ⌘-dragged position across launches.
        item.autosaveName = "tech.sp33c.NodgeSpare.spacer"
        item.behavior = []

        if let button = item.button {
            button.image = nil
            button.title = ""
            button.imagePosition = .noImage
            outlineView.frame = button.bounds
            outlineView.autoresizingMask = [.width, .height]
            button.addSubview(outlineView)
        }
    }

    /// Applies width + visibility. A width of 0 hides the item entirely, because a zero-width
    /// status item is impossible to ⌘-drag back into place.
    func apply(width: CGFloat, showOutline: Bool) {
        let width = width.rounded()
        guard width >= 1 else {
            item.isVisible = false
            return
        }
        item.length = width
        outlineView.showsOutline = showOutline
        item.isVisible = true
    }

    func hide() {
        item.isVisible = false
    }
}

/// Draws the dashed "here I am" rectangle used while positioning the spacer.
private final class SpacerOutlineView: NSView {
    var showsOutline = false {
        didSet { if showsOutline != oldValue { needsDisplay = true } }
    }

    override var isFlipped: Bool { false }

    override func draw(_ dirtyRect: NSRect) {
        guard showsOutline, bounds.width > 4 else { return }
        let rect = bounds.insetBy(dx: 1.5, dy: 4.5)
        let path = NSBezierPath(roundedRect: rect, xRadius: 3, yRadius: 3)
        path.lineWidth = 1
        path.setLineDash([3, 2], count: 2, phase: 0)
        NSColor.tertiaryLabelColor.setStroke()
        path.stroke()
    }
}

import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var controlItem: NSStatusItem!
    private let spacer = SpacerItem()
    private let prefs = Preferences.shared
    private var metrics = NotchMetrics.current()

    func applicationDidFinishLaunching(_ notification: Notification) {
        controlItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        controlItem.autosaveName = "tech.sp33c.NodgeSpare.control"
        if let button = controlItem.button {
            button.image = Self.controlIcon()
            button.image?.isTemplate = true
            button.toolTip = "NodgeSpare — keeps menu bar icons out of the notch"
        }
        controlItem.menu = buildMenu()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screensChanged),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )

        refresh()
    }

    // MARK: - State

    @objc private func screensChanged() {
        metrics = NotchMetrics.current()
        refresh()
    }

    /// Single place that turns preferences + measurements into the spacer's actual width.
    private func refresh() {
        guard prefs.enabled else {
            spacer.hide()
            controlItem.button?.appearsDisabled = true
            controlItem.menu = buildMenu()
            return
        }
        controlItem.button?.appearsDisabled = false

        if prefs.onlyNotchedDisplays && !metrics.hasNotch {
            spacer.hide()
        } else {
            spacer.apply(width: effectiveWidth(), showOutline: prefs.showOutline)
        }
        controlItem.menu = buildMenu()
    }

    private func effectiveWidth() -> CGFloat {
        if prefs.autoWidth {
            // Fall back to the stored manual width on a display we can't measure.
            return metrics.hasNotch ? metrics.notchWidth : prefs.manualWidth
        }
        return prefs.manualWidth
    }

    // MARK: - Menu

    private func buildMenu() -> NSMenu {
        let menu = NSMenu()
        menu.autoenablesItems = false

        let status: String
        if metrics.hasNotch {
            status = "Notch: \(Int(metrics.notchWidth)) pt — \(metrics.displayName)"
        } else {
            status = "No notch detected — \(metrics.displayName)"
        }
        menu.addItem(info(status))

        let reserved: String
        if !prefs.enabled {
            reserved = "Spacer off"
        } else if prefs.onlyNotchedDisplays && !metrics.hasNotch {
            reserved = "Spacer collapsed (no notched display)"
        } else {
            reserved = "Reserving \(Int(effectiveWidth())) pt"
        }
        menu.addItem(info(reserved))

        menu.addItem(.separator())

        menu.addItem(toggle("Reserve Notch Space", #selector(toggleEnabled), on: prefs.enabled))
        menu.addItem(toggle("Match Notch Width Automatically", #selector(toggleAutoWidth),
                            on: prefs.autoWidth, enabled: prefs.enabled))

        let sliderItem = NSMenuItem()
        let sliderView = WidthSliderView(width: effectiveWidth(), enabled: prefs.enabled && !prefs.autoWidth)
        sliderView.onChange = { [weak self] value in
            self?.prefs.manualWidth = value
            self?.refresh()
        }
        sliderItem.view = sliderView
        menu.addItem(sliderItem)

        menu.addItem(.separator())

        menu.addItem(toggle("Show Spacer Outline", #selector(toggleOutline),
                            on: prefs.showOutline, enabled: prefs.enabled))
        menu.addItem(toggle("Only On Notched Displays", #selector(toggleOnlyNotched),
                            on: prefs.onlyNotchedDisplays, enabled: prefs.enabled))

        let login = toggle("Launch at Login", #selector(toggleLoginItem),
                           on: LoginItem.isAvailable && LoginItem.isEnabled,
                           enabled: LoginItem.isAvailable)
        if !LoginItem.isAvailable {
            login.toolTip = "Available once NodgeSpare.app is installed (e.g. in /Applications)."
        }
        menu.addItem(login)

        menu.addItem(.separator())
        menu.addItem(action("How to Position the Spacer…", #selector(showHelp)))
        menu.addItem(action("Quit NodgeSpare", #selector(quit), key: "q"))
        return menu
    }

    private func info(_ title: String) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        item.isEnabled = false
        return item
    }

    private func toggle(_ title: String, _ selector: Selector, on: Bool, enabled: Bool = true) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: selector, keyEquivalent: "")
        item.target = self
        item.state = on ? .on : .off
        item.isEnabled = enabled
        return item
    }

    private func action(_ title: String, _ selector: Selector, key: String = "") -> NSMenuItem {
        let item = NSMenuItem(title: title, action: selector, keyEquivalent: key)
        item.target = self
        return item
    }

    // MARK: - Actions

    @objc private func toggleEnabled() {
        prefs.enabled.toggle()
        refresh()
    }

    @objc private func toggleAutoWidth() {
        prefs.autoWidth.toggle()
        // Leaving auto mode: seed the manual value with what's on screen right now.
        if !prefs.autoWidth, metrics.hasNotch {
            prefs.manualWidth = metrics.notchWidth
        }
        refresh()
    }

    @objc private func toggleOutline() {
        prefs.showOutline.toggle()
        refresh()
    }

    @objc private func toggleOnlyNotched() {
        prefs.onlyNotchedDisplays.toggle()
        refresh()
    }

    @objc private func toggleLoginItem() {
        do {
            try LoginItem.set(!LoginItem.isEnabled)
        } catch {
            let alert = NSAlert()
            alert.messageText = "Couldn’t change the login item"
            alert.informativeText = error.localizedDescription
            alert.alertStyle = .warning
            alert.runModal()
        }
        refresh()
    }

    @objc private func showHelp() {
        let alert = NSAlert()
        alert.messageText = "Positioning the spacer"
        alert.informativeText = """
        macOS decides where status items sit, but you can move them yourself:

        1. Turn on “Show Spacer Outline” so you can see the blank item.
        2. Hold ⌘ and drag the outlined item until it sits just right of the notch.
        3. Turn the outline back off — the position is remembered.

        Icons to the left of the spacer are now pushed clear of the notch \
        instead of disappearing behind it.
        """
        alert.addButton(withTitle: "Got it")
        NSApp.activate(ignoringOtherApps: true)
        alert.runModal()
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }

    private static func controlIcon() -> NSImage? {
        let name = "rectangle.topthird.inset.filled"
        if let image = NSImage(systemSymbolName: name, accessibilityDescription: "NodgeSpare") {
            return image
        }
        return NSImage(systemSymbolName: "menubar.rectangle", accessibilityDescription: "NodgeSpare")
    }
}

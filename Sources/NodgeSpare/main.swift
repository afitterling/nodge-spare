import AppKit

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
// Menu-bar-only app: no Dock tile, no main menu. Info.plist sets LSUIElement too,
// but this keeps the raw (unbundled) binary behaving the same way.
app.setActivationPolicy(.accessory)
app.run()

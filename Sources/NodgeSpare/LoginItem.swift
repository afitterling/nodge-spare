import AppKit
import ServiceManagement

/// Launch-at-login toggle backed by `SMAppService`.
///
/// `SMAppService.mainApp` only works for a real, code-signed `.app` bundle — running the bare
/// SwiftPM binary will report `.notFound` and registration will throw. That's surfaced to the
/// user rather than swallowed.
enum LoginItem {
    static var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    static var isAvailable: Bool {
        Bundle.main.bundleIdentifier != nil && Bundle.main.bundlePath.hasSuffix(".app")
    }

    static func set(_ enabled: Bool) throws {
        if enabled {
            try SMAppService.mainApp.register()
        } else {
            try SMAppService.mainApp.unregister()
        }
    }
}

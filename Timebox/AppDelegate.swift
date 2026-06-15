import AppKit
import ServiceManagement

class AppDelegate: NSObject, NSApplicationDelegate {
    private var menuBarController: MenuBarController!

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        menuBarController = MenuBarController()
        do {
            try SMAppService.mainApp.register()
        } catch {
            print("Login item registration failed: \(error)")
        }
    }
}

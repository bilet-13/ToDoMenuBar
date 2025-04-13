//
//  ToDoBarApp.swift
//  ToDoBar
//
//  Created by william on 2025/4/13.
//

import SwiftUI

@main
struct TodoMenuBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView() // optional, no default settings UI
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.image = NSImage(named: NSImage.statusAvailableName)
        statusItem?.button?.image?.isTemplate = true
        statusItem?.button?.setAccessibilityLabel("ToDoBar Icon")
        statusItem?.button?.action = #selector(togglePopover)

        popover.contentViewController = NSHostingController(rootView: TodoView())
        popover.behavior = .transient
    }

    let popover = NSPopover()

    @objc func togglePopover() {
        if popover.isShown {
            popover.performClose(nil)
        } else if let button = statusItem?.button {
           DispatchQueue.main.async {
               self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
           }
        }
    }
}

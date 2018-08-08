//
//  Notifier.swift
//  Caffeinator
//
//  Created by aaplmath on 9/24/17.
//  Copyright © 2017 aaplmath. All rights reserved.
//

import Cocoa

extension NSAlert {
    open func runModalInFront() -> NSApplication.ModalResponse {
        NSApplication.shared.activate(ignoringOtherApps: true)
        return self.runModal()
    }
}

/// Convenience class for grouping together various functions that trigger `NSAlert`s
class Notifier {
    
    /// Show a two-button text input dialog to the user and returns the String result if the user presses OK. Not to be confused with showValueDialog()
    class func showInputDialog(withWindowTitle windowTitle: String, title: String, text: String) -> String? {
        // FIXME: Instruments claims this causes a 32-byte (really?) memory leak. I'm not sure I believe it.
        let alert = NSAlert()
        alert.window.title = windowTitle
        alert.messageText = title
        alert.informativeText = text
        alert.addButton(withTitle: txt("N.ok-text"))
        alert.addButton(withTitle: txt("N.cancel-text"))
        alert.alertStyle = .informational
        alert.accessoryView = NSTextField(frame: NSMakeRect(0, 0, 200, 24))
        let button = alert.runModalInFront()
        if button == .alertFirstButtonReturn {
            return (alert.accessoryView as! NSTextField).stringValue
        }
        return nil
    }
    
    /// Displays a value input dialog for use in addValue(). Not to be confused with showInputDialog()
    class func showValueDialog(forParam param: String) -> String? {
        return Notifier.showInputDialog(withWindowTitle: txt("N.value-dialog-window-title"), title: txt("N.value-dialog-title"), text: String(format: txt("N.value-dialog-msg"), param))
    }
    
    /// Shows an error message with the specified text
    class func showErrorMessage(withTitle title: String, text: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.window.title = txt("N.error-message-title")
            alert.messageText = title
            alert.informativeText = text
            if let img = NSApp.applicationIconImage.copy() as? NSImage {
                img.lockFocus()
                let color = NSColor.red
                color.set()
                NSMakeRect(0, 0, img.size.width, img.size.height).fill(using: .sourceAtop)
                img.unlockFocus()
                alert.icon = img
            }
            alert.alertStyle = .warning
            _ = alert.runModalInFront()
        }
    }
    
    /// Shows a dialog with OK and Cancel buttons. Returns true if OK is selected, or false otherwise
    class func showConfirmationDialog(withTitle title: String, text: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = text
        alert.alertStyle = .informational
        alert.addButton(withTitle: txt("N.ok-text"))
        alert.addButton(withTitle: txt("N.cancel-text"))
        let res = alert.runModalInFront()
        return res == .alertFirstButtonReturn
    }
    
    // Don't allow Notifier to be initialized
    private init() {}
}

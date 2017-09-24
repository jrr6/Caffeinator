//
//  Notifier.swift
//  Caffeinator
//
//  Created by aaplmath on 9/24/17.
//  Copyright © 2017 aaplmath. All rights reserved.
//

import Cocoa

class Notifier {
    
    // Show a two-button text input dialog to the user and returns the String result if the user presses OK. Not to be confused with showValueDialog()
    class func showInputDialog(withWindowTitle windowTitle: String, title: String, text: String) -> String? {
        // FIXME: Instruments claims this causes a 32-byte (really?) memory leak. I'm not sure I believe it.
        let alert = NSAlert()
        alert.window.title = windowTitle
        alert.messageText = title
        alert.informativeText = text
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        alert.alertStyle = .informational
        alert.accessoryView = NSTextField(frame: NSMakeRect(0, 0, 200, 24))
        let button = alert.runModalInFront()
        if button == .alertFirstButtonReturn {
            return (alert.accessoryView as! NSTextField).stringValue
        }
        return nil
    }
    
    // Displays a value input dialog for use in addValue(). Not to be confused with showInputDialog()
    class func showValueDialog(forParam param: String) -> String? {
        return Notifier.showInputDialog(withWindowTitle: "Value Input", title: "Please Enter a Value", text: "Please enter the value for the \(param) parameter below:")
    }
    
    // Shows an error message with the specified text
    class func showErrorMessage(withTitle title: String, text: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.window.title = "Error"
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
}

//
//  ShortcutsViewController.swift
//  Caffeinator
//
//  Created by aaplmath on 12/30/19.
//  Copyright © 2019 aaplmath. All rights reserved.
//

import Cocoa
import HotKey

class ShortcutsViewController: NSViewController {
    
    @IBOutlet weak var startButton: NSButton!
    @IBOutlet weak var procButton: NSButton!
    @IBOutlet weak var manualButton: NSButton!
        
    var active: String? = nil // which button is the active listener
    var listening = false // are we listening for a keyboard shortcut input?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    /// Handles the pressing of a shortcut set button. Will disable any other shortcut buttons if they are currently active and sets up listening variables for when the keypress occurs.
    @IBAction func setShortcut(sender: NSButton) {
        // The sender's ID should be of the form `shortcutMENUID`, where MENUID is the ID of the menu item to which the shortcut corresponds
        guard let rawID = sender.identifier?.rawValue else {
            // TODO: handle error (which should not occur)
            return
        }
        let menuID = String(rawID[rawID.index(rawID.startIndex, offsetBy: 8)...])
        
        if let curActive = active, curActive == menuID {
            // We're in the middle of this button's own session—stop it
            active = nil
            listening = false
            return
        }
        
        if active != nil {
            // We're in the middle of another button's session—we can keep listening, just change who's active and reset that button's appearance
            deselectButtonForActiveID()
        }
        
        active = menuID.lowercased()
        listening = true
    }
    
    func updateHotkeyFor(event: NSEvent) {
        listening = false

        guard let active = active else {
            // TODO: handle error
            return
        }
        deselectButtonForActiveID()
        self.active = nil
        
        let relevantModifiers: [NSEvent.ModifierFlags] = [.function, .shift, .control, .option, .command]
        
        var hotkeyModifiers: NSEvent.ModifierFlags = []
        
        for modifier in relevantModifiers {
            if event.modifierFlags.contains(modifier) {
                hotkeyModifiers.update(with: modifier)
            }
        }
        
        guard hotkeyModifiers.contains(.function)
            || hotkeyModifiers.contains(.control)
            || hotkeyModifiers.contains(.option)
            || hotkeyModifiers.contains(.command) else {
            // TODO: alert that the entered combination is invalid
            return
        }
        
        guard let character = Key(carbonKeyCode: UInt32(event.keyCode)) else {
            // TODO: handle error
            return
        }
        HotKeyManager.shared.setKeyEquivForMenu(withID: active, key: character, modifiers: hotkeyModifiers)
    }
    
    private func deselectButtonForActiveID() {
        if let curActive = active {
            switch curActive {
            case "start":
                startButton.state = .off
            case "proc":
                procButton.state = .off
            case "manual":
                manualButton.state = .off
            default:
                break
            }
        }
    }
}

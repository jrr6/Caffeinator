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
    
    @IBOutlet weak var startClearButton: NSButton!
    @IBOutlet weak var procClearButton: NSButton!
    @IBOutlet weak var manualClearButton: NSButton!
    
    
    override var acceptsFirstResponder: Bool { return true }
    override func becomeFirstResponder() -> Bool { return true }
    override func resignFirstResponder() -> Bool { return true }
    
    var active: String? = nil // which button is the active listener
    var listening = false // are we listening for a keyboard shortcut input?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HotKeyManager.shared.actions.forEach { action in
            if let key = action.key {
                updateTitle(forButtonID: action.id, withKey: key, modifiers: action.modifiers)
                setClearButton(for: action.id, enabled: true)
            } else {
                resetTitle(forButtonID: action.id)
            }
        }
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { (aEvent) -> NSEvent? in
            let handled = self.onKeyDown(with: aEvent)
            return handled ? nil : aEvent
        }
    }
    
    /// Handles keydown events. Returns `true` if event was handled and `false` if it should be propagated.
    func onKeyDown(with event: NSEvent) -> Bool {
        if listening {
            updateHotkey(with: event)
            return true
        }
        return false
    }
    
    /// Handles the pressing of a shortcut set button. Will disable any other shortcut buttons if they are currently active and sets up listening variables for when the keypress occurs.
    @IBAction func setShortcut(sender: NSButton) {
        // The sender's ID should be of the form `shortcutMENUID`, where MENUID is the ID of the menu item to which the shortcut corresponds
        guard let rawID = sender.identifier?.rawValue else {
            // TODO: handle error (which should not occur)
            return
        }
        let menuID = String(rawID[rawID.index(rawID.startIndex, offsetBy: 8)...]).lowercased()
        
        if let curActive = active, curActive == menuID {
            // We're in the middle of this button's own session—stop it
            active = nil
            listening = false
            setClearButton(for: curActive, enabled: false)
            return
        }
        
        if active != nil {
            // We're in the middle of another button's session—we can keep listening, just change who's active and reset that button's appearance
            deselectButtonForActiveID()
        }
        
        active = menuID
        listening = true
    }
    
    @IBAction func clearShortcut(sender: NSButton) {
        // The sender's ID should be of the form `shortcutClearMENUID`, where MENUID is the ID of the menu item to which the shortcut corresponds
        guard let rawID = sender.identifier?.rawValue else {
                   // TODO: handle error (which should not occur)
                   return
               }
        let menuID = String(rawID[rawID.index(rawID.startIndex, offsetBy: 13)...]).lowercased()
        HotKeyManager.shared.clearKeyEquivForMenu(withID: menuID)
        resetTitle(forButtonID: menuID)
        sender.isEnabled = false
    }
    
    /**
     Updates the active hotkey based on input from a provided event.
     - Parameter event: an event containing a keypress that will become the new hotkey.
     */
    func updateHotkey(with event: NSEvent) {
        listening = false

        guard let curActive = active else {
            // TODO: handle error
            return
        }
        deselectButtonForActiveID()
        active = nil
        
        let relevantModifiers: [NSEvent.ModifierFlags] = [.shift, .control, .option, .command]
        
        var hotkeyModifiers: NSEvent.ModifierFlags = []
        
        for modifier in relevantModifiers {
            if event.modifierFlags.contains(modifier) {
                hotkeyModifiers.update(with: modifier)
            }
        }
        
        guard let character = Key(carbonKeyCode: UInt32(event.keyCode)) else {
            // TODO: handle error
            return
        }
        
        guard FunctionMap.map[character] != nil
            || hotkeyModifiers.contains(.control)
            || hotkeyModifiers.contains(.option)
            || hotkeyModifiers.contains(.command) else {
            // TODO: alert that the entered combination is invalid
            return
        }
        
        HotKeyManager.shared.setKeyEquivForMenu(withID: curActive, key: character, modifiers: hotkeyModifiers)
        updateTitle(forButtonID: curActive, withKey: character, modifiers: hotkeyModifiers)
        setClearButton(for: curActive, enabled: true)
    }
    
    /// Deselects the button that produced the current `active` ID. Used when the user switches buttons without unclicking the first one.
    private func deselectButtonForActiveID() {
        if let curActive = active {
            button(for: curActive)?.state = .off
            setClearButton(for: curActive, enabled: false)
        }
    }
    
    /// Gets the button corresponding to the given menu ID.
    private func button(for id: String) -> NSButton? {
        switch id {
        case "start":
            return startButton
        case "proc":
            return procButton
        case "manual":
            return manualButton
        default:
            return nil
        }
    }
    
    private func resetTitle(forButtonID id: String) {
        button(for: id)?.title = "Set" // TODO: Localize
    }
    
    private func updateTitle(forButtonID id: String, withKey key: Key, modifiers: NSEvent.ModifierFlags?) {
        button(for: id)?.title = stringForCombo(key: key, modifiers: modifiers ?? [])
    }
    
    private func setClearButton(for id: String, enabled: Bool) {
        switch id {
        case "start":
            startClearButton.isEnabled = enabled
        case "proc":
            procClearButton.isEnabled = enabled
        case "manual":
            manualClearButton.isEnabled = enabled
        default:
            break
        }
    }
    
    private func stringForCombo(key: Key, modifiers: NSEvent.ModifierFlags) -> String {
        var str = ""
        if modifiers.contains(.control) {
            str += "⌃"
        }
        if modifiers.contains(.option) {
            str += "⌥"
        }
        if modifiers.contains(.shift) {
            str += "⇧"
        }
        if modifiers.contains(.command) {
            str += "⌘"
        }
        str += key.description.uppercased()
        return str
    }
}

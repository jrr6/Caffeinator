//
//  HotKeyManager.swift
//  Caffeinator
//
//  Created by aaplmath on 12/30/19.
//  Copyright © 2019 aaplmath. All rights reserved.
//

import CaffeineKit
import Cocoa
import HotKey

class HotKeyManager: NSObject {
    
    struct MenuAction {
        let id: String
        let item: NSMenuItem
        let action: () -> Void
        var hotKey: HotKey?
        var key: Key?
        var modifiers: NSEvent.ModifierFlags?
        
        init(item: NSMenuItem, action: @escaping () -> Void) {
            self.item = item
            self.action = action
            guard let id = item.identifier?.rawValue else {
                // TODO: handle error (which should never happen)
                self.id = "ERROR"
                return
            }
            self.id = id
            
            self.hotKey = nil
            self.key = nil
            self.modifiers = nil
        }
    }
    
    static let shared = HotKeyManager()
    
    private override init() {}
    
    var toggleHotKey: HotKey?
    
    var actions: [MenuAction] = []
    
    func registerMenuItem(_ item: NSMenuItem, withEquivalentAction action: @escaping () -> Void) {
        let action = MenuAction(item: item, action: action)
        actions.append(action)
    }
    
    func setKeyEquivForMenu(withID id: String, key: Key, modifiers: NSEvent.ModifierFlags) {
        guard let idx = actions.firstIndex(where: { $0.id == id }) else {
            // TODO: report error—illegal ID (show a popup)
            return
        }
        actions[idx].key = key
        actions[idx].modifiers = modifiers
        reassignHotKey(at: idx)
    }

    private func unassignHotKeys() {
        for (idx, _) in actions.enumerated() {
            actions[idx].hotKey = nil
        }
    }
    
    private func reassignHotKey(at index: Array<MenuAction>.Index) {
        guard let key = actions[index].key, var modifiers = actions[index].modifiers else {
            return
        }
        // Global hotkey
        actions[index].hotKey = HotKey(key: key, modifiers: modifiers)
        actions[index].hotKey!.keyDownHandler = actions[index].action
        
        // In-menu hotkey
        if let alt = FunctionMap.map[key] {
            // Even though using the description method for function keys works, it doesn't produce the right shortcut in the menu, so use this workaround instead
            actions[index].item.keyEquivalent = String(Character(UnicodeScalar(alt)!))
            modifiers.remove(.function)
        } else {
            actions[index].item.keyEquivalent = key.description.lowercased()
        }
        actions[index].item.keyEquivalentModifierMask = modifiers
    }
    
    private func reassignHotKeys() {
        for (idx, _) in actions.enumerated() {
            reassignHotKey(at: idx)
        }
    }
}

// HotKeyManager must be the delegate of the main menu so it can fall back on local hotkeys when the menu opens
extension HotKeyManager: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        unassignHotKeys()
    }
    
    func menuDidClose(_ menu: NSMenu) {
        reassignHotKeys()
    }
}

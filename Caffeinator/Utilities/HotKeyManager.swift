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
    let caffeination: Caffeination!
    var startMenu: NSMenuItem!
    
    var toggleHotKey: HotKey?
    
    init(caffeination: Caffeination) {
        self.caffeination = caffeination
        super.init()
        reassignHotKeys()
        startMenu = (NSApp.delegate as! AppDelegate).startMenu // TODO: this is hacky and goes against principles of access control
        
        startMenu.keyEquivalent = "e"
        startMenu.keyEquivalentModifierMask = [.command, .option]
    }
    
    func unassignHotKeys() {
        toggleHotKey = nil
    }
    
    func reassignHotKeys() {
        toggleHotKey = HotKey(key: .e, modifiers: [.command, .option])
        toggleHotKey?.keyDownHandler = {
            self.caffeination.quickToggle()
        }
    }
}

extension HotKeyManager: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        unassignHotKeys()
    }
    
    func menuDidClose(_ menu: NSMenu) {
        reassignHotKeys()
    }
}

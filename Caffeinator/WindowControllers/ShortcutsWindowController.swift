//
//  ShortcutsWindowController.swift
//  Caffeinator
//
//  Created by aaplmath on 1/2/20.
//  Copyright © 2020 aaplmath. All rights reserved.
//

import Cocoa

class ShortcutsWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    override func keyDown(with event: NSEvent) {
        super.keyDown(with: event)
        if let vc = self.contentViewController as? ShortcutsViewController {
            if vc.listening {
                vc.updateHotkeyFor(event: event)
            }
        }
    }

}

//
//  ScriptingStopCaffeination.swift
//  Caffeinator
//
//  Created by aaplmath on 7/24/20.
//  Copyright © 2020 aaplmath. All rights reserved.
//

import Cocoa

/// A ScriptCommand class that handles the "stop caffeination" command.
class ScriptingStopCaffeination: NSScriptCommand {
    override func performDefaultImplementation() -> Any? {
        let caf = (NSApplication.shared.delegate as! AppDelegate).caffeination
        if let caf = caf, caf.isActive {
            caf.stop()
            return true
        }
        return false
    }
}

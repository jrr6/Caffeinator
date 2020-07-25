//
//  ScriptingStartCaffeination.swift
//  Caffeinator
//
//  Created by aaplmath on 7/24/20.
//  Copyright © 2020 aaplmath. All rights reserved.
//

import Cocoa

/// A ScriptCommand class that handles the "start caffeination" command.
class ScriptingStartCaffeination: NSScriptCommand {
    override func performDefaultImplementation() -> Any? {
        let caf = (NSApplication.shared.delegate as! AppDelegate).caffeination
        guard let caffeination = caf else {
            return false
        }
        if caffeination.isActive {
            return false
        }

        guard let args = self.evaluatedArguments else {
            return false
        }
        
        if let opts = args["Options"] as? [String] {
            // If the user has supplied custom options, disregard all defaults
            caffeination.opts = []
            for opt in opts {
                switch opt {
                case "display":
                    caffeination.opts.append(.display)
                case "idle":
                    caffeination.opts.append(.idle)
                case "disk":
                    caffeination.opts.append(.disk)
                case "system":
                    caffeination.opts.append(.system)
                case "user":
                    caffeination.opts.append(.user)
                default:
                    break
                }
            }
        }
        if let duration = args["Duration"] as? Double {
            caffeination.opts.append(.timed(duration))
        }
        if let pidStr = args["PID"] as? String, let pid = Int32(pidStr) {
            caffeination.opts.append(.process(pid))
        }
        
        do {
            try caffeination.start()
            (NSApp.delegate as! AppDelegate).updateIconForCafState(active: true)
            return true
        } catch {
            return false
        }
    }
}

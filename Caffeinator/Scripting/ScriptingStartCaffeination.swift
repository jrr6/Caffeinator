//
//  ScriptingStartCaffeination.swift
//  Caffeinator
//
//  Created by aaplmath on 7/24/20.
//  Copyright © 2020 aaplmath. All rights reserved.
//

import CaffeineKit
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
        
        // Collect opts in a temporary opt array so that if we fail as we're parsing, we don't ruin the default opts of the Caffeination instance
        var tempOpts: [Caffeination.Opt]! = nil
        if let opts = args["Options"] as? [String] {
            tempOpts = []
            // If the user has supplied custom options, disregard all defaults
            for opt in opts {
                switch opt {
                case "display":
                    tempOpts.append(.display)
                case "idle":
                    tempOpts.append(.idle)
                case "disk":
                    tempOpts.append(.disk)
                case "system":
                    tempOpts.append(.system)
                case "user":
                    tempOpts.append(.user)
                default:
                    // Illegal option—fail
                    return false
                }
            }
        }
        if let customOpts = tempOpts {
            caffeination.opts = customOpts
        }
        
        if let duration = args["Duration"] as? Double {
            caffeination.opts.append(.timed(duration))
        }
        if let pid = args["PID"] as? Int32 {
            caffeination.opts.append(.process(pid))
        }
        
        return caffeination.handledStartForAutomation()
    }
}

//
//  CaffeinationAdditions.swift
//  Caffeinator
//
//  Created by aaplmath on 6/18/19.
//  Copyright © 2019 aaplmath. All rights reserved.
//

import CaffeineKit
import Cocoa

extension Caffeination {
    /// Starts the Caffeination, catches and handles (with an alert dialog) any errors that occur, and—if the Caffeination starts successfully—sets the menu bar icon to its active state
    func handledStart() {
        do {
            try self.start()
            (NSApp.delegate as! AppDelegate).updateIconForCafState(active: true)
        } catch let err {
            switch err {
            case let err as CaffeinationError:
                if err == CaffeinationError.caffeinateNotFound {
                    Notifier.showErrorMessage(withTitle: txt("AD.caffeinate-missing-dialog-title"), text: txt("AD.caffeinate-missing-dialog-msg"))
                }
            // ignore "already active" errors
            default:
                Notifier.showErrorMessage(withTitle: txt("AD.caffeinate-failure-title"), text: String(format: txt("AD.caffeinate-failure-msg"), err.localizedDescription))
            }
            self.opts = Caffeination.Opt.userDefaults
        }
    }
    
    /// Starts the Caffeination with the provided options, catches and handles (with an alert dialog) any errors that occur, and—if the Caffeination starts successfully—sets the menu bar icon to its active state
    func handledStart(withOpts opts: [Opt]) {
        self.opts = opts
        self.handledStart()
    }
    
    /// Starts the Caffeination if it is not active or stops it if its, catching and handling (with an alert dialog) any errors that occur and appropriately updating the menu bar icon upon start (use `terminationHandler` to deal with the stop update)
    func quickToggle() {
        if self.isActive {
            self.stop()
        } else {
            self.handledStart()
        }
    }
    
    /**
     Starts the Caffeination for use in automation (e.g., scripting)—specifically, catches errors and converts success/fail to a boolean return state instead.
     
     - Returns: `true` if successful, `false` if not.
     */
    func handledStartForAutomation() -> Bool {
        do {
            try self.start()
            (NSApp.delegate as! AppDelegate).updateIconForCafState(active: true)
            return true
        } catch {
            return false
        }
    }
}

extension Caffeination.Opt {
    static var userDefaults: [Caffeination.Opt] {
        get {
            return UserDefaults.standard.bool(forKey: "CaffeinateDisplay") ? Caffeination.Opt.defaults : [Caffeination.Opt.idle]
        }
    }
}

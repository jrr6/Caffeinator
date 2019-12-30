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
    
    func handledStart(withOpts opts: [Opt]) {
        self.opts = opts
        self.handledStart()
    }
    
    func quickToggle() {
        if self.isActive {
            self.stop()
        } else {
            self.handledStart()
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

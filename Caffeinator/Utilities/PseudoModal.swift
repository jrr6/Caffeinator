//
//  PseudoModal.swift
//  Caffeinator
//
//  Created by aaplmath on 6/17/19.
//  Copyright © 2019 aaplmath. All rights reserved.
//

import Cocoa

/// Represents a view controller that functions modally but is encapsulated in a standard window
protocol PseudoModal {
    var properties: [String: Any] { get set }
    var onConfirm: (Any?) -> Void { get set }
    var onCancel: () -> Void { get set }
}

// Adds shorthand ways of instantiating windows and pseudo-modals
extension NSStoryboard {
    func instantiateAndShowWindow(withIDString idString: String) {
        // TODO: This is hacky and relies on the ID of the window matching the storyboard ID of its view controller. Investigate better ways to go about preventing duplicate windows. (Also, since update windows do their own thing, this doesn't prevent duplicate update windows, although that's less of an issue.)
        if !NSApp.windows.contains { $0.identifier?.rawValue == idString } {
            (self.instantiateController(withIdentifier: idString) as? NSWindowController)?.showWindow(self)
        }
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func instantiateAndShowPseudoModal(withIDString idString: String, properties: [String: Any], onConfirm: ((Any) -> Void)?, onCancel: (() -> Void)?) {
        guard (!NSApp.windows.contains { $0.identifier?.rawValue == idString }) else {
            return
        }
        let windowCtrl = self.instantiateController(withIdentifier: idString) as? NSWindowController
        var vc = windowCtrl?.contentViewController as? PseudoModal
        vc?.onConfirm = onConfirm ?? { _ in }
        vc?.onCancel = onCancel ?? {}
        vc?.properties = properties
        windowCtrl?.showWindow(self)
        NSApp.activate(ignoringOtherApps: true)
    }
}

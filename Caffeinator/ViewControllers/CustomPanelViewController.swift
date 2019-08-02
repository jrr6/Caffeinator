//
//  ArgumentPanelViewController.swift
//  Caffeinator
//
//  Created by aaplmath on 8/9/18.
//  Copyright © 2018 aaplmath. All rights reserved.
//

import Cocoa
import CaffeineKit

class CustomPanelViewController: NSViewController, PseudoModal {
    @IBOutlet weak var tButton: NSButton!
    @IBOutlet weak var tLabel: NSTextField!
    @IBOutlet weak var wButton: NSButton!
    @IBOutlet weak var wLabel: NSTextField!
    @IBOutlet weak var timedCheckbox: NSButton!
    @IBOutlet weak var processCheckbox: NSButton!
    
    // PseudoModal fields
    var properties: [String : Any] = [:]
    var onConfirm: (Any?) -> Void = { _ in }
    var onCancel: () -> Void = {}
    
    var args: [String: String] = [:]
    
    /// Responds to an argument being (un)checked by adding it to/removing it from the args array, and if it allows a manually-input value, enables/disables the corresponding input button
    @IBAction func optionChecked(_ sender: NSButton) {
        let identifier = sender.identifier?.rawValue ?? ""
        let argumentName = "-\(identifier)"
        let state = sender.state == .on
        if state {
            args[argumentName] = ""
        } else {
            if let loc = args.index(forKey: argumentName) {
                args.remove(at: loc)
            }
            if identifier == "t" {
                tLabel.stringValue = txt("CPVC.no-argument-label")
            } else if identifier == "w" {
                wLabel.stringValue = txt("CPVC.no-argument-label")
            }
        }
        if identifier == "t" {
            tButton.isEnabled = state
        } else if identifier == "w" {
            wButton.isEnabled = state
        }
    }
    
    /// Shows the value input dialog and uses its return value for the corresponding argument, as determined by the sender's tag. These values are then assigned to the corresponding dictionary item
    @IBAction func addValue(_ sender: NSButton) {
        let params = sender.tag == 0 ? (flag: "-t", label: tLabel, name: timedCheckbox.title) : (flag: "-w", label: wLabel, name: processCheckbox.title)
        if let value = Notifier.showValueDialog(forParam: params.name) {
            params.label?.stringValue = value
            args[params.flag] = value
        }
    }
    
    /// Converts the dictionary of arguments into an array of parameters, then passes that array to generateCaffeine() in dev mode.
    @IBAction func confirmOptions(_ sender: NSButton) {
        onConfirm(args)
        self.view.window?.close()
    }
    
    /// Closes the argument panel
    @IBAction func cancelClicked(_ sender: NSButton) {
        onCancel()
        self.view.window?.close()
    }
}

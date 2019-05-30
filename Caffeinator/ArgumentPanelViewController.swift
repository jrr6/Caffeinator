//
//  ArgumentPanelViewController.swift
//  Caffeinator
//
//  Created by aaplmath on 8/9/18.
//  Copyright © 2018 aaplmath. All rights reserved.
//

import Cocoa
import CaffeineKit

class ArgumentPanelViewController: NSViewController {
    @IBOutlet weak var tButton: NSButton!
    @IBOutlet weak var tLabel: NSTextField!
    @IBOutlet weak var wButton: NSButton!
    @IBOutlet weak var wLabel: NSTextField!
    @IBOutlet weak var timedCheckbox: NSButton!
    @IBOutlet weak var processCheckbox: NSButton!
    
    var args: [String: String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    /// Responds to an argument being (un)checked by adding it to/removing it from the args array, and if it allows a manually-input value, enables/disables the corresponding input button
    @IBAction func argumentChecked(_ sender: NSButton) {
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
                tLabel.stringValue = txt("AD.no-argument-label")
            } else if identifier == "w" {
                wLabel.stringValue = txt("AD.no-argument-label")
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
    @IBAction func confirmArguments(_ sender: NSButton) {
        var params: [Caffeination.Opt] = []
        for (name, arg) in args {
            let opt: Caffeination.Opt?
            if arg != "" {
                opt = Caffeination.Opt.from([name, arg])
            } else {
                opt = Caffeination.Opt.from(name)
            }
            guard let optUnwrapped = opt else {
                Notifier.showErrorMessage(withTitle: txt("AD.bad-opt-config-title"), text: txt("AD.bad-opt-config-msg"))
                self.view.window?.close()
                return
            }
            params.append(optUnwrapped)
        }
        (NSApp.delegate as! AppDelegate).caffeination.handledStart(withOpts: params)
        self.view.window?.close()
    }
    
    /// Closes the argument panel
    @IBAction func cancelArguments(_ sender: NSButton) {
        self.view.window?.close()
    }
}

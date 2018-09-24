//
//  ArgumentPanelViewController.swift
//  Caffeinator
//
//  Created by aaplmath on 8/9/18.
//  Copyright © 2018 aaplmath. All rights reserved.
//

import Cocoa

class ArgumentPanelViewController: NSViewController {
    @IBOutlet weak var tButton: NSButton!
    @IBOutlet weak var tLabel: NSTextField!
    @IBOutlet weak var wButton: NSButton!
    @IBOutlet weak var wLabel: NSTextField!
    
    var args: [String: String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    /// Responds to an argument being (un)checked by adding it to/removing it from the args array, and if it allows a manually-input value, enables/disables the corresponding input button
    @IBAction func argumentChecked(_ sender: NSButton) {
        let title = sender.title
        let state = sender.state == .on
        if state {
            args[title] = ""
        } else {
            if let loc = args.index(forKey: title) {
                args.remove(at: loc)
            }
            if title == "-t" {
                tLabel.stringValue = txt("AD.no-argument-label")
            } else if title == "-w" {
                wLabel.stringValue = txt("AD.no-argument-label")
            }
        }
        if title == "-t" {
            tButton.isEnabled = state
        } else if title == "-w" {
            wButton.isEnabled = state
        }
    }
    
    /// Shows the value input dialog and uses its return value for the corresponding argument, as determined by the sender's tag. These values are then assigned to the corresponding dictionary item
    @IBAction func addValue(_ sender: NSButton) {
        let params = sender.tag == 0 ? (flag: "-t", label: tLabel) : (flag: "-w", label: wLabel)
        if let value = Notifier.showValueDialog(forParam: params.flag) {
            params.label?.stringValue = value
            args[params.flag] = value
        }
    }
    
    /// Converts the dictionary of arguments into an array of parameters, then passes that array to generateCaffeine() in dev mode.
    @IBAction func confirmArguments(_ sender: NSButton) {
        var params: [String] = []
        for (name, arg) in args {
            params.append(name)
            // This check is not strictly necessary, but makes things cleaner
            if arg != "" {
                params.append(arg)
            }
        }
        (NSApplication.shared.delegate as! AppDelegate).generateCaffeinate(withArgs: params, isDev: true)
        self.view.window?.close()
    }
    
    /// Closes the argument panel
    @IBAction func cancelArguments(_ sender: NSButton) {
        self.view.window?.close()
    }
    
    /// Responds to the "info" button on the argument input window by opening Apple's caffeinate man page on their online developer library. In future releases, this may be replaced with a native solution.
    @IBAction func viewManPage(_ sender: NSButton) {
        NSWorkspace.shared.open(URL(string: "https://developer.apple.com/legacy/library/documentation/Darwin/Reference/ManPages/man8/caffeinate.8.html")!)
    }
    
}

//
//  ProcessPanelViewController.swift
//  Caffeinator
//
//  Created by aaplmath on 6/17/19.
//  Copyright © 2019 aaplmath. All rights reserved.
//

import Cocoa

class ProcessPanelViewController: NSViewController, PseudoModal {
    
    @IBOutlet weak var selectorBox: NSComboBox!
    
    var properties: [String : Any] = [:]
    var onConfirm: (Any?) -> Void = {_ in }
    var onCancel: () -> Void = {}
    
    private var processes: [NSRunningApplication] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        processes = NSWorkspace.shared.runningApplications
        processes.sort { (a: NSRunningApplication, b: NSRunningApplication) -> Bool in
            let a1 = a.localizedName?.first ?? Character("")
            let b1 = b.localizedName?.first ?? Character("")
            return a1 < b1
        }
        selectorBox.dataSource = self
        // Do view setup here.
    }
    
    @IBAction func confirmClicked(_ sender: NSButton) {
//        onConfirm(pid)
        self.view.window?.close()
    }
    
    @IBAction func cancelClicked(_ sender: NSButton) {
        self.view.window?.close()
    }
    
}

extension ProcessPanelViewController: NSComboBoxDataSource {
    
    private func entryString(for app: NSRunningApplication) -> String {
        let procName = app.localizedName
        let procID = app.processIdentifier
        if let procName = procName {
            return "\(procName) (\(procID))"
        } else {
            return "PID \(procID)"
        }
    }
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return processes.count + 1
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        if index < processes.count {
            let app = processes[index]
            return entryString(for: app)
        } else {
            return txt("PPVC.other")
        }
    }
    
    func comboBox(_ comboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
        guard string.count > 0 else {
            return NSNotFound
        }
        let end = string.index(before: string.endIndex)
        guard let preStart = string.lastIndex(of: "(") else {
            return NSNotFound
        }
        let start = string.index(after: preStart)
        guard start < end, let pidStr = Int(string[start..<end]) else {
            return NSNotFound
        }
        let index = processes.firstIndex(where: { $0.processIdentifier == pidStr })
        return index ?? NSNotFound
    }
}
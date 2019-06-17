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
    @IBOutlet weak var tabView: NSTabView!
    @IBOutlet weak var pidInput: NSTextField!
    
    var properties: [String : Any] = [:]
    var onConfirm: (Any?) -> Void = {_ in }
    var onCancel: () -> Void = {}
    
    // TODO: Update this periodically
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
    }
    
    @IBAction func confirmClicked(_ sender: NSButton) {
        let tabID = tabView.selectedTabViewItem?.identifier as? String
        let pidOpt: pid_t?
        if tabID == "select" {
            pidOpt = processes[selectorBox.indexOfSelectedItem].processIdentifier
        } else if tabID == "pid" {
            pidOpt = pid_t(pidInput.stringValue)
        } else {
            pidOpt = nil
        }
        guard let pid = pidOpt else {
            Notifier.showErrorMessage(withTitle: txt("PPVC.process-failure-title"), text: txt("PPVC.process-failure-msg"))
            return
        }
        onConfirm(pid)
        self.view.window?.close()
    }
    
    @IBAction func cancelClicked(_ sender: NSButton) {
        self.view.window?.close()
    }
    
}

/// Represents an app in the combo box data source
struct MiniApp: CustomStringConvertible {
    var name: String?
    var pid: pid_t
    
    public var description: String {
        get {
            if let name = name {
                return "\(name) (\(pid))"
            } else {
                return "PID \(pid)"
            }
        }
    }
    
    init(from app: NSRunningApplication) {
        self.name = app.localizedName
        self.pid = app.processIdentifier
    }
}

extension ProcessPanelViewController: NSComboBoxDataSource {
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return processes.count
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return MiniApp(from: processes[index])
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

//
//  ProcessPanelViewController.swift
//  Caffeinator
//
//  Created by aaplmath on 6/17/19.
//  Copyright © 2019 aaplmath. All rights reserved.
//

import Cocoa

class ProcessPanelViewController: NSViewController, PseudoModal {
    
    private static let refreshFrequency: TimeInterval = 4.0
    
    @IBOutlet weak var selectorBox: NSComboBox!
    @IBOutlet weak var tabView: NSTabView!
    @IBOutlet weak var pidInput: NSTextField!
    
    weak var refreshTimer: Timer?
    
    var properties: [String : Any] = [:]
    var onConfirm: (Any?) -> Void = {_ in }
    var onCancel: () -> Void = {}
    
    private var processes: [NSRunningApplication] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadProcesses()
        selectorBox.dataSource = self
        
        refreshTimer = Timer.scheduledTimer(withTimeInterval: ProcessPanelViewController.refreshFrequency, repeats: true) { timer in
            self.reloadProcesses()
            self.selectorBox.reloadData()
        }
    }
    
    /// Refreshes the array of processes; `reloadData()` should be called on the combo box following this refresh
    private func reloadProcesses() {
        processes = NSWorkspace.shared.runningApplications
        processes.sort { (a: NSRunningApplication, b: NSRunningApplication) -> Bool in
            let a1 = a.localizedName?.first ?? Character("")
            let b1 = b.localizedName?.first ?? Character("")
            return a1 < b1
        }
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
    
    /// Prevents the refresh timer from carrying on beyond the lifecycle of the window
    override func viewWillDisappear() {
        refreshTimer?.invalidate()
    }
    
}

// Data source for combo box
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
        return processes.count
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return entryString(for: processes[index])
    }
    
    /// Tries to find an item matching the entered string based on the PID in parentheses. Note that, because this matches the final component of the string, it will likely only match auto-completed entries (auto-completion occurs by default anyway)
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

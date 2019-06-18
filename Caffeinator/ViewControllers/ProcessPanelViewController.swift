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
    
    private var processes: [Proc] = []
    var advanced = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        advanced = UserDefaults.standard.bool(forKey: "AdvancedProcessSelector")
        reloadProcesses()
        selectorBox.dataSource = self
        
        refreshTimer = Timer.scheduledTimer(withTimeInterval: ProcessPanelViewController.refreshFrequency, repeats: true) { timer in
            self.reloadProcesses()
            self.selectorBox.reloadData()
        }
        
        if UserDefaults.standard.bool(forKey: "ProcPanelPIDFocused") {
            tabView.selectTabViewItem(tabView.tabViewItems.last)
        }
    }
    
    /// Refreshes the array of processes; `reloadData()` should be called on the combo box following this refresh
    private func reloadProcesses() {
        if advanced {
            let pidCount = proc_listallpids(nil, 0)
            let pidListBuffer = UnsafeMutablePointer<pid_t>.allocate(capacity: Int(pidCount))
            defer {
                pidListBuffer.deallocate()
            }
            let bufferSize = pidCount * Int32(MemoryLayout<pid_t>.size)
            let pidCount2 = proc_listallpids(pidListBuffer, bufferSize)
            for i in 0..<pidCount2 {
                let pid = pidListBuffer[Int(i)]
                let name = getLibProcName(for: pid) ?? getLibProcPathEnd(for: pid) ?? nil
                processes.append(Proc(pid, name))
            }
            processes.sort { $0.name ?? "" < $1.name ?? "" }
        } else {
            let runningApps = NSWorkspace.shared.runningApplications
            processes = runningApps.map { Proc($0.processIdentifier, $0.localizedName) }
            processes.sort { $0.name ?? "" < $1.name ?? "" }
        }
    }
    
    @IBAction func confirmClicked(_ sender: NSButton) {
        let tabID = tabView.selectedTabViewItem?.identifier as? String
        let pidOpt: pid_t?
        if tabID == "select" {
            pidOpt = processes[selectorBox.indexOfSelectedItem].pid
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

/// Represents any process with a PID and optional name. Serves as a universal type for representing processes retrieved from NSWorkspace or libproc.
struct Proc: CustomStringConvertible {
    let pid: pid_t
    let name: String?
    
    public var description: String {
        get {
            return "\(name ?? "unknown") (\(pid))"
        }
    }
    
    init(_ pid: pid_t, _ name: String?) {
        self.pid = pid
        self.name = name
    }
}

// Delegate for tab view so we can remember selected process input mode
extension ProcessPanelViewController: NSTabViewDelegate {
    func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        if tabViewItem?.identifier as? String == "pid" {
            UserDefaults.standard.set(true, forKey: "ProcPanelPIDFocused")
        } else {
            UserDefaults.standard.set(false, forKey: "ProcPanelPIDFocused")
        }
    }
}

// Data source for combo box
extension ProcessPanelViewController: NSComboBoxDataSource {
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return processes.count
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return processes[index]
    }
    
    func comboBox(_ comboBox: NSComboBox, completedString string: String) -> String? {
        let nameMatchProc = processes.first(where: { app in
            guard let name = app.name else {
                return false
            }
            guard let sliceEnd = name.index(name.startIndex, offsetBy: string.count, limitedBy: name.endIndex) else {
                return false
            }
            let slice = name[name.startIndex..<sliceEnd]
            return slice.lowercased() == string.lowercased()
        })
        if let app = nameMatchProc {
            return app.description
        } else {
            return nil
        }
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
        guard start < end, let inputPID = Int(string[start..<end]) else {
            return NSNotFound
        }
        let index = processes.firstIndex(where: { $0.pid == inputPID })
        return index ?? NSNotFound
    }
}

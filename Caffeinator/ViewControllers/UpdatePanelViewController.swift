//
//  UpdatePanelViewController.swift
//  Caffeinator
//
//  Created by aaplmath on 5/26/19.
//  Copyright © 2019 aaplmath. All rights reserved.
//

import Cocoa

/// The VC for the updater's modal-like window
class UpdatePanelViewController: NSViewController, PseudoModal {

    @IBOutlet weak var versionsLabel: NSTextField!
    @IBOutlet weak var releaseNotesField: NSTextView!
    
    // These properties are to be set by `Updater` prior to the view appearing
    var onConfirm: (Any?) -> Void = {_ in } // update confirmed
    var onCancel: () -> Void = {} // update postponed
    var properties: [String: Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        releaseNotesField?.textContainerInset = NSSize(width: 5, height: 5)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        let newVersion = properties["newVersion"] as? String ?? ""
        let currentVersion = properties["currentVersion"] as? String ?? ""
        versionsLabel.stringValue = String(format: versionsLabel?.stringValue ?? "", newVersion, currentVersion)
        let releaseNotes = properties["releaseNotes"] as? NSAttributedString ?? NSAttributedString(string: "")
        releaseNotesField.textStorage?.setAttributedString(releaseNotes)
        releaseNotesField.textStorage?.foregroundColor = NSColor.textColor
    }
    
    @IBAction func updateClicked(_ sender: NSButton) {
        onConfirm(nil)
        self.view.window?.close()
    }
    
    @IBAction func postponeClicked(_ sender: NSButton) {
        onCancel()
        self.view.window?.close()
    }
}

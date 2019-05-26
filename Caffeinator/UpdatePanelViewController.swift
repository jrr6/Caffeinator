//
//  UpdatePanelViewController.swift
//  Caffeinator
//
//  Created by aaplmath on 5/26/19.
//  Copyright © 2019 aaplmath. All rights reserved.
//

import Cocoa

/// The VC for the updater's modal-like window
class UpdatePanelViewController: NSViewController {

    @IBOutlet weak var versionsLabel: NSTextField?
    @IBOutlet weak var releaseNotesField: NSTextView?
    
    // These properties are to be set by `Updater` prior to the view appearing
    var onUpdateConfirmed: () -> Void = {}
    var onUpdatePostponed: () -> Void = {}
    var currentVersion: String = ""
    var newVersion: String = ""
    var releaseNotes: NSAttributedString = NSAttributedString(string: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        releaseNotesField?.textContainerInset = NSSize(width: 5, height: 5)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        versionsLabel?.stringValue = String(format: versionsLabel?.stringValue ?? "", newVersion, currentVersion)
        releaseNotesField?.textStorage?.setAttributedString(releaseNotes)
        releaseNotesField?.textStorage?.foregroundColor = NSColor.textColor
    }
    
    @IBAction func updateClicked(_ sender: NSButton) {
        onUpdateConfirmed()
        self.view.window?.close()
    }
    
    @IBAction func postponeClicked(_ sender: NSButton) {
        onUpdatePostponed()
        self.view.window?.close()
    }
}

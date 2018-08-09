//
//  HelpPanelViewController.swift
//  Caffeinator
//
//  Created by aaplmath on 8/9/18.
//  Copyright © 2018 aaplmath. All rights reserved.
//

import Cocoa

class HelpPanelViewController: NSViewController {

    @IBOutlet weak var helpTitle: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        helpTitle.stringValue = "Caffeinator \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")"
    }
    
}

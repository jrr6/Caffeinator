//
//  HelpPanelViewController.swift
//  Caffeinator
//
//  Created by aaplmath on 8/9/18.
//  Copyright © 2018 aaplmath. All rights reserved.
//

import Cocoa
import WebKit

class HelpPanelViewController: NSViewController {

    @IBOutlet var webView: WKWebView!
    
    /// Determines whether Dark Mode is enabled on macOS Mojave; if the OS is outdated, it defaults to light
    var isDarkMode: Bool {
        get {
            if #available(OSX 10.14, *) {
                return view.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            }
            return false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let helpFile: String
        if isDarkMode {
            helpFile = "help_dark"
        } else {
            helpFile = "help_light"
        }
        if let resource = Bundle.main.url(forResource: helpFile, withExtension: "html") {
            webView.load(URLRequest(url: resource))
        } else {
            webView.loadHTMLString("<p>Could not find help file.</p>", baseURL: URL(string: "data://"))
        }
    }
    
    override func viewWillAppear() {
        let versionStr = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        view.window?.title = "Caffeinator \(versionStr) Help"
    }
}

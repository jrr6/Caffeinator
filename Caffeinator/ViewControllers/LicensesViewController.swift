//
//  LicensesViewController.swift
//  Caffeinator
//
//  Created by aaplmath on 8/9/18.
//  Copyright © 2018 aaplmath. All rights reserved.
//

import Cocoa

class LicensesViewController: NSViewController {

    @IBOutlet weak var licenseField: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let rtfPath = Bundle.main.url(forResource: "Licenses", withExtension: "rtf") {
            do {
                let licenseString = try NSAttributedString(url: rtfPath, options: [.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil)
                licenseField.textStorage?.setAttributedString(licenseString)
            } catch {
                licenseField.string = txt("AD.license-error")
            }
        }
    }
    
}

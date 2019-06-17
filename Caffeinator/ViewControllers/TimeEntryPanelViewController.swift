//
//  TimeEntryPanelViewController.swift
//  Caffeinator
//
//  Created by aaplmath on 6/17/19.
//  Copyright © 2019 aaplmath. All rights reserved.
//

import Cocoa

/// Time entry modal-like window
class TimeEntryPanelViewController: NSViewController, PseudoModal {

    // tag constants
    private let hourTag = 0
    private let minuteTag = 1
    private let secondTag = 2
    
    @IBOutlet weak var hourInput: NSTextField!
    @IBOutlet weak var minuteInput: NSTextField!
    @IBOutlet weak var secondInput: NSTextField!
    
    @IBOutlet weak var hourStepper: NSStepper!
    @IBOutlet weak var minuteStepper: NSStepper!
    @IBOutlet weak var secondStepper: NSStepper!
    
    // didSets are structured a) to prevent negative values and b) so that text fields will populate if the value > 0 or if they already have a value (e.g., we're going from 1 down to 0 using the stepper) when the stepper is used (n.b. this does cause a redundant set when the control text changes)
    // steppers are bound to these variables; text fields interact with them via didSet and the custom delegate defined at the bottom of this file
    @objc dynamic var hours: Int = 0 {
        didSet {
            if hours < 0 {
                hours = 0
            }
            if hours > 0 || hourInput.stringValue != "" {
                hourInput.stringValue = String(hours)
            }
        }
    }
    @objc dynamic var minutes: Int = 0 {
        didSet {
            if minutes < 0 {
                minutes = 0
            }
            if minutes > 0 || minuteInput.stringValue != "" {
                minuteInput.stringValue = String(minutes)
            }
        }
    }
    @objc dynamic var seconds: Int = 0 {
        didSet {
            if seconds < 0 {
                seconds = 0
            }
            if seconds > 0 || secondInput.stringValue != "" {
                secondInput.stringValue = String(seconds)
            }
        }
    }
    
    // PseudoModal fields
    var properties: [String: Any] = [:]
    var onConfirm: (Any?) -> Void = { _ in }
    var onCancel: () -> Void = {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hourInput.formatter = TimeValueFormatter(for: .hour)
        minuteInput.formatter = TimeValueFormatter(for: .minute)
        secondInput.formatter = TimeValueFormatter(for: .second)
    }

    @IBAction func confirmClicked(_ sender: NSButton) {
        let interval = Double((hours * 60 * 60) + (minutes * 60) + (seconds))
        // If the interval < 1, AppDelegate will throw needless errors; it's okay to treat a 0-duration input as functionally equivalent to a cancel
        if interval > 0 {
            onConfirm(interval)
        }
        self.view.window?.close()
    }
    
    @IBAction func cancelClicked(_ sender: NSButton) {
        self.view.window?.close()
    }
}

/// A number formatter for time component entries
class TimeValueFormatter: NumberFormatter {
    let comp: Component?
    enum Component {
        case hour, minute, second
    }
    
    init(for comp: Component) {
        self.comp = comp
        super.init()
    }
    required init?(coder aDecoder: NSCoder) {
        self.comp = nil
        super.init(coder: aDecoder)
    }
    
    override func isPartialStringValid(_ partialString: String, newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        if partialString.isEmpty {
            return true
        }
        guard let intVal = Int(partialString) else {
            return false
        }
        if intVal < 0 {
            return false
        }
        if self.comp == .hour {
            // caffeinate takes the time value (seconds), multiplies it by NSEC_PER_SEC, and stores in an Int64; thus, maximum allowable second value is 9223372036, so maximum hours (given that minutes and seconds could each be 60) is floor((9223372036 - 60*60 - 60) / 60 / 60) = 2562046
            return intVal <= 2562046
        } else {
            return intVal < 60
        }
    }
}


// Writes text field values to controller variables
extension TimeEntryPanelViewController: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        let textField = obj.object as! NSTextField
        let val = textField.stringValue
        let intVal = Int(val) ?? 0
        switch textField.tag {
        case hourTag:
            hours = intVal
        case minuteTag:
            minutes = intVal
        case secondTag:
            seconds = intVal
        default:
            break
        }
    }
}

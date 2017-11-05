
//  AppDelegate.swift
//  Caffeinator
//
//  Created by aaplmath on 11/8/15.
//  Copyright © 2017 aaplmath. All rights reserved.
//

import Cocoa

extension NSAlert {
    open func runModalInFront() -> NSApplication.ModalResponse {
        NSApplication.shared.activate(ignoringOtherApps: true)
        return self.runModal()
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var mainMenu: NSMenu!
    @IBOutlet weak var argumentPanel: NSPanel!
    
    @IBOutlet weak var helpHUD: NSPanel!
    @IBOutlet weak var helpTitle: NSTextField!
    
    @IBOutlet weak var licenseHUD: NSPanel!
    @IBOutlet weak var licenseField: NSTextView!
    
    @IBOutlet weak var startMenu: NSMenuItem!
    @IBOutlet weak var processMenu: NSMenuItem!
    @IBOutlet weak var timedMenu: NSMenuItem!
    
    @IBOutlet weak var displayToggle: NSMenuItem!
    @IBOutlet weak var promptToggle: NSMenuItem!
    
    var df: UserDefaults!
    var nc: NotificationCenter!
    var updater: Updater!
    var task: Process?
    
    // MARK: - Main Menu
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    
    // Add Notification Center observer to detect changes to the "display" preference, load the existing preference (or set one, true by default, if none exists), set up the menu item and windows, and check for updates
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.image = NSImage(named: NSImage.Name(rawValue: "CoffeeCup"))
        statusItem.menu = mainMenu
        helpTitle.stringValue = "Caffeinator \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")"
        if let rtfPath = Bundle.main.url(forResource: "Licenses", withExtension: "rtf") {
            do {
                let licenseString = try NSAttributedString(url: rtfPath, options: [.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil)
                licenseField.textStorage?.setAttributedString(licenseString)
            } catch {
                licenseField.string = "There was an error parsing the License text. Please report this so it can be fixed."
            }
        }
        
        // Configure UserDefaults
        df = UserDefaults.standard
        nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(AppDelegate.defaultsDidChange), name: UserDefaults.didChangeNotification, object: nil)
        initDefaults()
        
        // Set up updating
        updater = Updater()
    }
    
    // Ensures that all UserDefaults values have been initialized and updates each preference's corresponding menu item accordingly
    func initDefaults() {
        // TODO: If the number of preferences in Caffeinator gets too big, this needs to be turned into a more organized system (think: loops, etc.)
        if df.object(forKey: "CaffeinateDisplay") == nil {
            df.set(true, forKey: "CaffeinateDisplay")
        }
        if df.object(forKey: "PromptBeforeExecuting") == nil {
            df.set(false, forKey: "PromptBeforeExecuting")
        }
        defaultsDidChange()
    }
    
    // Respond to a change to the CaffeinateDisplay default — while this is unnecessary for updates triggered by clicks in the application, menu items do need to be updated if the default is updated from the Terminal or on application launch
    @objc func defaultsDidChange() {
        RunLoop.main.perform(inModes: [.eventTrackingRunLoopMode, .defaultRunLoopMode]) {
            self.displayToggle.state = self.df.bool(forKey: "CaffeinateDisplay") ? .on : .off
            self.promptToggle.state = self.df.bool(forKey: "PromptBeforeExecuting") ? .on : .off
        }
    }
    
    // Terminate caffeinate upon application termination to prevent "zombie" processes (which should be terminated anyway, but just for safety)
    func applicationWillTerminate(_ notification: Notification) {
        if let activeTask = task {
            activeTask.terminate()
        }
    }
    
    // Responsible for managing the inactive/active state of the app. If there is an active "Caffeination," disable the appropriate menu items and set the icon green. Otherwise, enable all menu items and set the icon to the template
    var active = false {
        didSet {
            RunLoop.main.perform(inModes: [.eventTrackingRunLoopMode, .defaultRunLoopMode]) {
                self.startMenu.title = self.active ? "Stop Caffeinator" : "Start Caffeinator"
                self.processMenu.isEnabled = !self.active
                if (!self.active) {
                    self.processMenu.title = "Caffeinate a Process…"
                }
                self.timedMenu.isEnabled = !self.active
                self.argumentMenu.isEnabled = !self.active
                self.statusItem.image = self.active ? NSImage(named: NSImage.Name(rawValue: "CoffeeCupGreen")) : NSImage(named: NSImage.Name(rawValue: "CoffeeCup"))
            }
        }
    }

    @IBAction func changeDefault(_ sender: NSMenuItem) {
        let val: Bool
        if sender.state == .on {
            val = false
        } else {
            val = true
        }
        RunLoop.main.perform(inModes: [.eventTrackingRunLoopMode, .defaultRunLoopMode]) {
            sender.state = val ? .on : .off
        }
        let key: String?
        switch sender.tag {
        case 1:
            key = "CaffeinateDisplay"
        case 2:
            key = "PromptBeforeExecuting"
        default:
            key = nil
        }
        if let key = key {
            df.set(val, forKey: key)
        } else {
            Notifier.showErrorMessage(withTitle: "Unknown Preference Tag", text: "An attempt was made to set a preference by an unrecognized sender. This error should be reported.")
        }
    }
    
    // Responds to the Quit menu item
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
    
    // Start Caffeinate with no args, or stop it if it is active
    @IBAction func startClicked(_ sender: NSMenuItem) {
        if sender.title == "Start Caffeinator" {
            generateCaffeine(withArgs: [], isDev: false)
        } else {
            task?.terminate()
            active = false
        }
    }
    
    // Responds to the "Run with args" item by opening the argument panel
    @IBAction func argumentClicked(_ sender: NSMenuItem) {
        argumentPanel.makeKeyAndOrderFront(nil)
    }
    
    // Responds to the "Caffeinate process" item by prompting entry of a PID, which is passed alongside the corresponding "-w" argument to generateCaffeine()
    @IBAction func processClicked(_ sender: NSMenuItem) {
        DispatchQueue.main.async {
            if let res = Notifier.showInputDialog(withWindowTitle: "Caffeinate a Process", title: "Select a Process", text: "Enter the PID of the process you would like to Caffeinate. This PID can be found in Activity Monitor:") {
                if let text = Int(res) {
                    var labelName = "PID \(res)"
                    if let appName = NSRunningApplication(processIdentifier: pid_t(text))?.localizedName {
                        labelName = appName
                    }
                    RunLoop.main.perform(inModes: [.eventTrackingRunLoopMode, .defaultRunLoopMode]) {
                        self.processMenu.title = "Caffeinating \(labelName)"
                    }
                    self.generateCaffeine(withArgs: ["-w", String(text)], isDev: false)
                } else {
                    Notifier.showErrorMessage(withTitle: "Illegal Input", text: "You must enter the PID of the process you wish to Caffeinate.")
                }
            }
        }
    }
    
    // Responds to the "Timed Caffeination" item. If a preset is selected, the number is parsed out of the string and multiplied as necessary. If custom entry is selected, a time entry prompt is shows, followed by a confirmation of the user input's validity (generating errors as necessary). The generated time (in seconds) is passed to generateCaffeine() along with the corresponding "-t" argument
    @IBAction func timedClicked(_ sender: NSMenuItem) {
        DispatchQueue.main.async {
            let title = sender.title
            var time: Double? = nil
            var multiplier: Double? = nil
            var loc: Range<Substring.Index>? = nil
            
            if let range = title.range(of: " minutes") {
                multiplier = 60
                loc = range
            } else if let range = title.range(of: " hours") {
                multiplier = 3600
                loc = range
            } else {
                guard let res = Notifier.showInputDialog(withWindowTitle: "Timed Caffeination", title: "Custom Time Entry", text: "Enter the amount of time for which you would like Caffeinator to keep your computer awake, IN MINUTES:") else {
                    // User canceled
                    return
                }
                guard let text = Double(res) else {
                    Notifier.showErrorMessage(withTitle: "Illegal Input", text: "You must enter an integer or decimal number.")
                    return
                }
                time = text * 60
            }
            if let multi = multiplier, let range = loc {
                guard let preset = Double(title[..<range.lowerBound]) else {
                    Notifier.showErrorMessage(withTitle: "Unknown Preset Value", text: "An error occurred when attempting to parse the selected preset. This is unexpected behavior and should be reported.")
                    return
                }
                time = preset * multi
            }
            guard let t = time, t > 1 else {
                Notifier.showErrorMessage(withTitle: "Illegal Time Value", text: "The time value must be a valid number greater than or equal to 1 second.")
                return
            }
            self.generateCaffeine(withArgs: ["-t", String(t)], isDev: false)
        }
    }
    
    // Responds to the "Help" item by opening the Help window
    @IBAction func helpPressed(_ sender: NSMenuItem) {
        helpHUD.makeKeyAndOrderFront(nil)
    }
    
    // Responds to the "View License Information" menu item by opening the License HUD
    @IBAction func licensePressed(_ sender: NSMenuItem) {
        licenseHUD.makeKeyAndOrderFront(nil)
    }
    
    // Generates an NSTask based on the arguments it is passed. If "dev" mode is not enabled (i.e., individual arguments have not been specified by the user), it will automatically add "-i" and, if the user has decided to Caffeinate their display, "-d"
    func generateCaffeine(withArgs args: [String], isDev: Bool) {
        var arguments = args
        if !isDev {
            arguments.append("-i")
            if df.bool(forKey: "CaffeinateDisplay") {
                arguments.append("-d")
            }
        }
        if df.bool(forKey: "PromptBeforeExecuting") {
            let alert = NSAlert()
            alert.messageText = "Confirm Caffeination"
            alert.informativeText = "The following command will be run:\ncaffeinate \(arguments.joined(separator: " "))"
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.addButton(withTitle: "Cancel")
            let res = alert.runModalInFront()
            if res != .alertFirstButtonReturn {
                // User cancelled
                return
            }
        }
        let caffeinatePath = "/usr/bin/caffeinate"
        guard FileManager.default.fileExists(atPath: caffeinatePath) else {
            Notifier.showErrorMessage(withTitle: "Could Not Find Caffeinate", text: "Your system does not appear to have caffeinate installed. Ensure that your disk permissions are properly set; you may also need to re-install macOS.")
            return
        }
        DispatchQueue.global(qos: .background).async { // TODO: Do we need [weak self]
            () -> Void in
            self.task = Process()
            self.task!.launchPath = caffeinatePath
            self.task!.arguments = arguments
            self.task!.terminationHandler = self.taskDidTerminate
            self.task!.launch()
        }
        active = true
    }
    
    // Clean-up method that makes sure that the inactive state of the app is restored once caffeinate finishes running
    func taskDidTerminate(_ task: Process) {
        active = false
    }
    
    // MARK: - Argument Panel
    
    @IBOutlet weak var argumentMenu: NSMenuItem!
    @IBOutlet weak var tButton: NSButton!
    @IBOutlet weak var tLabel: NSTextField!
    @IBOutlet weak var wButton: NSButton!
    @IBOutlet weak var wLabel: NSTextField!
    
    var args: [String: String] = [:]
    
    // Responds to an argument being (un)checked by adding it to/removing it from the args array, and if it allows a manually-input value, enable/disable the corresponding input button
    @IBAction func argumentChecked(_ sender: NSButton) {
        let title = sender.title
        let state = sender.state == .on
        if state {
            args[title] = ""
        } else {
            if let loc = args.index(forKey: title) {
                args.remove(at: loc)
            }
            if title == "-t" {
                tLabel.stringValue = "None"
            } else if title == "-w" {
                wLabel.stringValue = "None"
            }
        }
        if title == "-t" {
            tButton.isEnabled = state
        } else if title == "-w" {
            wButton.isEnabled = state
        }
    }
    
    // Shows the value input dialog and uses its return value for the corresponding argument, as determined by the sender's tag. These values are then assigned to the corresponding dictionary item
    @IBAction func addValue(_ sender: NSButton) {
        let params = sender.tag == 0 ? (flag: "-t", label: tLabel) : (flag: "-w", label: wLabel)
        if let value = Notifier.showValueDialog(forParam: params.flag) {
            params.label.stringValue = value
            args[params.flag] = value
        }
    }
    
    // Convert the dictionary of arguments into an array of parameters, then pass that array to generateCaffeine() in dev mode.
    @IBAction func confirmArguments(_ sender: NSButton) {
        var params: [String] = []
        for (name, arg) in args {
            params.append(name)
            // This check is not strictly necessary, but makes things cleaner
            if arg != "" {
                params.append(arg)
            }
        }
        generateCaffeine(withArgs: params, isDev: true)
        argumentPanel.close()
    }
    
    // Close the argument panel
    @IBAction func cancelArguments(_ sender: NSButton) {
        argumentPanel.close()
    }
    
    // Responds to the "info" button on the argument input window by opening Apple's caffeinate man page on their online developer library. In future releases, this may be replaced with a native solution.
    @IBAction func viewManPage(_ sender: NSButton) {
        NSWorkspace.shared.open(URL(string: "https://developer.apple.com/legacy/library/documentation/Darwin/Reference/ManPages/man8/caffeinate.8.html")!)
    }
    
    // Responds to user request to check for updates by calling checkForUpdate()
    @IBAction func checkForUpdatesClicked(_ sender: NSMenuItem) {
        updater.checkForUpdate(isUserInitiated: true)
    }
    
    // Remove Notification Center observer on deinit
    deinit {
        nc.removeObserver(self)
    }
}


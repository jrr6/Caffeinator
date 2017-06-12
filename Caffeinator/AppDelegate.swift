//
//  AppDelegate.swift
//  Caffeinator
//
//  Created by aaplmath on 11/8/15.
//  Copyright © 2017 aaplmath. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let VERSION_NUMBER = 112
    
    // MARK: - Outlets
    
    @IBOutlet weak var mainMenu: NSMenu!
    @IBOutlet weak var argumentPanel: NSPanel!
    @IBOutlet weak var helpHUD: NSPanel!
    
    @IBOutlet weak var startMenu: NSMenuItem!
    @IBOutlet weak var processMenu: NSMenuItem!
    @IBOutlet weak var timedMenu: NSMenuItem!
    
    @IBOutlet weak var displayToggle: NSMenuItem!
    @IBOutlet weak var promptToggle: NSMenuItem!
    
    var task: Process?
    
    // MARK: - Main Menu
    
    let statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
   
    let df = UserDefaults.standard
    let nc = NotificationCenter.default
    
    // Add Notification Center observer to detect changes to the "display" preference, load the existing preference (or set one, true by default, if none exists), set up the menu item, and check for updates
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        nc.addObserver(self, selector: #selector(AppDelegate.defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
        initDefaults()
        statusItem.image = NSImage(named: "CoffeeCup")
        statusItem.menu = mainMenu
        checkForUpdate(userInitiated: false)
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
            startMenu.title = active ? "Stop Caffeinator" : "Start Caffeinator"
            processMenu.isEnabled = !active
            if (!active) {
                processMenu.title = "Caffeinate a Process…"
            }
            timedMenu.isEnabled = !active
            argumentMenu.isEnabled = !active
            statusItem.image = active ? NSImage(named: "CoffeeCupGreen") : NSImage(named: "CoffeeCup")
        }
    }

    // Ensures that all NSUserDefaults values have been initialized and updates each preference's corresponding menu item accordingly
    func initDefaults() {
        // TODO: If the number of preferences in Caffeinator gets too big, this needs to be turned into a more organized system (think: loops, etc.)
        if df.object(forKey: "CaffeinateDisplay") == nil {
            df.set(true, forKey: "CaffeinateDisplay")
        }
        if df.object(forKey: "PromptBeforeExecuting") == nil {
            df.set(false, forKey: "PromptBeforeExecuting")
        }
        defaultsChanged()
    }
    
    // Respond to a change to the CaffeinateDisplay default — while this is unnecessary for updates triggered by clicks in the application, menu items do need to be updated if the default is updated from the Terminal or on application launch
    func defaultsChanged() {
        displayToggle.state = df.bool(forKey: "CaffeinateDisplay") ? NSOnState : NSOffState
        promptToggle.state = df.bool(forKey: "PromptBeforeExecuting") ? NSOnState : NSOffState
    }
    
    // Toggle a given preference and update NSUserDefaults accordingly
    @IBAction func changeDefault(_ sender: NSMenuItem) {
        let val: Bool
        if sender.state == NSOnState {
            sender.state = NSOffState
            val = false
        } else {
            sender.state = NSOnState
            val = true
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
            errorMessage("Unknown Preference Tag", text: "An attempt was made to set a preference by an unrecognized sender. This error should be reported.")
        }
    }
    
    // Responds to the Quit menu item
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
    
    // Start Caffeinate with no args, or stop it if it is active
    @IBAction func startClicked(_ sender: NSMenuItem) {
        if sender.title == "Start Caffeinator" {
            generateCaffeine([], isDev
                : false)
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
        if let res = inputDialog("Caffeinate a Process", title: "Select a Process", text: "Enter the PID of the process you would like to Caffeinate. This PID can be found in Activity Monitor:") {
            if let text = Int(res) {
                if let app = NSRunningApplication(processIdentifier: pid_t(text)) {
                    processMenu.title = "Caffeinating \(app.localizedName ?? "PID \(text)")"
                    generateCaffeine(["-w", String(text)], isDev: false)
                } else {
                    errorMessage("Illegal PID", text: "There is no process with the PID \(text).")
                }
            } else {
                errorMessage("Illegal Input", text: "You must enter the PID of the process you wish to Caffeinate.")
            }
        }
    }
    
    // Responds to the "Timed Caffeination" item. If a preset is selected, the number is parsed out of the string and multiplied as necessary. If custom entry is selected, a time entry prompt is shows, followed by a confirmation of the user input's validity (generating errors as necessary). The generated time (in seconds) is passed to generateCaffeine() along with the corresponding "-t" argument
    @IBAction func timedClicked(_ sender: NSMenuItem) {
        let title = sender.title
        var time: Double? = nil
        var multiplier: Double? = nil
        var loc: Range<String.CharacterView.Index>? = nil
        
        if let range = title.range(of: "minutes") {
            multiplier = 60
            loc = range
        } else if let range = title.range(of: "hours") {
            multiplier = 3600
            loc = range
        } else {
            if let res = inputDialog("Timed Caffeination", title: "Custom Time Entry", text: "Enter the amount of time for which you would like Caffeinator to keep your computer awake, IN MINUTES:") {
                if let text = Double(res) {
                    time = text * 60
                } else {
                    errorMessage("Illegal Input", text: "You must enter an integer or decimal number.")
                }
            }
        }
        if let multi = multiplier, let range = loc {
            time = Double(title.substring(to: title.index(before: range.lowerBound)))! * multi
        }
        if let t = time {
            generateCaffeine(["-t", String(t)], isDev: false)
        } else {
            errorMessage("No Time Assigned", text: "No time value was passed to caffeinate.")
        }
    }
    
    // Responds to the "Help" item by opening the Help window
    @IBAction func helpPressed(_ sender: NSMenuItem) {
        helpHUD.makeKeyAndOrderFront(nil)
    }
    
    // Generates an NSTask based on the arguments it is passed. If "dev" mode is not enabled (i.e., individual arguments have not been specified by the user), it will automatically add "-i" and, if the user has decided to Caffeinate their display, "-d"
    func generateCaffeine(_ arguments: [String], isDev: Bool) {
        var arguments = arguments
        if !isDev {
            arguments.append("-i")
            if df.bool(forKey: "CaffeinateDisplay") {
                arguments.append("-d")
            }
        }
        print("Executing: " + String(describing: arguments))
        if (df.bool(forKey: "PromptBeforeExecuting")) {
            let alert = NSAlert()
            alert.messageText = "Confirm Caffeination"
            alert.informativeText = "The following command will be run:\ncaffeinate \(arguments.joined(separator: " "))"
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.addButton(withTitle: "Cancel")
            let res = alert.runModal()
            if res != NSAlertFirstButtonReturn {
                return
            }
        }
        DispatchQueue.global(qos: .background).async { // TODO: Do we need [weak self]
            () -> Void in
            self.task = Process()
            self.task!.launchPath = "/usr/bin/caffeinate"
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
    
    // Remove Notification Center observer on deinit
    deinit {
        nc.removeObserver(self)
    }
    
    // MARK: - Argument Panel
    
    @IBOutlet weak var argumentMenu: NSMenuItem!
    @IBOutlet weak var tButton: NSButton!
    @IBOutlet weak var tLabel: NSTextField!
    @IBOutlet weak var wButton: NSButton!
    @IBOutlet weak var wLabel: NSTextField!
    
    var args: [String] = []
    var twArgs: [String: String] = [:]
    
    // Responds to an argument being (un)checked by adding it to/removing it from the args array, and if it allows a manually-input value, enable/disable the corresponding input button
    @IBAction func argumentChecked(_ sender: NSButton) {
        let title = sender.title
        let state = sender.state == NSOnState
        if state {
            args.append(title)
        } else {
            if let loc = args.index(of: title) {
                args.remove(at: loc)
            }
        }
        if title == "-t" {
            tButton.isEnabled = state
        } else if title == "-w" {
            wButton.isEnabled = state
        }
    }
    
    // Shows the value input dialog and uses its return value for the corresponding argument, as determined by the sender's tag. These values are stored in "twArgs" so they can easily be added/removed until confirmArguments() is called
    @IBAction func addValue(_ sender: NSButton) {
        let params = sender.tag == 0 ? ("-t", tLabel) : ("-w", wLabel)
        if let value = showValueDialog(params.0) {
            params.1.stringValue = value
            twArgs[params.0] = value
        }
    }
    
    // Displays a value input dialog for use in addValue(). Not to be confused with inputDialog()
    func showValueDialog(_ paramName: String) -> String? {
        return inputDialog("Value Input", title: "Please Enter a Value", text: "Please enter the value for the \(paramName) parameter below:")
    }
    
    // Merge twArgs into the appropriate locations (directly after the corresponding argument) in args, then call generateCaffeine() in dev mode with args
    @IBAction func confirmArguments(_ sender: NSButton) {
        for (name, arg) in twArgs {
            if let index = args.index(of: name) {
                args.insert(arg, at: index + 1)
            }
        }
        generateCaffeine(args, isDev: true)
        argumentPanel.close()
    }
    
    // Close the argument panel
    @IBAction func cancelArguments(_ sender: NSButton) {
        argumentPanel.close()
    }
    
    // Responds to the "info" button on the argument input window by opening Apple's caffeinate manpage on their online developer library. In future releases, this may be replaced with a native solution.
    @IBAction func viewManpage(_ sender: NSButton) {
        NSWorkspace.shared().open(URL(string: "https://developer.apple.com/legacy/library/documentation/Darwin/Reference/ManPages/man8/caffeinate.8.html")!)
    }
    
    // MARK: - Update Functions
    
    // Queries the server to see if a new version is available. If it is, alerts the user and opens the file in their browser.
    func checkForUpdate(userInitiated: Bool) {
        let url = URL(string: "https://aaplmath.github.io/Caffeinator/latestversion")!
        let session = URLSession.shared
        let query = session.dataTask(with: url, completionHandler: { data, response, error in
            let str = String(data: data!, encoding: String.Encoding.utf8)
            if var versionString = str, let serverVersion = Int(versionString) {
                if (serverVersion > self.VERSION_NUMBER) {
                    DispatchQueue.main.async {
                        var versionChars = versionString.characters
                        // FIXME: This could not be a more hideous solution. Will be addressed in future releases.
                        versionChars.insert(".", at: versionChars.index(after: versionChars.startIndex))
                        versionChars.insert(".", at: versionChars.index(after: versionChars.index(after: versionChars.index(after: versionChars.startIndex))))
                        versionString = String(versionChars)
                        
                        let alert = NSAlert()
                        alert.window.title = "Caffeinator Update"
                        alert.messageText = "Update Available"
                        alert.informativeText = "A new version of Caffeinator (\(versionString)) is available. Would you like to download it now?"
                        alert.addButton(withTitle: "Update")
                        alert.addButton(withTitle: "Not Now")
                        alert.alertStyle = .informational
                        if alert.runModal() == NSAlertFirstButtonReturn {
                            let downloadURL = URL(string: "https://www.github.com/aaplmath/caffeinator/releases/download/v\(versionString)/Caffeinator.dmg")!
                            NSWorkspace.shared().open(downloadURL)
                        }
                    }
                } else if (userInitiated) {
                    DispatchQueue.main.async {
                        let alert = NSAlert()
                        alert.window.title = "Caffeinator Update"
                        alert.messageText = "No Updates Available"
                        alert.informativeText = "You're running the latest version of Caffeinator."
                        alert.addButton(withTitle: "OK")
                        alert.runModal()
                    }
                }
            }
        }) 
        query.resume()
    }
    
    // Responds to user request to check for updates by calling checkForUpdate()
    @IBAction func checkForUpdatesClicked(_ sender: NSMenuItem) {
        checkForUpdate(userInitiated: true)
    }
    
    // MARK: - Utility Alert Functions
    
    // Show a two-button text input dialog to the user and returns the String result if the user presses OK. Not to be confused with showValueDialog()
    func inputDialog(_ windowTitle: String, title: String, text: String) -> String? {
        let alert = NSAlert()
        alert.window.title = windowTitle
        alert.messageText = title
        alert.informativeText = text
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        alert.alertStyle = .informational
        let input = NSTextField(frame: NSMakeRect(0, 0, 200, 24))
        alert.accessoryView = input
        let button = alert.runModal()
        if button == NSAlertFirstButtonReturn {
            return input.stringValue
        }
        return nil
    }
    
    // Shows an error message with the specified text
    func errorMessage(_ title: String, text: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.window.title = "Error"
            alert.messageText = title
            alert.informativeText = text
            alert.alertStyle = .warning
            alert.runModal()
        }
    }

}


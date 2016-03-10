//
//  AppDelegate.swift
//  Caffeinator
//
//  Created by aaplmath on 11/8/15.
//  Copyright © 2016 aaplmath. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var mainMenu: NSMenu!
    @IBOutlet weak var argumentPanel: NSPanel!
    @IBOutlet weak var helpHUD: NSPanel!
    
    @IBOutlet weak var startMenu: NSMenuItem!
    @IBOutlet weak var processMenu: NSMenuItem!
    @IBOutlet weak var timedMenu: NSMenuItem!
    
    var task: NSTask?
    
    // MARK: - Main Menu
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSSquareStatusItemLength)
   
    let df = NSUserDefaults.standardUserDefaults()
    let nc = NSNotificationCenter.defaultCenter()
    
    var sleepDisplay = true
    
    // Add Notification Center observer to detect changes to the "display" preference, load the existing preference (or set one, true by default, if none exists), and set up the menu item
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        nc.addObserver(self, selector: "defaultsChanged", name: NSUserDefaultsDidChangeNotification, object: nil)
        if df.objectForKey("CaffeinateDisplay") != nil {
            sleepDisplay = df.boolForKey("CaffeinateDisplay")
        } else {
            sleepDisplay = true
            df.setBool(true, forKey: "CaffeinateDisplay")
        }
        statusItem.image = NSImage(named: "CoffeeCup")
        statusItem.menu = mainMenu
    }
    
    // Terminate caffeinate upon application termination to prevent "zombie" processes
    func applicationWillTerminate(notification: NSNotification) {
        if let activeTask = task {
            activeTask.terminate()
        }
    }
    
    // Responsible for managing the inactive/active state of the app. If there is an active "Caffeination," disable the appropriate menu items and set the icon green. Otherwise, enable all menu items and set the icon to the template
    var active = false {
        didSet {
            startMenu.title = active ? "Stop Caffeinator" : "Start Caffeinator"
            processMenu.enabled = !active
            timedMenu.enabled = !active
            argumentMenu.enabled = !active
            statusItem.image = active ? NSImage(named: "CoffeeCupGreen") : NSImage(named: "CoffeeCup")
        }
    }

    // Respond to a change to the CaffeinateDisplay default — this is used for both external updates (e.g., from Terminal using defaults write) and internal ones (see caffeinateDisplay())
    func defaultsChanged() {
        sleepDisplay = df.boolForKey("CaffeinateDisplay")
    }
    
    // Respons to the Quit menu item
    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }
    
    // Toggle the "display" option and update NSUserDefaults
    @IBAction func caffeinateDisplay(sender: NSMenuItem) {
        let val: Bool
        if sender.state == NSOnState {
            sender.state = NSOffState
            val = false
        } else {
            sender.state = NSOnState
            val = true
        }

        df.setBool(val, forKey: "CaffeinateDisplay")
    }
    
    // Start Caffeinate with no args, or stop it if it is active
    @IBAction func startClicked(sender: NSMenuItem) {
        if sender.title == "Start Caffeinator" {
            generateCaffeine([], dev: false)
        } else {
            task?.terminate()
            active = false
        }
    }
    
    // Responds to the "Run with args" item by opening the argument panel
    @IBAction func argumentClicked(sender: NSMenuItem) {
        argumentPanel.makeKeyAndOrderFront(nil)
    }
    
    // Responds to the "Caffeinate process" item by prompting entry of a PID, which is passed alongside the corresponding "-w" argument to generateCaffeine()
    @IBAction func processClicked(sender: NSMenuItem) {
        if let res = inputDialog("Caffeinate a Process", title: "Select a Process", text: "Enter the PID of the process you would like to Caffeinate. This PID can be found in the Activity Monitor application:") {
            if let text = Int(res) {
                generateCaffeine(["-w", String(text)], dev: false)
            } else {
                errorMessage("Illegal Input", text: "You must enter the PID of the process you wish to Caffeinate.")
            }
        }
    }
    
    // Responds to the "Timed Caffeination" item. If a preset is selected, the number is parsed out of the string and multiplied as necessary. If custom entry is seleted, a time entry prompt is shows, followed by a confirmation of the user input's validity (generating errors as necessary). The generated time (in seconds) is passed to generateCaffeine() along with the corresponding "-t" argument
    @IBAction func timedClicked(sender: NSMenuItem) {
        let title = sender.title
        var time: Double? = nil
        var multiplier: Double? = nil
        var loc: Range<String.CharacterView.Index>? = nil
        
        if let range = title.rangeOfString("minutes") {
            multiplier = 60
            loc = range
        } else if let range = title.rangeOfString("hours") {
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
        if let multi = multiplier, range = loc {
            time = Double(title.substringToIndex(range.first!.predecessor()))! * multi
        }
        if let t = time {
            generateCaffeine(["-t", String(t)], dev: false)
        } else {
            errorMessage("No Time Assigned", text: "No time value was passed to caffeinate.")
        }
    }
    
    // Responds to the "Help" item by opening the Help window
    @IBAction func helpPressed(sender: NSMenuItem) {
        helpHUD.makeKeyAndOrderFront(nil)
    }
    
    // Generates an NSTask based on the arguments it is passed. If "dev" mode is not enabled (i.e., individual arguments have not been specified by the user), it will automatically add "-i" and, if the user has decided to Caffeinate their display, "-d"
    func generateCaffeine(var arguments: [String], dev: Bool) {
        if !dev {
            arguments.append("-i")
            if sleepDisplay {
                arguments.append("-d")
            }
        }
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
        dispatch_async(queue) {
            self.task = NSTask()
            self.task!.launchPath = "/usr/bin/caffeinate"
            self.task!.arguments = arguments
            self.task!.terminationHandler = self.taskDidTerminate
            self.task!.launch()
        }
        active = true
    }
    
    // Clean-up method that makes sure that the inactive state of the app is restored once caffeinate finishes running
    func taskDidTerminate(task: NSTask) {
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
    @IBAction func argumentChecked(sender: NSButton) {
        let title = sender.title
        let state = sender.state == NSOnState
        if state {
            args.append(title)
        } else {
            if let loc = args.indexOf(title) {
                args.removeAtIndex(loc)
            }
        }
        if title == "-t" {
            tButton.enabled = state
        } else if title == "-w" {
            wButton.enabled = state
        }
    }
    
    // Shows the value input dialog and uses its return value for the corresponding argument, as determined by the sender's tag. These values are stored in "twArgs" so they can easily be added/removed until confirmArguments() is called
    @IBAction func addValue(sender: NSButton) {
        let params = sender.tag == 0 ? ("-t", tLabel) : ("-w", wLabel)
        if let value = showValueDialog(params.0) {
            params.1.stringValue = value
            twArgs[params.0] = value
        }
    }
    
    // Displays a value input dialog for use in addValue(). Not to be confused with inputDialog()
    func showValueDialog(paramName: String) -> String? {
        return inputDialog("Value Input", title: "Please Enter a Value", text: "Please enter the value for the \(paramName) parameter below:")
    }
    
    // Merge twArgs into the appropriate locations (directly after the corresponding argument) in args, then call generateCaffeine() in dev mode with args
    @IBAction func confirmArguments(sender: NSButton) {
        for (name, arg) in twArgs {
            if let index = args.indexOf(name) {
                args.insert(arg, atIndex: index + 1)
            }
        }
        generateCaffeine(args, dev: true)
        argumentPanel.close()
    }
    
    // Close the argument panel
    @IBAction func cancelArguments(sender: NSButton) {
        argumentPanel.close()
    }
    
    // MARK: - Utility Alert Functions
    
    // Show a two-button text input dialog to the user and returns the String result if the user presses OK. Not to be confused with showValueDialog()
    func inputDialog(windowTitle: String, title: String, text: String) -> String? {
        let alert = NSAlert()
        alert.window.title = windowTitle
        alert.messageText = title
        alert.informativeText = text
        alert.addButtonWithTitle("OK")
        alert.addButtonWithTitle("Cancel")
        alert.alertStyle = .InformationalAlertStyle
        let input = NSTextField(frame: NSMakeRect(0, 0, 200, 24))
        alert.accessoryView = input
        let button = alert.runModal()
        if button == NSAlertFirstButtonReturn {
            return input.stringValue
        }
        return nil
    }
    
    // Shows an error message with the specified text
    func errorMessage(title: String, text: String) {
        let alert = NSAlert()
        alert.window.title = "Error"
        alert.messageText = title
        alert.informativeText = text
        alert.runModal()
    }

}


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
    
    func applicationWillTerminate(notification: NSNotification) {
        if let activeTask = task {
            activeTask.terminate()
        }
    }
    
    var active = false {
        didSet {
            startMenu.title = active ? "Stop Caffeinator" : "Start Caffeinator"
            processMenu.enabled = !active
            timedMenu.enabled = !active
            argumentMenu.enabled = !active
            statusItem.image = active ? NSImage(named: "CoffeeCupGreen") : NSImage(named: "CoffeeCup")
        }
    }

    
    func defaultsChanged() {
        sleepDisplay = df.boolForKey("CaffeinateDisplay")
    }
    
    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }
    
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
    
    @IBAction func startClicked(sender: NSMenuItem) {
        if sender.title == "Start Caffeinator" {
            generateCaffeine([], dev: false)
        } else {
            task?.terminate()
            active = false
        }
    }
    
    @IBAction func argumentClicked(sender: NSMenuItem) {
        argumentPanel.makeKeyAndOrderFront(nil)
    }
    
    @IBAction func processClicked(sender: NSMenuItem) {
        if let res = inputDialog("Caffeinate a Process", title: "Select a Process", text: "Enter the PID of the process you would like to Caffeinate. This PID can be found in the Activity Monitor application:") {
            if let text = Int(res) {
                generateCaffeine(["-w", String(text)], dev: false)
            } else {
                errorMessage("Illegal Input", text: "You must enter the PID number of the process you wish to Caffeinate.")
            }
        }
    }
    
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
            errorMessage("No Time Assigned", text: "No time value was passed to caffeimate.")
        }
    }
    
    @IBAction func helpPressed(sender: NSMenuItem) {
        helpHUD.makeKeyAndOrderFront(nil)
    }
    
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
    
    func taskDidTerminate(task: NSTask) {
        active = false
    }
    
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
    
    @IBAction func confirmArguments(sender: NSButton) {
        for (name, arg) in twArgs {
            if let index = args.indexOf(name) {
                args.insert(arg, atIndex: index + 1)
            }
        }
        generateCaffeine(args, dev: true)
        argumentPanel.close()
    }
    
    @IBAction func cancelArguments(sender: NSButton) {
        argumentPanel.close()
    }
    
    @IBAction func addValue(sender: NSButton) {
        let params = sender.tag == 0 ? ("-t", tLabel) : ("-w", wLabel)
        if let value = showValueDialog(params.0) {
            params.1.stringValue = value
            twArgs[params.0] = value
        }
    }
    
    func showValueDialog(paramName: String) -> String? {
        return inputDialog("Value Input", title: "Please Enter a Value", text: "Please enter the value for the \(paramName) parameter below:")
    }
    
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
    
    // MARK: - Utility Alert Functions
    
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
    
    func errorMessage(title: String, text: String) {
        let alert = NSAlert()
        alert.window.title = "Error"
        alert.messageText = title
        alert.informativeText = text
        alert.runModal()
    }

}


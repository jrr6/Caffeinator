
//  AppDelegate.swift
//  Caffeinator
//
//  Created by aaplmath on 11/8/15.
//  Copyright © 2017 aaplmath. All rights reserved.
//

import Cocoa

/// Convenience method for getting NSLocalizedString values
func txt(_ text: String) -> String {
    return NSLocalizedString(text, comment: "")
}

extension NSStoryboard {
    func instantiateAndShowWindow(withIDString idString: String) {
        (self.instantiateController(withIdentifier: idString) as? NSWindowController)?.showWindow(self)
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var mainMenu: NSMenu!
    
    @IBOutlet weak var startMenu: NSMenuItem!
    @IBOutlet weak var processMenu: NSMenuItem!
    @IBOutlet weak var timedMenu: NSMenuItem!
    
    @IBOutlet weak var displayToggle: NSMenuItem!
    @IBOutlet weak var promptToggle: NSMenuItem!
    @IBOutlet weak var argumentMenu: NSMenuItem!
    
    var storyboard: NSStoryboard!
    var df: UserDefaults!
    var nc: NotificationCenter!
    var updater: Updater!
    var killMan: KillallManager!
    var trapper: SignalTrapper!
    var proc: Process?
    
    // MARK: - Main Menu
    
    var statusItem: NSStatusItem! = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    
    // Add Notification Center observer to detect changes to the "display" preference, load the existing preference (or set one, true by default, if none exists), set up the menu item and windows, and check for updates
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.image = NSImage(named: "CoffeeCup")
        statusItem.button?.action = #selector(handleStatusItemClick(sender:))
        statusItem.button?.target = self
        statusItem.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        storyboard = NSStoryboard(name: "Main", bundle: nil)
        
        // Configure UserDefaults
        df = UserDefaults.standard
        nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(AppDelegate.defaultsDidChange), name: UserDefaults.didChangeNotification, object: nil)
        initDefaults()
        
        // Set up updating
        updater = Updater()
        
        // Ensure no background caffeinate processes are running
        killMan = KillallManager()
        killMan.runCaffeinateCheck()
        
        // Set up signal trapping
        trapper = SignalTrapper(withHandler: preQuitSafetyCheck)
    }
    
    /// Handles clicks on the NSStatusItem's button—shows the main menu if it's a left-click, or immediately starts Caffeinating if it's a right-click or option-click
    @objc func handleStatusItemClick(sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        if event.type == NSEvent.EventType.rightMouseUp || event.modifierFlags.contains(.option) {
            if active {
                proc?.terminate()
            } else {
                generateCaffeinate(withArgs: [], isDev: false)
            }
        } else {
            statusItem.menu = mainMenu
            statusItem.popUpMenu(mainMenu)
            statusItem.menu = nil
        }
    }
    
    /// Ensures that all UserDefaults values have been initialized and updates each preference's corresponding menu item accordingly
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
    
    /// Responds to a change to the CaffeinateDisplay default — while this is unnecessary for updates triggered by clicks in the application, menu items do need to be updated if the default is updated from the Terminal or on application launch
    @objc func defaultsDidChange() {
        RunLoop.main.perform(inModes: [RunLoop.Mode.eventTracking, RunLoop.Mode.default]) {
            self.displayToggle.state = self.df.bool(forKey: "CaffeinateDisplay") ? .on : .off
            self.promptToggle.state = self.df.bool(forKey: "PromptBeforeExecuting") ? .on : .off
        }
    }
    
    /// Ensures that the caffeinate process is quit prior to the application exiting
    func preQuitSafetyCheck() {
        if let activeProc = proc {
            activeProc.terminate()
        }
    }
    
    // Terminate caffeinate upon application termination to prevent "zombie" processes (which should be terminated anyway, but just for safety) (note that this is necessary on top of the signal trapping because "Quit" messages are sent as Apple Events, not OS signals)
    func applicationWillTerminate(_ notification: Notification) {
        preQuitSafetyCheck()
    }
    
    /// Responsible for managing the inactive/active state of the app. If there is an active "Caffeination," disable the appropriate menu items and set the icon green. Otherwise, enable all menu items and set the icon to the template
    var active = false {
        didSet {
            RunLoop.main.perform(inModes: [RunLoop.Mode.eventTracking, RunLoop.Mode.default]) {
                self.startMenu.title = self.active ? txt("AD.stop-caffeinator") : txt("AD.start-caffeinator")
                self.processMenu.isEnabled = !self.active
                if !self.active {
                    self.processMenu.title = txt("AD.process-menu-item")
                }
                self.timedMenu.isEnabled = !self.active
                self.argumentMenu.isEnabled = !self.active
                self.statusItem.image = self.active ? NSImage(named: "CoffeeCupGreen") : NSImage(named: "CoffeeCup")
            }
        }
    }

    /// Responds to clicks from toggles for UserDefaults
    @IBAction func changeDefault(_ sender: NSMenuItem) {
        let val: Bool
        if sender.state == .on {
            val = false
        } else {
            val = true
        }
        RunLoop.main.perform(inModes: [RunLoop.Mode.eventTracking, RunLoop.Mode.default]) {
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
            Notifier.showErrorMessage(withTitle: txt("AD.pref-tag-err-title"), text: txt("AD.pref-tag-err-msg"))
        }
    }
    
    /// Responds to the Quit menu item
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
    
    /// Start Caffeinate with no args, or stop it if it is active
    @IBAction func startClicked(_ sender: NSMenuItem) {
        // FIXME: Title-based comparisons—especially in a localized app—are inadvisable
        if sender.title == txt("AD.start-caffeinator") {
            generateCaffeinate(withArgs: [], isDev: false)
        } else {
            proc?.terminate()
            active = false
        }
    }
    
    /// Responds to the "Run with args" item by opening the argument panel
    @IBAction func argumentClicked(_ sender: NSMenuItem) {
        storyboard.instantiateAndShowWindow(withIDString: "argumentPanelController")
    }
    
    /// Responds to the "Caffeinate process" item by prompting entry of a PID, which is passed alongside the corresponding "-w" argument to generateCaffeine()
    @IBAction func processClicked(_ sender: NSMenuItem) {
        DispatchQueue.main.async {
            if let res = Notifier.showInputDialog(withWindowTitle: txt("AD.process-dialog-window-title"), title: txt("AD.process-dialog-title"), text: txt("AD.process-dialog-msg")) {
                if let text = Int(res) {
                    var labelName = "PID \(res)"
                    if let appName = NSRunningApplication(processIdentifier: pid_t(text))?.localizedName {
                        labelName = appName
                    }
                    RunLoop.main.perform(inModes: [RunLoop.Mode.eventTracking, RunLoop.Mode.default]) {
                        self.processMenu.title = String(format: txt("AD.caffeinating-app-label"), labelName)
                    }
                    self.generateCaffeinate(withArgs: ["-w", String(text)], isDev: false)
                } else {
                    Notifier.showErrorMessage(withTitle: txt("AD.illegal-process-title"), text: txt("AD.illegal-process-msg"))
                }
            }
        }
    }
    
    /// Responds to the "Timed Caffeination" item. If a preset is selected, the number is parsed out of the string and multiplied as necessary. If custom entry is selected, a time entry prompt is shows, followed by a confirmation of the user input's validity (generating errors as necessary). The generated time (in seconds) is passed to generateCaffeine() along with the corresponding "-t" argument
    @IBAction func timedClicked(_ sender: NSMenuItem) {
        DispatchQueue.main.async {
            let title = sender.title
            var time: Double? = nil
            var multiplier: Double? = nil
            var loc: Range<Substring.Index>? = nil
            
            // FIXME: This already-invadvisable method of checking times becomes even more dangerous with localizations
            if let range = title.range(of: txt("AD.minutes-with-space")) {
                multiplier = 60
                loc = range
            } else if let range = title.range(of: txt("AD.hours-with-space")) {
                multiplier = 3600
                loc = range
            } else {
                guard let res = Notifier.showInputDialog(withWindowTitle: txt("AD.timed-dialog-window-title"), title: txt("AD.timed-dialog-title"), text: txt("AD.timed-dialog-msg")) else {
                    // User canceled
                    return
                }
                guard let text = Double(res) else {
                    Notifier.showErrorMessage(withTitle: txt("AD.non-number-time-title"), text: txt("AD.non-number-time-msg"))
                    return
                }
                time = text * 60
            }
            if let multi = multiplier, let range = loc {
                guard let preset = Double(title[..<range.lowerBound]) else {
                    Notifier.showErrorMessage(withTitle: txt("AD.unknown-preset-title"), text: txt("AD.unknown-preset-msg"))
                    return
                }
                time = preset * multi
            }
            guard let t = time, t > 1 else {
                Notifier.showErrorMessage(withTitle: txt("AD.illegal-time-title"), text: txt("AD.illegal-time-msg"))
                return
            }
            self.generateCaffeinate(withArgs: ["-t", String(t)], isDev: false)
        }
    }
    
    /// Responds to the "Help" item by opening the Help window
    @IBAction func helpPressed(_ sender: NSMenuItem) {
        storyboard.instantiateAndShowWindow(withIDString: "helpPanelController")
    }
    
    /// Responds to the "View License Information" menu item by opening the License HUD
    @IBAction func licensePressed(_ sender: NSMenuItem) {
        storyboard.instantiateAndShowWindow(withIDString: "licensePanelController")
    }
    
    /// Generates a Process based on the arguments it is passed. If "dev" mode is not enabled (i.e., individual arguments have not been specified by the user), it will automatically add "-i" and, if the user has decided to Caffeinate their display, "-d"
    func generateCaffeinate(withArgs args: [String], isDev: Bool) {
        DispatchQueue.main.async {
            self.killMan.runCaffeinateCheck() // Make sure no other caffeinate processes are active
            var arguments = args
            if !isDev {
                arguments.append("-i")
                if self.df.bool(forKey: "CaffeinateDisplay") {
                    arguments.append("-d")
                }
            }
            if self.df.bool(forKey: "PromptBeforeExecuting") {
                let confirmed = Notifier.showConfirmationDialog(withTitle: txt("AD.execution-prompt-title"), text: String(format: txt("AD.execution-prompt-msg"), "caffeinate \(arguments.joined(separator: " "))"))
                if !confirmed {
                    // User canceled
                    self.processMenu.title = txt("AD.process-menu-item") // resets the process menu title, which will have been naïvely changed by processClicked
                    return
                }
            }
            let caffeinatePath = "/usr/bin/caffeinate"
            guard FileManager.default.fileExists(atPath: caffeinatePath) else {
                Notifier.showErrorMessage(withTitle: txt("AD.caffeinate-missing-dialog-title"), text: txt("AD.caffeinate-missing-dialog-msg"))
                return
            }
            DispatchQueue.global(qos: .background).async { // TODO: Do we need [weak self]
                () -> Void in
                self.proc = Process(caffeinatePath, withArguments: arguments)
                self.proc!.run(synchronously: false, terminationHandler: self.processDidTerminate)
            }
            self.active = true
        }
    }
    
    /// Clean-up method that makes sure that the inactive state of the app is restored once caffeinate finishes running
    func processDidTerminate(_ terminatedProc: Process) {
        active = false
        DispatchQueue.main.async {
            self.killMan.runCaffeinateCheck()
        }
    }
    
    /// Responds to user request to check for updates by calling checkForUpdate()
    @IBAction func checkForUpdatesClicked(_ sender: NSMenuItem) {
        updater.checkForUpdate(isUserInitiated: true)
    }
    
    /// Remove Notification Center observer on deinit
    deinit {
        nc.removeObserver(self)
    }
}


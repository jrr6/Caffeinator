
//  AppDelegate.swift
//  Caffeinator
//
//  Created by aaplmath on 11/8/15.
//  Copyright © 2017 aaplmath. All rights reserved.
//

import CaffeineKit
import Cocoa

/// Convenience method for getting NSLocalizedString values
func txt(_ text: String) -> String {
    return NSLocalizedString(text, comment: "")
}

extension NSStoryboard {
    func instantiateAndShowWindow(withIDString idString: String) {
        // TODO: This is hacky and relies on the ID of the window matching the storyboard ID of its view controller. Investigate better ways to go about preventing duplicate windows. (Also, since update windows do their own thing, this doesn't prevent duplicate update windows, although that's less of an issue.)
        if !NSApplication.shared.windows.contains { $0.identifier?.rawValue == idString } {
            (self.instantiateController(withIdentifier: idString) as? NSWindowController)?.showWindow(self)
        }
    }
}

extension Caffeination {
    func handledStart() {
        do {
            try self.start()
            (NSApplication.shared.delegate as! AppDelegate).updateIconForCafState(active: true)
        } catch let err {
            switch err {
            case let err as CaffeinationError:
                if err == CaffeinationError.caffeinateNotFound {
                    Notifier.showErrorMessage(withTitle: txt("AD.caffeinate-missing-dialog-title"), text: txt("AD.caffeinate-missing-dialog-msg"))
                }
                // ignore "already active" errors
            default:
                Notifier.showErrorMessage(withTitle: txt("AD.caffeinate-failure-title"), text: String(format: txt("AD.caffeinate-failure-msg"), err.localizedDescription))
            }
            self.opts = Caffeination.Opt.userDefaults
        }
    }
    
    func handledStart(withOpts opts: [Opt]) {
        self.opts = opts
        self.handledStart()
    }
}

extension Caffeination.Opt {
    static var userDefaults: [Caffeination.Opt] {
        get {
            return UserDefaults.standard.bool(forKey: "CaffeinateDisplay") ? Caffeination.Opt.defaults : [Caffeination.Opt.idle]
        }
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var mainMenu: NSMenu!
    
    @IBOutlet weak var startMenu: NSMenuItem!
    @IBOutlet weak var processMenu: NSMenuItem!
    @IBOutlet weak var timedMenu: NSMenuItem!
    @IBOutlet weak var customMenu: NSMenuItem!
    
    @IBOutlet weak var displayToggle: NSMenuItem!
    
    var storyboard: NSStoryboard!
    var df: UserDefaults!
    var nc: NotificationCenter!
    var updater: Updater!
    var killMan: KillallManager!
    var caffeination: Caffeination!
    
    // MARK: - Main Menu
    
    var statusItem: NSStatusItem! = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    
    // Add Notification Center observer to detect changes to the "display" preference, load the existing preference (or set one, true by default, if none exists), set up the menu item and windows, and check for updates
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.image = NSImage(named: "CoffeeCup")
        statusItem.button?.action = #selector(handleStatusItemClick(sender:))
        statusItem.button?.target = self
        statusItem.button?.sendAction(on: [.leftMouseDown, .rightMouseDown])
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
        caffeination = Caffeination()
        caffeination.terminationHandler = caffeinationDidFinish
    }
    
    /// Handles Caffeination termination—initiates status bar update and resets to default opts
    func caffeinationDidFinish(caf: Caffeination) {
        self.updateIconForCafState(active: false)
        DispatchQueue.main.async {
            self.killMan.runCaffeinateCheck()
        }
        caf.opts = Caffeination.Opt.userDefaults
    }
    
    /// Handles clicks on the NSStatusItem's button—shows the main menu if it's a left-click, or immediately starts Caffeinating if it's a right-click or option-click
    @objc func handleStatusItemClick(sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        if event.type == NSEvent.EventType.rightMouseDown || event.modifierFlags.contains(.option) {
            if caffeination.isActive {
                caffeination.stop()
            } else {
                caffeination.handledStart()
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
        defaultsDidChange()
    }
    
    /// Responds to a change to the CaffeinateDisplay default — while this is unnecessary for updates triggered by clicks in the application, menu items do need to be updated if the default is updated from the Terminal or on application launch
    @objc func defaultsDidChange() {
        RunLoop.main.perform(inModes: [RunLoop.Mode.eventTracking, RunLoop.Mode.default]) {
            self.displayToggle.state = self.df.bool(forKey: "CaffeinateDisplay") ? .on : .off
        }
    }
    
    // Terminate caffeinate upon application termination to prevent "zombie" processes (which should be terminated anyway, but just for safety) (note that this is necessary on top of the signal trapping because "Quit" messages are sent as Apple Events, not OS signals)
    func applicationWillTerminate(_ notification: Notification) {
        caffeination.stop()
    }
    
    // Updates the menu bar when the Caffeination stops/starts
    func updateIconForCafState(active: Bool) {
        RunLoop.main.perform(inModes: [RunLoop.Mode.eventTracking, RunLoop.Mode.default]) {
            self.startMenu.title = active ? txt("AD.stop-caffeinator") : txt("AD.start-caffeinator")
            self.startMenu.identifier = NSUserInterfaceItemIdentifier(rawValue: active ?  "stop" : "start")
            self.processMenu.isEnabled = !active
            if !active {
                self.processMenu.title = txt("AD.process-menu-item")
            }
            self.timedMenu.isEnabled = !active
            self.customMenu.isEnabled = !active
            self.statusItem.image = active ? NSImage(named: "CoffeeCupGreen") : NSImage(named: "CoffeeCup")
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
        switch sender.identifier?.rawValue {
        case "caffeinateDisplay":
            key = "CaffeinateDisplay"
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
        if sender.identifier?.rawValue == "start" {
            caffeination.handledStart()
        } else {
            caffeination.stop()
        }
    }
    
    /// Responds to the "Run with args" item by opening the argument panel
    @IBAction func customClicked(_ sender: NSMenuItem) {
        storyboard.instantiateAndShowWindow(withIDString: "argumentPanelController")
    }
    
    /// Responds to the "Caffeinate process" item by prompting entry of a PID and starting the Caffeination with the `.process` Opt
    @IBAction func processClicked(_ sender: NSMenuItem) {
        DispatchQueue.main.async {
            guard let res = Notifier.showInputDialog(withWindowTitle: txt("AD.process-dialog-window-title"), title: txt("AD.process-dialog-title"), text: txt("AD.process-dialog-msg")) else {
                return
            }
            guard let pidInt = Int32(res) else {
                Notifier.showErrorMessage(withTitle: txt("AD.illegal-process-title"), text: txt("AD.illegal-process-msg"))
                return
            }
            var labelName = "PID \(res)"
            if let appName = NSRunningApplication(processIdentifier: pidInt)?.localizedName {
                labelName = appName
            }
            RunLoop.main.perform(inModes: [RunLoop.Mode.eventTracking, RunLoop.Mode.default]) {
                self.processMenu.title = String(format: txt("AD.caffeinating-app-label"), labelName)
            }
            self.caffeination.opts.append(.process(pidInt))
            self.caffeination.handledStart()
        }
    }
    
    /// Responds to the "Timed Caffeination" item. If a preset is selected, the number is parsed out of the string and multiplied as necessary. If custom entry is selected, a time entry prompt is shows, followed by a confirmation of the user input's validity (generating errors as necessary). The generated time (in seconds) is used to start the Cafffeination with the `.timed` Opt
    @IBAction func timedClicked(_ sender: NSMenuItem) {
        DispatchQueue.main.async {
            var time: Double? = nil
            
            if let secondsPreset = sender.identifier?.rawValue, secondsPreset != "custom" {
                time = Double(secondsPreset)
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
            guard let t = time, t > 1 else {
                Notifier.showErrorMessage(withTitle: txt("AD.illegal-time-title"), text: txt("AD.illegal-time-msg"))
                return
            }
            self.caffeination.opts.append(.timed(t))
            self.caffeination.handledStart()
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
    
    /// Responds to user request to check for updates by calling checkForUpdate()
    @IBAction func checkForUpdatesClicked(_ sender: NSMenuItem) {
        updater.checkForUpdate(isUserInitiated: true)
    }
    
    /// Remove Notification Center observer on deinit
    deinit {
        nc.removeObserver(self)
    }
}


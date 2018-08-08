//
//  Updater.swift
//  Caffeinator
//
//  Created by aaplmath on 9/24/17.
//  Copyright © 2017 aaplmath. All rights reserved.
//

import Cocoa

/// Responsible for update operations
class Updater {
    var updateFrequency: Double = 60 * 60 * 24
    var resumptionDelay: Double = 60 * 60 * 24 * 3
    var updateTimer: Timer!
    
    // Runs a preliminary update check on launch, checks for a custom update interval (in days), then schedules automatic background checks
    init() {
        checkForUpdate(isUserInitiated: false)
        if !UserDefaults.standard.bool(forKey: "DisableAutoUpdate") {
            let customUpdateInterval = UserDefaults.standard.double(forKey: "AutoUpdateInterval")
            if customUpdateInterval > 0.1 { // Confirm that a custom interval is set and do a basic sanity check on it
                updateFrequency *= customUpdateInterval
            }
            
            updateTimer = Timer.scheduledTimer(withTimeInterval: updateFrequency, repeats: true) { _ in
                self.checkForUpdate(isUserInitiated: false)
            }
        } else {
            Notifier.showErrorMessage(withTitle: txt("U.auto-update-disabled-title"), text: String(format: txt("U.auto-update-disabled-msg"), "defaults write com.aaplmath.Caffeinator DisableAutoUpdate -bool NO"))
        }
    }
    
    // Queries the GitHub API to see if a new version is available. If there is a more recent version, it alerts the user and opens the file in their browser. User-initiated checks will show a "No Updates Available" alert if the latest version is installed and verbose error dialogs; automated background checks fail silently (while suboptimal, this is necessary, as we may be running the check while the computer is offline, etc.)
    func checkForUpdate(isUserInitiated: Bool) {
        let url = URL(string: "https://api.github.com/repos/aaplmath/Caffeinator/releases/latest")!
        let query = URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            guard let data = data else {
                if isUserInitiated {
                    Notifier.showErrorMessage(withTitle: txt("U.no-update-data-title"), text: txt("U.no-update-data-msg"))
                }
                return
            }
            let jsonData: [String: AnyObject]
            do {
                guard let rawData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] else {
                    if isUserInitiated {
                        Notifier.showErrorMessage(withTitle: txt("U.improper-json-title"), text: txt("U.improper-json-msg"))
                    }
                    return
                }
                jsonData = rawData
            } catch {
                if isUserInitiated {
                    Notifier.showErrorMessage(withTitle: txt("U.serializaiton-failure-title"), text: txt("U.serialization-failure-msg"))
                }
                return
            }
            guard var serverVersion = jsonData["tag_name"] as? String, let bundleVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
                if isUserInitiated {
                    Notifier.showErrorMessage(withTitle: txt("U.version-parse-failure-title"), text: txt("U.version-parse-failure-msg"))
                }
                return
            }
            serverVersion.remove(at: serverVersion.startIndex) // Remove the "v" from the tag name
            if bundleVersion.compare(serverVersion, options: .numeric) == .orderedAscending {
                guard let assets = jsonData["assets"] as? [AnyObject], let downloadURL = assets[0]["browser_download_url"] as? String else {
                    if isUserInitiated {
                        Notifier.showErrorMessage(withTitle: txt("U.download-parse-failure-title"), text: txt("U.download-parse-failure-msg"))
                    }
                    return
                }
                self.showUpdatePrompt(forVersion: serverVersion, withURLString: downloadURL)
            } else if isUserInitiated {
                DispatchQueue.main.async {
                    let alert = NSAlert()
                    alert.window.title = txt("U.caffeinator-update-title")
                    alert.messageText = txt("U.no-update-title")
                    alert.informativeText = txt("U.no-update-msg")
                    alert.alertStyle = .informational
                    alert.addButton(withTitle: txt("U.no-update-ok-text"))
                    _ = alert.runModalInFront()
                }
            }
        })
        query.resume()
    }
    
    // Displays a dialog prompting the user to update. If the user decides to update, the default browser is launched to download the DMG and the app is terminated to avoid issues when the user attempts to overwrite it; if the update is declined, swap out the update timer for one with a longer time interval (we don't want to be hounding the user to update if they don't want to right now)
    func showUpdatePrompt(forVersion version: String, withURLString urlString: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.window.title = txt("U.caffeinator-update-title")
            alert.messageText = txt("U.update-available-title")
            alert.informativeText = String(format: txt("U.update-available-msg"), version)
            alert.addButton(withTitle: txt("U.update-available-update-button"))
            alert.addButton(withTitle: txt("U.update-available-not-now-button"))
            if alert.runModalInFront() == .alertFirstButtonReturn {
                if let url = URL(string: urlString) {
                    NSWorkspace.shared.open(url)
                    NSApplication.shared.terminate(self)
                } else {
                    Notifier.showErrorMessage(withTitle: txt("U.url-open-failure-title"), text: txt("U.url-open-failure-msg"))
                }
            } else {
                self.updateTimer.invalidate()
                self.updateTimer = Timer.scheduledTimer(withTimeInterval: self.resumptionDelay, repeats: false) { _ in
                    self.checkForUpdate(isUserInitiated: false)
                }
            }
        }
    }
}
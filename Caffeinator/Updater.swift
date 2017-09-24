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
    var resumptionDelay: Double = 60 * 60 * 24 * 7
    var updateTimer: Timer!
    
    // Runs a preliminary update check on launch, then schedules automatic background checks
    init() {
        checkForUpdate(isUserInitiated: false)
        updateTimer = Timer.scheduledTimer(withTimeInterval: updateFrequency, repeats: true) { _ in
            self.checkForUpdate(isUserInitiated: false)
        }
    }
    
    // Queries the GitHub API to see if a new version is available. If there is a more recent version, it alerts the user and opens the file in their browser. User-initiated checks will show a "No Updates Available" alert if the latest version is installed and verbose error dialogs; automated background checks fail silently (while suboptimal, this is necessary, as we may be running the check while the computer is offline, etc.)
    func checkForUpdate(isUserInitiated: Bool) {
        let url = URL(string: "https://api.github.com/repos/aaplmath/Caffeinator/releases/latest")!
        let query = URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            guard let data = data else {
                if isUserInitiated {
                    Notifier.showErrorMessage(withTitle: "No Update Data Received", text: "The GitHub API returned no data. This error should be reported.")
                }
                return
            }
            let jsonData: [String: AnyObject]
            do {
                guard let rawData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] else {
                    if isUserInitiated {
                        Notifier.showErrorMessage(withTitle: "Improperly Formatted JSON", text: "The JSON data returned by the update server was not in the correct format. This error should be reported.")
                    }
                    return
                }
                jsonData = rawData
            } catch {
                if isUserInitiated {
                    Notifier.showErrorMessage(withTitle: "Could Not Serialize Update Data", text: "The data returned by the GitHub API was not in a valid JSON format, or JSONSerialization failed internally. This error should be reported.")
                }
                return
            }
            guard var serverVersion = jsonData["tag_name"] as? String, let bundleVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
                if isUserInitiated {
                    Notifier.showErrorMessage(withTitle: "Failed to Parse Update Information", text: "The data necessary for checking the latest version of Caffeinator could not be found. This error should be reported.")
                }
                return
            }
            serverVersion.remove(at: serverVersion.characters.startIndex) // Remove the "v" from the tag name
            if bundleVersion.compare(serverVersion, options: .numeric) == .orderedAscending {
                guard let assets = jsonData["assets"] as? [AnyObject], let downloadURL = assets[0]["browser_download_url"] as? String else {
                    if isUserInitiated {
                        Notifier.showErrorMessage(withTitle: "Failed to Parse Download Information", text: "While update version data was able to be parsed, download asset data could not. This error should be reported.")
                    }
                    return
                }
                self.showUpdatePrompt(forVersion: serverVersion, withURLString: downloadURL)
            } else if isUserInitiated {
                DispatchQueue.main.async {
                    let alert = NSAlert()
                    alert.window.title = "Caffeinator Update"
                    alert.messageText = "No Updates Available"
                    alert.informativeText = "You're running the latest version of Caffeinator."
                    alert.alertStyle = .informational
                    alert.addButton(withTitle: "OK")
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
            alert.window.title = "Caffeinator Update"
            alert.messageText = "Update Available"
            alert.informativeText = "A new version of Caffeinator (\(version)) is available. Would you like to download it now?\n\nIf you choose to update, the Caffeinator installer will be downloaded to your Downloads folder. Simply open the installer and drag Caffeinator to your Applications folder, then right-click on the installed app and click \"Open.\""
            alert.addButton(withTitle: "Update")
            alert.addButton(withTitle: "Not Now")
            if alert.runModalInFront() == .alertFirstButtonReturn {
                if let url = URL(string: urlString) {
                    NSWorkspace.shared.open(url)
                    NSApplication.shared.terminate(self)
                } else {
                    Notifier.showErrorMessage(withTitle: "Error Opening URL", text: "Could not open the URL for the update download. You can manually download the update by going to https://aaplmath.github.io/Caffeinator and clicking the Download button. This error should be reported.")
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

//
//  Updater.swift
//  Caffeinator
//
//  Created by aaplmath on 9/24/17.
//  Copyright © 2017 aaplmath. All rights reserved.
//

import Cocoa

class Updater {
    // Queries the GitHub API to see if a new version is available. If there is a more recent version, it alerts the user and opens the file in their browser.
    func checkForUpdate(isUserInitiated: Bool) {
        let url = URL(string: "https://api.github.com/repos/aaplmath/Caffeinator/releases/latest")!
        let query = URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            guard let data = data else {
                Notifier.showErrorMessage(withTitle: "No Update Data Received", text: "The GitHub API returned no data. This error should be reported.")
                return
            }
            let jsonData: [String: AnyObject]
            do {
                guard let rawData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] else {
                    Notifier.showErrorMessage(withTitle: "Improperly Formatted JSON", text: "The JSON data returned by the update server was not in the correct format. This error should be reported.")
                    return
                }
                jsonData = rawData
            } catch {
                Notifier.showErrorMessage(withTitle: "Could Not Serialize Update Data", text: "The data returned by the GitHub API was not in a valid JSON format, or JSONSerialization failed internally. This error should be reported.")
                return
            }
            guard var serverVersion = jsonData["tag_name"] as? String, let bundleVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
                Notifier.showErrorMessage(withTitle: "Failed to Parse Update Information", text: "The data necessary for checking the latest version of Caffeinator could not be found. This error should be reported.")
                return
            }
            serverVersion.remove(at: serverVersion.characters.startIndex) // Remove the "v" from the tag name
            if bundleVersion.compare(serverVersion, options: .numeric) == .orderedAscending {
                guard let assets = jsonData["assets"] as? [AnyObject], let downloadURL = assets[0]["browser_download_url"] as? String else {
                    Notifier.showErrorMessage(withTitle: "Failed to Parse Download Information", text: "While update version data was able to be parsed, download asset data could not. This error should be reported.")
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
    
    func showUpdatePrompt(forVersion version: String, withURLString urlString: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.window.title = "Caffeinator Update"
            alert.messageText = "Update Available"
            alert.informativeText = "A new version of Caffeinator (\(version)) is available. Would you like to download it now?"
            alert.addButton(withTitle: "Update")
            alert.addButton(withTitle: "Not Now")
            if alert.runModalInFront() == .alertFirstButtonReturn {
                if let url = URL(string: urlString) {
                    NSWorkspace.shared.open(url)
                } else {
                    Notifier.showErrorMessage(withTitle: "Error Opening URL", text: "Could not open the URL for the update download. You can manually download the update by going to https://aaplmath.github.io/Caffeinator and clicking the Download button. This error should be reported.")
                }
            }
        }
    }
}

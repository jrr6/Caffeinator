//
//  KillallManager.swift
//  Caffeinator
//
//  Created by aaplmath on 8/7/18.
//  Copyright © 2018 aaplmath. All rights reserved.
//

import Foundation

class KillallManager {
    /// An enum representing the different states in which `killall` can exit
    enum KillallTerminationState {
        case Success, ProcessNotFound, UnknownError
    }
    
    /// Error type for unexpected `killall` exit statuses
    enum KillallError: Error {
        case UnknownExecutionError, NoProcessFoundError
    }
    
    static let shared = KillallManager()
    
    private init() {}
    
    /// Runs a check on background caffeinate processes and deals with user interaction
    func runCaffeinateCheck() {
        do {
            if try caffeinateProcessFound() {
                let doKill = Notifier.showConfirmationDialog(withTitle: txt("KM.kill-caffeinate-prompt-title"), text: txt("KM.kill-caffeinate-prompt-msg"))
                if doKill {
                    try killBackgroundCaffeinate()
                }
            }
        } catch let err as KillallError {
            if err == .NoProcessFoundError {
                Notifier.showErrorMessage(withTitle: txt("KM.no-caffeinate-process-title"), text: txt("KM.no-caffeinate-process-msg"))
            } else {
                Notifier.showErrorMessage(withTitle: txt("KM.unknown-killall-error-title"), text: txt("KM.unknown-killall-error-msg"))
            }
        } catch {} // The error will always be of type KillallError
    }
    
    /// Checks if a `caffeinate` process is currently running on the system.
    func caffeinateProcessFound() throws -> Bool {
        let state = killallCaffeinate(asDryRun: true)
        guard state != .UnknownError else {
            throw KillallError.UnknownExecutionError
        }
        return state == .Success
    }
    
    /// Kills a background `caffeinate` process
    func killBackgroundCaffeinate() throws {
        let state = killallCaffeinate(asDryRun: false)
        if state != .Success {
            throw state == .ProcessNotFound ? KillallError.NoProcessFoundError : KillallError.UnknownExecutionError
        }
    }

    /**
     Executes `killall` on the `caffeinate` process.
     - Important: This launches the `killall` subprocess in a synchronous manner. It should, therefore, not be called on the main queue.
     - Parameter asDryRun: Indicates whether the `-0` flag should be passed (can be used to check if a `caffeinate` process is active).
     - Returns: The termination state of the `killall` process in the form of an enum value.
    */
    private func killallCaffeinate(asDryRun: Bool) -> KillallTerminationState {
        let proc = Process("/usr/bin/killall", "caffeinate")
        if asDryRun {
            proc.arguments!.append("-0") // there's already an argument, so force unwrap is okay
        }
        proc.run(synchronously: true, terminationHandler: nil)
        let status = proc.terminationStatus
        if status == 0 {
            return .Success
        } else if status == 1 {
            return .ProcessNotFound
        }
        return .UnknownError
    }
}

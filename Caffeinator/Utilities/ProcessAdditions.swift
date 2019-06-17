//
//  ProcessAdditions.swift
//  Caffeinator
//
//  Created by aaplmath on 8/8/18.
//  Copyright © 2018 aaplmath. All rights reserved.
//

import Foundation

extension Process {
    convenience init(_ executablePath: String, _ arguments: String...) {
        self.init()
        self.launchPath = executablePath
        self.arguments = arguments
        self.standardOutput = FileHandle.nullDevice
        self.standardError = FileHandle.nullDevice
    }
    
    convenience init(_ executablePath: String, withArguments arguments: [String]) {
        self.init()
        self.launchPath = executablePath
        self.arguments = arguments
        self.standardOutput = FileHandle.nullDevice
        self.standardError = FileHandle.nullDevice
    }
    
    func run(synchronously: Bool, terminationHandler: ((Process) -> Void)?) {
        if let handler = terminationHandler {
            self.terminationHandler = handler
        }
        if #available(macOS 10.13, *) {
            do {
                try self.run()
            } catch let err {
                Notifier.showErrorMessage(withTitle: txt("PA.execution-error-title"), text: String(format: txt("PA.execution-error-msg"), launchPath ?? "PA.unknown-process-path", err.localizedDescription))
            }
        } else {
            self.launch()
        }
        if synchronously {
            self.waitUntilExit()
        }
    }
}

//
//  ProcessAdditions.swift
//  Caffeinator
//
//  Created by aaplmath on 8/8/18.
//  Copyright © 2018 aaplmath. All rights reserved.
//

import Foundation

/// Gets the name of a process by its PID using libproc
func getLibProcName(for pid: pid_t) -> String? {
    if pid == 0 {
        return "kernel_task"
    }
    let nameBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(MAXPATHLEN))
    defer {
        nameBuffer.deallocate()
    }
    let nameLength = proc_name(pid, nameBuffer, UInt32(MAXPATHLEN))
    if nameLength > 0 {
        return String(cString: nameBuffer)
    } else {
        return nil
    }
}

/// Gets the last component of the path of a process by its PID using libproc
func getLibProcPathEnd(for pid: pid_t) -> String? {
    let pathBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(MAXPATHLEN))
    defer {
        pathBuffer.deallocate()
    }
    let pathLength = proc_pidpath(pid, pathBuffer, UInt32(MAXPATHLEN))
    if pathLength > 0 {
        let fullPath = String(cString: pathBuffer)
        let sliceStart: String.Index
        if let lastSeparatorLoc = fullPath.lastIndex(of: "/"), lastSeparatorLoc < fullPath.index(before: fullPath.endIndex) {
            sliceStart = fullPath.index(after: lastSeparatorLoc)
        } else {
            sliceStart = fullPath.startIndex
        }
        let lastComponent = fullPath[sliceStart...]
        return String(lastComponent)
    } else {
        return nil
    }
}

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

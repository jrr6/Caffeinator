//
//  ScriptingCaffeination.swift
//  Caffeinator
//
//  Created by aaplmath on 7/25/20.
//  Copyright © 2020 aaplmath. All rights reserved.
//

import Cocoa

@objcMembers class ScriptingCaffeination: NSObject {
    static let shared = ScriptingCaffeination()
    
    override private init() {}
    
    override var objectSpecifier: NSScriptObjectSpecifier {
        let appDescription = NSApplication.shared.classDescription as! NSScriptClassDescription
        
        print(appDescription)
        let specifier = NSPropertySpecifier(containerClassDescription: appDescription, containerSpecifier: nil, key: "caffeination")
        return specifier
    }
    
    var lifetimeLimited: Bool {
        get {
            return (NSApplication.shared.delegate as! AppDelegate).caffeination.limitLifetime
        }
    }
    
    var active: Bool {
        get {
            return (NSApplication.shared.delegate as! AppDelegate).caffeination.isActive
        }
    }
    
    var options: [String] {
        get {
            return (NSApplication.shared.delegate as! AppDelegate).caffeination.opts.map { String(describing: $0) }
        }
    }
}

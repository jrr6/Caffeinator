//
//  SignalTrapper.swift
//  Caffeinator
//
//  Created by aaplmath on 8/8/18.
//  Copyright © 2018 aaplmath. All rights reserved.
//

import Cocoa

class SignalTrapper {
    // TODO: This is hacky—investigate other ways of circumventing lack of context in C closures
    static var handler: () -> Void = {}
    
    init(withHandler userHandler: @escaping () -> Void) {
        SignalTrapper.handler = {
            userHandler()
            NSApplication.shared.terminate(self)
        }
        
        signal(SIGHUP) { signal in
            SignalTrapper.handler()
        }
        signal(SIGINT) { signal in
            SignalTrapper.handler()
        }
        signal(SIGQUIT) { signal in
            SignalTrapper.handler()
        }
        signal(SIGABRT) { signal in
            SignalTrapper.handler()
        }
        signal(SIGTERM) { signal in
            SignalTrapper.handler()
        }
    }
}

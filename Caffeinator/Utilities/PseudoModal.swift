//
//  PseudoModal.swift
//  Caffeinator
//
//  Created by aaplmath on 6/17/19.
//  Copyright © 2019 aaplmath. All rights reserved.
//

import Cocoa

/// Represents a view controller that functions modally but is encapsulated in a standard window
protocol PseudoModal {
    var properties: [String: Any] { get set }
    var onConfirm: (Any?) -> Void { get set }
    var onCancel: () -> Void { get set }
}

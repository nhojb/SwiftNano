//
//  Nano.swift
//  ColorFinale
//
//  Created by John on 29/07/2016.
//  Copyright © 2016 Formal Technology. All rights reserved.
//

import Foundation

var nvgCreateGL : (Int32) -> COpaquePointer = { (flags: Int32) -> COpaquePointer in
    let result : COpaquePointer = nil // necessary only to ensure closure has correct 'type'.
    // Otherwise the closure is interpreted as the 'fatalError' closure alone.
    fatalError("Nano.initialize not called")
}

var nvgDeleteGL : (COpaquePointer) -> Void = { (context: COpaquePointer) -> Void in
    fatalError("Nano.initialize not called")
}

public func initialize(createContext create: (Int32) -> COpaquePointer, deleteContext delete: (COpaquePointer) -> Void) {
    Nano.nvgCreateGL = create
    Nano.nvgDeleteGL = delete
}

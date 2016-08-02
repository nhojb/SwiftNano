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

public enum HorizontalAlignment {
    case left
    case center
    case right
}

public enum VerticalAlignment {
    case top
    case middle
    case bottom
    case baseline
}

public struct TextAlignment {
    public var horizontal : HorizontalAlignment
    public var vertical : VerticalAlignment

    public init(horizontal: HorizontalAlignment, vertical: VerticalAlignment) {
        self.horizontal = horizontal
        self.vertical = vertical
    }

    public init(horizontal: HorizontalAlignment) {
        self.horizontal = horizontal
        self.vertical = .middle
    }

    public init() {
        self.horizontal = .left
        self.vertical = .middle
    }
}

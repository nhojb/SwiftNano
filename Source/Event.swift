//
//  Event.swift
//  Nano
//
//  Created by John on 14/06/2016.
//  Copyright © 2016 Formal Technology. All rights reserved.
//

import Foundation

public enum EventType {
    case leftMouseDown
    case leftMouseUp
    case rightMouseDown
    case rightMouseUp
    case mouseMoved
    case leftMouseDragged
    case rightMouseDragged
    case mouseEntered
    case mouseExited
    case keyDown
    case keyUp
    case runLoop
}

public struct ModifierFlags : OptionSetType {
    public let rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    static public let AlphaShiftKeyMask = ModifierFlags(rawValue: 1 << 16)
    static public let ShiftKeyMask = ModifierFlags(rawValue: 1 << 17)
    static public let ControlKeyMask = ModifierFlags(rawValue: 1 << 18)
    static public let AlternateKeyMask = ModifierFlags(rawValue: 1 << 19)
    static public let CommandKeyMask = ModifierFlags(rawValue: 1 << 20)
    static public let NumericPadKeyMask = ModifierFlags(rawValue: 1 << 21)
    static public let HelpKeyMask = ModifierFlags(rawValue: 1 << 22)
    static public let FunctionKeyMask = ModifierFlags(rawValue: 1 << 23)
}

public struct Event {
    public let timestamp : Double
    public let type : EventType
    public let modifierFlags : ModifierFlags
    public let window : Window?
    public let locationInWindow : CGPoint?
    public let keyCode : UInt16?
    public internal(set) var cancelled = false

    public init(timestamp: Double, type: EventType, modifierFlags: ModifierFlags, window: Window?, locationInWindow: CGPoint?, keyCode: UInt16?) {
        self.timestamp = timestamp
        self.type = type
        self.modifierFlags = modifierFlags
        self.window = window
        self.locationInWindow = locationInWindow
        self.keyCode = keyCode
    }

    public mutating func cancel() {
        cancelled = true
    }
}

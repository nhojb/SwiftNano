//
//  ScreenMac.swift
//  Nano
//
//  Created by John on 26/07/2016.
//  Copyright © 2016 Formal Technology. All rights reserved.
//

import Foundation
import AppKit

public extension Screen {

    static private let nsEventTypeMap : [NSEventType: EventType] = [.LeftMouseDown: .leftMouseDown,
                                                                    .LeftMouseUp: .leftMouseUp,
                                                                    .RightMouseDown: .rightMouseDown,
                                                                    .RightMouseUp: .rightMouseUp,
                                                                    .MouseMoved: .mouseMoved,
                                                                    .LeftMouseDragged: .leftMouseDragged,
                                                                    .RightMouseDragged: .rightMouseDragged,
                                                                    .MouseEntered: .mouseEntered,
                                                                    .MouseExited: .mouseExited,
                                                                    .KeyDown: .keyDown,
                                                                    .KeyUp: .keyUp]

    static private let nsEventModifierFlagsMap : [UInt: ModifierFlags] = [NSEventModifierFlags.AlphaShiftKeyMask.rawValue: .AlphaShiftKeyMask,
                                                                          NSEventModifierFlags.ShiftKeyMask.rawValue: .ShiftKeyMask,
                                                                          NSEventModifierFlags.ControlKeyMask.rawValue: .ControlKeyMask,
                                                                          NSEventModifierFlags.AlternateKeyMask.rawValue: .AlternateKeyMask,
                                                                          NSEventModifierFlags.CommandKeyMask.rawValue: .CommandKeyMask,
                                                                          NSEventModifierFlags.NumericPadKeyMask.rawValue: .NumericPadKeyMask,
                                                                          NSEventModifierFlags.HelpKeyMask.rawValue: .HelpKeyMask,
                                                                          NSEventModifierFlags.FunctionKeyMask.rawValue: .FunctionKeyMask]

    public func process(nsEvent event: NSEvent, location: CGPoint) {
        guard let nanoType = Screen.nsEventTypeMap[event.type] else {
            fatalError("Invalid NSEventType")
        }

        let nanoModifierFlags = self.convertNSEventModifierFlags(event.modifierFlags)

        // Find the window:
        var window : Window?
        var locationInWindow : CGPoint?
        var keyCode : UInt16?

        switch event.type {
            // Keyboard event -> keyWindow
            case .KeyDown, .KeyUp:
                window = self.keyWindow
                keyCode = event.keyCode

            case .LeftMouseDragged, .RightMouseDragged, .LeftMouseUp, .RightMouseUp:
                // TODO: Take into consideration the lastMouseDownTarget for "Dragged" and "Up" events which "capture" the mouse
                if let target = self.lastMouseDownTarget {
                    if let w = target.window {
                        window = w
                        locationInWindow = location - w.frame.origin
                    }
                }

            // All other events go to window under cursor
            default:
                for w in self.windows {
                    if w.frame.contains(location) {
                        window = w
                        locationInWindow = location - w.frame.origin
                        break
                    }
                }
        }

        let nanoEvent = Event(timestamp:event.timestamp,
                                  type:nanoType,
                                  modifierFlags:nanoModifierFlags,
                                  window:window,
                                  locationInWindow:locationInWindow,
                                  keyCode:keyCode)

        self.process(event:nanoEvent)
    }

    private func convertNSEventModifierFlags(modifierFlags : NSEventModifierFlags) -> ModifierFlags {

        var nanoModifierFlags = ModifierFlags(rawValue:0)

        for (nsRawValue, nanoFlag) in Screen.nsEventModifierFlagsMap {
            let flag = NSEventModifierFlags(rawValue:nsRawValue)
            if modifierFlags.contains(flag) {
                nanoModifierFlags.insert(nanoFlag)
            }
        }

        return nanoModifierFlags
    }
}

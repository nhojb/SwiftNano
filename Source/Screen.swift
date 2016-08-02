//
//  Screen.swift
//  Nano
//
//  Created by John on 15/06/2016.
//  Copyright © 2016 Formal Technology. All rights reserved.
//

import Foundation

public protocol ScreenDelegate : class {
    // Delegate methods required for OS level cursor updates
    func nanoScreenUpdate(cursorStyle cursorStyle: CursorStyle)
}

public class Screen {

    internal private(set) var context : Context

    internal private(set) var windows = [Window]()

    internal private(set) var keyWindow : Window?

    public weak var delegate : ScreenDelegate?

    public var size = CGSize() {
        didSet {
            self.setNeeds(layout:true, display:true)
        }
    }

    // Natural scale factor associated with this screen.
    public var scale : CGFloat = 1.0 {
        didSet {
            self.setNeeds(layout:true, display:true)
        }
    }

    public init() {
        print("Screen::init")
        if let context = Context(options: [.Antialias, .StencilStrokes, .Debug]) {
            self.context = context
        }
        else {
            fatalError("Failed to initialize Context")
        }
    }

    public func add(window w: Window) {
        print("Screen::add:", w)
        if !self.windows.contains(w) {
            self.windows.append(w)
        }
    }

    public func remove(window w: Window) {
        if let idx = self.windows.indexOf(w) {
            self.windows.removeAtIndex(idx)
        }
    }

    public func makeKey(window w: Window) {
        keyWindow = w
    }

    // The mouse down target captures future mouseUp and mouseDragged events.
    // The target is set to nil after receiving a mouseUp event.
    internal weak var lastMouseDownTarget : View?

    internal weak var lastMouseMoveTarget : View?

    public func process(event event: Event) {
        // debugPrint("process: ", event.type)
        // debugPrint("lastMouseDownTarget:", lastMouseDownTarget)

        switch event.type {
        case .runLoop:
            self.layoutIfNeeded()
            self.draw()

        case .leftMouseDown:
            if let window = event.window {
                let locationInScreen = event.locationInWindow! + window.frame.origin
                lastMouseDownTarget = window.hitTest(pointInSuperview:locationInScreen)
                window.mouseDown(event)
            }

        case .rightMouseDown:
            if let window = event.window {
                let locationInScreen = event.locationInWindow! + window.frame.origin
                lastMouseDownTarget = window.hitTest(pointInSuperview:locationInScreen)
                window.mouseDown(event)
            }

        case .leftMouseUp:
            if let target = self.lastMouseDownTarget {
                self.lastMouseDownTarget = nil
                target.mouseUp(event)
            }

        case .rightMouseUp:
            if let target = self.lastMouseDownTarget {
                self.lastMouseDownTarget = nil
                target.mouseUp(event)
            }

        case .leftMouseDragged:
            if let target = self.lastMouseDownTarget {
                target.mouseDragged(event)
            }

        case .rightMouseDragged:
            if let target = self.lastMouseDownTarget {
                target.mouseDragged(event)
            }

        case .mouseMoved:
            // Check target and notify of move/enter/exit events
            var target : View?
            if let window = event.window {
                let locationInScreen = event.locationInWindow! + window.frame.origin
                target = window.hitTest(pointInSuperview:locationInScreen)
            }

            if self.lastMouseMoveTarget == target {
                target?.mouseMoved(event)
            }
            else {
                self.lastMouseMoveTarget?.mouseExited(event)

                self.delegate?.nanoScreenUpdate(cursorStyle: CursorStyle.arrow)

                self.lastMouseMoveTarget = target
                target?.mouseEntered(event)

                // Update cursor
                if let cursor = target?.cursorStyle {
                    self.delegate?.nanoScreenUpdate(cursorStyle: cursor)
                }
            }

        case .mouseEntered, .mouseExited:
            self.delegate?.nanoScreenUpdate(cursorStyle:CursorStyle.arrow)
            self.lastMouseMoveTarget = nil
            break

        case .keyDown:
            event.window?.keyDown(event)

        case .keyUp:
            event.window?.keyUp(event)
        }
    }

    public func draw() {
        print("Screen::draw")
        print("size:", self.size)

        self.context.beginFrame(width:self.size.width, height:self.size.height, scale:self.scale)

        for window in self.windows {
            window.draw(context: self.context)
        }

        // self.context.beginPath()
        // self.context.addRect(CGRect(x:10.0, y:10.0, width:self.size.width - 20.0, height:self.size.height - 20.0))
        // self.context.fill(withColor: Color.white)

        self.context.endFrame()
    }

    public func layoutIfNeeded() {
        print("Screen::layoutIfNeeded")

        for window in self.windows {
            // TODO:
            // 1. Mouse events (move windows, interact with controls etc)
            //
            // 2. Layout - either via
            // a) "Layout" classes
            // b) NSView style layout (autoresizingMask)
            // c) Constraints based layout (prob. too difficult, also harder to specify via code)
            //
            // a) May be the quickest option, reusing logic from nanogui?

            if window.needsLayout {
                window.layoutSubviews()
            }
        }
    }

    func setNeeds(layout l: Bool, display d: Bool) {
        for window in windows {
            if l {
                window.needsLayout = true
            }
            if d {
                window.needsDisplay = true
            }
        }
    }

    public var needsDisplay : Bool {
        for window in self.windows {
            if window.needsDisplayRecursive {
                return true
            }
        }
        return false
    }
}

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
    func nanoScreen(updateCursorStyle cursorStyle: CursorStyle)
}

public class Screen {

    public private(set) var context : Context

    public private(set) var windows = [Window]()

    public private(set) var keyWindow : Window?

    public weak var delegate : ScreenDelegate?

    public var size = CGSize() {
        didSet {
            self.setNeeds(layout:false, display:true)
        }
    }

    // Natural scale factor associated with this screen.
    public var scale : CGFloat = 1.0 {
        didSet {
            self.setNeeds(layout:true, display:true)
        }
    }

    public init(contextOptions: ContextOptions = [.Antialias, .StencilStrokes]) {
        print("Screen::init")
        var options = contextOptions
        options.insert(.StencilStrokes) // required

        if let context = Context(options: options) {
            self.context = context

            if options.contains(.Debug) {
                View.debugDrawing = true
            }
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
        self.remove(window:w)
        self.windows.append(w)
        self.setNeeds(layout:false, display:true)
    }

    // The mouse down target permits us to capture mouseDragged events until mouseUp.
    // The target is set to nil after receiving a mouseUp event.
    weak var lastMouseDownTarget : View?

    weak var lastMouseMoveTarget : View?

    public func process(event event: Event) {
        //print("process: ", event.type)

        switch event.type {
            case .leftMouseDown, .rightMouseDown:
                if let window = event.window {
                    if window != self.keyWindow {
                        self.makeKey(window:window)
                    }
                    let locationInScreen = event.locationInWindow! + window.frame.origin
                    self.lastMouseDownTarget = window.hitTest(pointInSuperview:locationInScreen)
                    if let target = self.lastMouseDownTarget {
                        window.make(firstResponder:target)
                        target.mouseDown(event)
                        if event.cancelled {
                            self.lastMouseDownTarget = nil
                        }
                        window.layoutIfNeeded()
                        // TODO: May also need to force a draw here (unless system does it for us)
                    }
                }

            case .leftMouseDragged, .rightMouseDragged:
                if let target = self.lastMouseDownTarget {
                    target.mouseDragged(event)
                    target.window?.layoutIfNeeded()
                }

            case .leftMouseUp, .rightMouseUp:
                if let target = self.lastMouseDownTarget {
                    self.lastMouseDownTarget = nil
                    target.mouseUp(event)
                    target.window?.layoutIfNeeded()
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

                    self.delegate?.nanoScreen(updateCursorStyle: CursorStyle.arrow)

                    self.lastMouseMoveTarget = target
                    target?.mouseEntered(event)

                    // Update cursor
                    if let cursor = target?.cursorStyle {
                        self.delegate?.nanoScreen(updateCursorStyle: cursor)
                    }
                }

            case .mouseEntered, .mouseExited:
                // Screen enter/exit events from the system.
                self.delegate?.nanoScreen(updateCursorStyle:CursorStyle.arrow)
                self.lastMouseMoveTarget = nil
                break

            case .keyDown:
                if let keyWindow = self.keyWindow {
                    keyWindow.firstResponder?.keyDown(event)
                    keyWindow.layoutIfNeeded()
                }

            case .keyUp:
                if let keyWindow = self.keyWindow {
                    keyWindow.firstResponder?.keyUp(event)
                    keyWindow.layoutIfNeeded()
                }
        }
    }

    public func draw() {
        print("Screen::draw")
        self.context.beginFrame(width:self.size.width, height:self.size.height, scale:self.scale)

        for window in self.windows {
            window.draw(context: self.context)
        }

        self.context.endFrame()
    }

    public func layoutIfNeeded() {
        //print("Screen::layoutIfNeeded")

        for window in self.windows {
            window.layoutIfNeeded()
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

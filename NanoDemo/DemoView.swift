//
//  DemoView.swift
//  NanoDemo
//
//  Created by John on 21/06/2016.
//  Copyright © 2016 Formal Technology. All rights reserved.
//

import Cocoa
import Nano

class DemoView : NSOpenGLView, Nano.ScreenDelegate {

    var nanoWindow : Nano.Window?
    var nanoScreen : Nano.Screen?

    var backgroundColor = Nano.Color(red:0.3, green:0.3, blue:0.32, alpha:1.0)

    override init(frame: NSRect) {
        super.init(frame:frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder:coder)
    }

    override var flipped : Bool {
        // origin in top-left (for SwiftNano)
        return true
    }

    override func prepareOpenGL() {
        super.prepareOpenGL()

        Nano.initialize(createContext:nvgCreateGL2, deleteContext:nvgDeleteGL2)

        Nano.View.debugDrawing = true

        self.nanoScreen = Nano.Screen()
        self.nanoScreen!.delegate = self
        self.nanoScreen!.size = self.bounds.size

        if let scale = NSScreen.mainScreen()?.backingScaleFactor {
            self.nanoScreen!.scale = scale
        }

        self.nanoWindow = Nano.Window(screen:self.nanoScreen!, flags:[Nano.WindowFlags.TitleBar, Nano.WindowFlags.Resizable])
        self.nanoWindow!.frame = CGRect(origin:CGPoint(), size:CGSize(width:200.0, height:self.bounds.size.height - 20.0))

        self.nanoWindow!.title = "Window"
        self.nanoWindow!.makeKey()

        // Add a label:
        let label = Nano.Label(text:"Label")
        label.textColor = Nano.Color.white
        label.shadowColor = Nano.Color(red:1.0, green:0.0, blue:0.0)
        label.shadowOffset = CGSize(width:1.0, height:1.0)

        self.nanoWindow!.add(subview:label)
        label.frame = CGRect(x:10.0, y:50.0, width:100.0, height:20.0)
        //label.sizeToFit()
    }

    override var frame : NSRect {
        didSet {
            //debugPrint("didSet frame:", frame)
            if let nanoScreen = self.nanoScreen {
                nanoScreen.size = frame.size
            }
        }
    }

    override var bounds : NSRect {
        didSet {
            //debugPrint("didSet bounds:", bounds)

            if let nanoScreen = self.nanoScreen {
                nanoScreen.size = bounds.size
            }
        }
    }

    override func reshape() {
        //debugPrint("DemoView::reshape")
        super.reshape()

        if let nanoScreen = self.nanoScreen {
            nanoScreen.layoutIfNeeded()
        }
    }

    override func drawRect(rect : NSRect) {
        super.drawRect(rect)

        guard let nanoScreen = self.nanoScreen else {
            return
        }

        guard let openGLContext = self.openGLContext else {
            return
        }

        // Set background color
        glClearColor(self.backgroundColor.red, self.backgroundColor.green, self.backgroundColor.blue, self.backgroundColor.alpha)

        // Clear various GL bits (GL_STENCIL_BUFFER_BIT for nanovg)
        glClear(UInt32(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT))

        nanoScreen.draw()

        // Flush is required to actually flush the drawing cmds to OpenGL
        CGLFlushDrawable(openGLContext.CGLContextObj)
    }

    // Events
    func processEvent(event: NSEvent) {
        let location = self.convertPoint(event.locationInWindow, fromView:nil)

        if let nanoScreen = self.nanoScreen {
            nanoScreen.process(nsEvent: event, location:location)
            self.needsDisplay = nanoScreen.needsDisplay
        }
    }

    override func mouseDown(event: NSEvent) {
        super.mouseDown(event)
        self.processEvent(event)
    }

    override func mouseDragged(event: NSEvent) {
        super.mouseDragged(event)
        self.processEvent(event)
    }

    override func mouseUp(event: NSEvent) {
        super.mouseUp(event)
        self.processEvent(event)
    }

    override func mouseMoved(event: NSEvent) {
        super.mouseMoved(event)
        self.processEvent(event)
    }

    override func mouseEntered(event: NSEvent) {
        super.mouseEntered(event)
        self.processEvent(event)
    }

    override func mouseExited(event: NSEvent) {
        super.mouseExited(event)
        self.processEvent(event)
    }

    override func rightMouseDown(event: NSEvent) {
        super.rightMouseDown(event)
        self.processEvent(event)
    }

    override func rightMouseDragged(event: NSEvent) {
        super.rightMouseDragged(event)
        self.processEvent(event)
    }

    override func rightMouseUp(event: NSEvent) {
        super.rightMouseUp(event)
        self.processEvent(event)
    }

    override func keyDown(event: NSEvent) {
        super.keyDown(event)
        self.processEvent(event)
    }

    override func keyUp(event: NSEvent) {
        super.keyUp(event)
        self.processEvent(event)
    }

    // Tracking area - to support mouse move events
    override func updateTrackingAreas() {
        super.updateTrackingAreas()

        // Remove old areas
        for ta in self.trackingAreas {
            self.removeTrackingArea(ta)
        }

        // Build a new mouse move/enter/exit area for the entire view.
        let ta = NSTrackingArea(rect: self.bounds,
                                options: [NSTrackingAreaOptions.MouseMoved, NSTrackingAreaOptions.MouseEnteredAndExited, NSTrackingAreaOptions.ActiveInKeyWindow],
                                owner: self,
                                userInfo: nil)

        self.addTrackingArea(ta)
    }

    // Nano.ScreenDelegate
    func nanoScreen(updateCursorStyle style: Nano.CursorStyle) {
        switch style {
            case .ibeam:
                NSCursor.IBeamCursor().set()

            case .resizeLeft:
                NSCursor.resizeLeftCursor().set()

            case .resizeRight:
                NSCursor.resizeRightCursor().set()

            case .resizeUp:
                NSCursor.resizeUpCursor().set()

            case .resizeDown:
                NSCursor.resizeDownCursor().set()

            case .resizeLeftRight:
                NSCursor.resizeLeftRightCursor().set()

            case .resizeUpDown:
                NSCursor.resizeUpDownCursor().set()

            default:
                NSCursor.arrowCursor().set()

        }
    }
}

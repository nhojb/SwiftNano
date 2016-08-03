//
//  Window.swift
//  Nano
//
//  Created by John on 20/06/2016.
//  Copyright © 2016 Formal Technology. All rights reserved.
//

import Foundation

public struct WindowFlags : OptionSetType {
    public let rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    static public let TitleBar = WindowFlags(rawValue: 1)
    static public let Resizable = WindowFlags(rawValue: 2)
}

public class Window : View {

    public var title : String?

    public var theme : Theme

    public let flags : WindowFlags

    // unowned: a "weak" ref which will never be set to nil during object's lifetime
    unowned public let screen : Screen

    override public var window : Window? {
        return self
    }

    // weak: may be set to nil by the runtime (hence optional type)
    internal private(set) weak var firstResponder : Responder?

    private var mouseDownHeaderLocation : CGPoint?

    private var contentView : View

    public init(screen: Screen, flags: WindowFlags = WindowFlags(rawValue:0)) {
        self.flags = flags
        self.screen = screen
        self.theme = Theme(context:screen.context)

        let frame = CGRect(origin:CGPoint(), size:screen.size)
        self.contentView = View(frame: frame)

        super.init(frame: frame)

        screen.add(window:self)
        super.add(subview:self.contentView)
    }

    public func makeKey() {
        self.screen.makeKey(window:self)

        // TODO: Activate initialFirstResponder?
    }

    var isKey : Bool  {
        get {
            return self.screen.keyWindow == self
        }
    }

    public func make(firstResponder responder: Responder) -> Bool {
        if let currentResponder = self.firstResponder {
            if !currentResponder.resignFirstResponder() {
                return false
            }
        }

        self.firstResponder = nil

        if responder.becomeFirstResponder() {
            self.firstResponder = responder
            return true
        }

        return false
    }

    // View
    override public func add(subview sv: View) {
        self.contentView.add(subview:sv)
    }

    override public func bringToFront(subview sv: View) {
        self.contentView.bringToFront(subview:sv)
    }

    override public func sendToBack(subview sv: View) {
        self.contentView.sendToBack(subview:sv)
    }

    override public func layoutSubviews() {
        var contentPadding : CGFloat = 0.0
        if flags.contains(.TitleBar) {
            contentPadding = theme.windowHeaderHeight
        }
        self.contentView.fillSuperview(top:contentPadding)

        super.layoutSubviews()
    }

    override public func draw(context ctx: Context) {
        // print("Window::draw")
        // print("size:", self.bounds.size)

        self.needsDisplay = false

        let dropShadowSize = self.theme.windowDropShadowSize
        let cornerRadius = self.theme.windowCornerRadius

        // Translate to our bounds coordinates
        let frame = self.frame
        ctx.translate(dx:frame.origin.x, dy:frame.origin.y)

        // Draw window
        ctx.save()

        defer {
            ctx.restore()

            // Draw subviews
            super.draw(context: ctx)

            ctx.translate(dx: -frame.origin.x, dy:-frame.origin.y)
        }

        ctx.beginPath()

        let bounds = self.bounds

        ctx.add(rect:bounds, cornerRadius:cornerRadius)

        if self.isKey {
            ctx.fill(withColor:self.theme.windowFillFocusedColor)
        }
        else {
            ctx.fill(withColor:self.theme.windowFillUnfocusedColor)
        }

        // Draw a drop shadow
        let shadowPaint = ctx.createBoxGradient(rect:bounds,
                                                cornerRadius: cornerRadius * 2.0,
                                                feather: dropShadowSize * 2.0,
                                                innerColor: self.theme.dropShadowColor,
                                                outerColor: Color.clear)

        ctx.beginPath()
        ctx.add(rect:bounds.makeInset(dx:-dropShadowSize, dy:-dropShadowSize), cornerRadius:cornerRadius)
        ctx.add(rect:bounds, cornerRadius:cornerRadius)
        ctx.set(pathWindingDirection:NVG_HOLE.rawValue)
        ctx.fill(withPaint:shadowPaint)

        if self.flags.contains(WindowFlags.TitleBar) {
            // Draw header
            let headerHeight = self.theme.windowHeaderHeight

            let headerPaint = ctx.createLinearGradient(start:bounds.origin,
                                                       end:CGPoint(x:bounds.origin.x, y:bounds.origin.y + headerHeight),
                                                       startColor:self.theme.windowHeaderGradientTopColor,
                                                       endColor:self.theme.windowHeaderGradientBottomColor)

            let headerFrame = CGRect(origin:bounds.origin, size:CGSize(width:bounds.size.width, height:headerHeight))

            ctx.beginPath()
            ctx.add(rect:headerFrame, cornerRadius:cornerRadius)
            ctx.fill(withPaint:headerPaint)

            ctx.beginPath()
            ctx.add(rect:headerFrame, cornerRadius:cornerRadius)
            ctx.set(clippingRegion: CGRect(origin:bounds.origin, size:CGSize(width:bounds.size.width, height:0.5)))
            ctx.stroke(withColor:self.theme.windowHeaderSeparatorTopColor)
            ctx.resetClipping()

            ctx.beginPath()
            var bottomSeparatorOrigin = CGPoint(x:bounds.origin.x + 0.5, y:bounds.origin.y + headerHeight - 1.5)
            ctx.move(to: bottomSeparatorOrigin)
            bottomSeparatorOrigin.x += bounds.size.width - 1.0
            ctx.line(to: bottomSeparatorOrigin)
            ctx.stroke(withColor: self.theme.windowHeaderSeparatorBottomColor)

            guard let title = self.title else {
                return
            }

            guard var boldFont = self.theme.boldFont else {
                return
            }

            if !title.isEmpty {
                ctx.save()
                boldFont.size = 17.0
                ctx.set(font:boldFont)
                ctx.set(textAlignment: TextAlignment(horizontal:.center))

                // Drop shadow
                ctx.set(fontBlur: 2.0)
                ctx.set(fillColor: self.theme.dropShadowColor)

                var titleOrigin = headerFrame.center
                ctx.draw(text:title, at:titleOrigin)

                // Title
                ctx.set(fontBlur:0.0)

                if self.isKey {
                    ctx.set(fillColor: self.theme.windowTitleFocusedColor)
                }
                else {
                    ctx.set(fillColor: self.theme.windowTitleUnfocusedColor)
                }

                titleOrigin.y -= 1.0
                ctx.draw(text:title, at:titleOrigin)

                ctx.restore()
            }
        }
    }

    // Responder
    override public var nextResponder : Responder? {
        // We've reached the top of the responder chain
        return nil
    }

    override public func mouseDown(event: Event) {
        print("window: mouseDown")
        if let location = event.locationInWindow {
            if location.y < self.theme.windowHeaderHeight {
                self.mouseDownHeaderLocation = event.locationInWindow
            }
        }
    }

    override public func mouseDragged(event: Event) {
        print("window: mouseDragged")
        print("event.window:", event.window)

        // Check for drag on title bar (also resize?)
        if self.title != nil {
            guard let location = event.locationInWindow else {
                return
            }

            guard let mouseDownLocation = self.mouseDownHeaderLocation else {
                return
            }

            let delta = (location - mouseDownLocation)
            self.center += delta
        }
    }

    override public func mouseUp(event: Event) {
        print("window: mouseUp")

        // no-op
        self.mouseDownHeaderLocation = nil
    }
}

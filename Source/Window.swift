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
    static public let FullScreen = WindowFlags(rawValue: 4)
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
    public private(set) weak var firstResponder : Responder?

    public let contentView : View

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

    public var isKey : Bool  {
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

    // Set this to restrict to control the windows minium size
    public var minimumContentSize = CGSize(width:100.0, height:200.0) {
        didSet {
            var windowSize = minimumContentSize
            if self.flags.contains(.TitleBar) {
                windowSize.height += self.theme.windowHeaderHeight
            }
            self.bounds = CGRect(origin:self.bounds.origin, size:windowSize)
        }
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

    override public var frame : CGRect {
        get {
            return super.frame
        }
        set(newFrame) {
            var frame = newFrame
            frame.size = CGSize(width:max(frame.size.width, minimumContentSize.width),
                                height:max(frame.size.height, minimumContentSize.height))
            super.frame = frame
        }
    }

    override public var bounds : CGRect {
        get {
            return super.bounds
        }
        set(newBounds) {
            var bounds = newBounds
            bounds.size = CGSize(width:max(bounds.size.width, minimumContentSize.width),
                                height:max(bounds.size.height, minimumContentSize.height))
            super.bounds = bounds
        }
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

            ctx.resetClipping()

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

        // Clip to bounds from now on (including subviews)
        ctx.set(clippingRegion:self.bounds)

        if self.flags.contains(.Resizable) {
            // Draw a resize handle in the bottom-left corner:
            var resizeFrame = self.resizeHandleFrame

            let indent : CGFloat = 2.0
            let strokeColor = Color(white:0.5)
            for idx in 0...2 {
                if idx > 0 {
                    resizeFrame = resizeFrame.makeInset(left:indent, top:indent, right:0.0, bottom:0.0)
                }
                ctx.beginPath()
                ctx.move(to:resizeFrame.bottomLeft)
                ctx.line(to:resizeFrame.topRight)
                ctx.stroke(withColor:strokeColor)
            }
        }

        if self.flags.contains(.TitleBar) {
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

    var resizeHandleFrame : CGRect {
        let resizeHandleWidth : CGFloat = 10.0
        return CGRect(origin: CGPoint(x:self.bounds.maxX - resizeHandleWidth, y:self.bounds.maxY - resizeHandleWidth),
                      size: CGSize(width:resizeHandleWidth, height:resizeHandleWidth))
    }

    private var mouseDownHeaderLocation : CGPoint?
    private var mouseDownResizeLocation : CGPoint?

    // Responder
    override public var nextResponder : Responder? {
        // We've reached the top of the responder chain
        return nil
    }

    override public func mouseDown(event: Event) {
        if let location = event.locationInWindow {
            if self.flags.contains(.TitleBar) && location.y < self.theme.windowHeaderHeight {
                self.mouseDownHeaderLocation = location
            }
            else if self.flags.contains(.Resizable) && self.resizeHandleFrame.contains(location) {
                self.mouseDownResizeLocation = location
            }
            else {
                event.cancel()
            }
        }
    }

    override public func mouseDragged(event: Event) {
        // Check for drag on title bar (also resize?)
        guard let location = event.locationInWindow else {
            return
        }

        if let headerLocation = self.mouseDownHeaderLocation {
            let delta = (location - headerLocation)
            self.center += delta
        }
        else if let resizeLocation = self.mouseDownResizeLocation {
            let delta = (location - resizeLocation)
            var bounds = self.bounds
            bounds.size.width += delta.x
            bounds.size.height += delta.y
            self.bounds = bounds

            // bounds may be constrained by minimumContentSize, so establish new "resize location"
            self.mouseDownResizeLocation = self.bounds.bottomRight
        }
    }

    override public func mouseUp(event: Event) {
        self.mouseDownHeaderLocation = nil
        self.mouseDownResizeLocation = nil;
    }
}

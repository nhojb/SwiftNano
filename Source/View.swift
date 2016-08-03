//
//  View.swift
//  Nano
//
//  Created by John on 14/06/2016.
//  Copyright © 2016 Formal Technology. All rights reserved.
//

import Foundation

// Note that not all cursor styles will be supported by the host system.
public enum CursorStyle {
    case arrow
    case ibeam
    case crossHair
    case resizeLeft
    case resizeRight
    case resizeLeftRight
    case resizeUp
    case resizeDown
    case resizeUpDown
    case resizeDiagonalRight
    case resizeDiagonalLeft
}

public class View : Responder, Frameable, Anchorable, Alignable, Groupable  {

    internal private(set) var superview : View?

    internal private(set) var subviews = [View]()

    public var window : Window? {
        return self.superview?.window
    }

    public var context : Context? {
        return self.window?.screen.context
    }

    public var center = CGPoint() {
        didSet {
            needsDisplay = true
        }
    }

    public var frame : CGRect {
        get {
            // TODO: Handle (add) a transform property...
            let origin = CGPoint(x: self.center.x - self.bounds.size.width / 2.0,
                                   y: self.center.y - self.bounds.size.height / 2.0)
            return CGRect(origin:origin, size:self.bounds.size)
        }
        set {
            self.bounds.size = newValue.size
            self.center = CGPoint(x: newValue.origin.x + self.bounds.size.width / 2.0,
                                    y: newValue.origin.y + self.bounds.size.height / 2.0)
            needsLayout = true
            needsDisplay = true
        }
    }

    public var bounds = CGRect() {
        didSet {
            // Frame origin does not change, rather the view expands to the right/bottom.
            self.center.x += (self.bounds.size.width - oldValue.size.width) / 2.0
            self.center.y += (self.bounds.size.height - oldValue.size.height) / 2.0
            needsLayout = true
            needsDisplay = true
        }
    }

    public var hidden = false

    public var needsLayout = false

    public var needsDisplay = false

    var needsDisplayRecursive : Bool {
        if self.needsDisplay {
            return true
        }

        for sv in self.subviews {
            if sv.needsDisplayRecursive {
                return true
            }
        }

        return false
    }

    public var alpha = 1.0

    public var backgroundColor : Color?

    public var cursorStyle : CursorStyle?

    public var userInteractionEnabled = true

    public init(frame f: CGRect) {
        super.init()
        self.frame = f
    }

    override public var nextResponder : Responder? {
        // Always our superview
        // (see https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/EventOverview/EventArchitecture/EventArchitecture.html)
        return self.superview
    }

    public func add(subview sv: View) {
        if !self.subviews.contains(sv) {
            sv.superview = self
            self.subviews.append(sv)
        }
    }

    public func removeFromSuperview() {
        if let superview = self.superview {
            superview.subviews.remove(self)
            self.superview = nil
        }
    }

    public func bringToFront(subview sv: View) {
        if sv.superview == self {
            self.subviews.remove(sv)
            self.subviews.append(sv)
        }
    }

    public func sendToBack(subview sv: View) {
        if sv.superview == self {
            self.subviews.remove(sv)
            self.subviews.insert(sv, atIndex:0)
        }
    }

    public static var debugDrawing = false

    public func draw(context ctx: Context) {
        // TODO: Background color fill...
        self.needsDisplay = false

        if self.hidden {
            return
        }

        if View.debugDrawing {
            ctx.stroke(rect:self.bounds, withColor:Color(red:1.0, green:0.0, blue:0.0, alpha:0.5))
        }

        for sv in self.subviews {
            // NanoVG drawing is all or nothing, so no check for needsDisplay here.
            ctx.save()
            // Translate context to view's coordinates
            let offset = sv.frame.origin
            ctx.translate(dx:offset.x, dy:offset.y)
            sv.draw(context:ctx)
            ctx.restore()
        }
    }

    public func layoutSubviews() {
        self.needsLayout = false

        // TODO: Handle layout of the sv itself...
        // Layout manager?

        for sv in self.subviews {
            if ( sv.needsLayout ) {
                sv.layoutSubviews()
            }
        }
    }

    public var preferredSize : CGSize {
        // TODO: Handle layout/enumerate subviews?
        return CGSize()
    }

    public func sizeToFit() {
        let preferredSize = self.preferredSize
        if !preferredSize.isEmpty && self.bounds.size != preferredSize {
            self.bounds = CGRect(origin:self.bounds.origin, size:preferredSize)
        }
    }

    public func hitTest(pointInSuperview pt: CGPoint) -> View? {
        // print("hitTest:", pt)
        // print("frame:", self.frame)

        if !self.userInteractionEnabled || self.hidden || self.alpha < 0.01 || !self.frame.contains(pt) {
            return nil
        }

        let pointInView = pt - self.frame.origin

        for sv in self.subviews {
            if let target = sv.hitTest(pointInSuperview:pointInView) {
                return target
            }
        }

        return self
    }

    // public func convert(point pt: CGPoint, fromView: View?) -> CGPoint {
    //     if let view = fromView {
    //     }
    //     else {
    //         // Convert from window coordinates to our own coordinates
    //         return pt - self.frame.origin
    //     }
    // }

    // Frameable
    public var superFrame : CGRect {
        if let superview = self.superview {
            return superview.frame
        }
        else {
            return CGRectZero
        }
    }

    public func setDimensionAutomatically() {
        var bounds = self.bounds
        let preferredSize = self.preferredSize
        if !preferredSize.isEmpty && bounds.size != preferredSize {
            bounds.size = preferredSize
            self.bounds = bounds
        }
    }
}

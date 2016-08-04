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

public struct AutoSize : OptionSetType {
    public let rawValue : UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    static public let none = AutoSize(rawValue: 0)
    // Size
    static public let fixedWidth = AutoSize(rawValue: 1<<1)
    static public let fixedHeight = AutoSize(rawValue: 1<<2)
    static public let autoWidth = AutoSize(rawValue: 1<<3)
    static public let autoHeight = AutoSize(rawValue: 1<<4)
    // Horizontal
    static public let autoLeft = AutoSize(rawValue: 1<<5)
    static public let autoCenter = AutoSize(rawValue: 1<<6)
    static public let autoRight = AutoSize(rawValue: 1<<7)
    // Vertical
    static public let autoTop = AutoSize(rawValue: 1<<8)
    static public let autoMiddle = AutoSize(rawValue: 1<<9)
    static public let autoBottom = AutoSize(rawValue: 1<<10)
}

public class View : Responder, Frameable, Anchorable, Alignable, Groupable, CustomStringConvertible  {

    public private(set) var superview : View?

    public private(set) var subviews = [View]()

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
            let oldSize = self.bounds.size
            self.bounds.size = newValue.size
            self.center = CGPoint(x: newValue.origin.x + self.bounds.size.width / 2.0,
                                  y: newValue.origin.y + self.bounds.size.height / 2.0)

            if oldSize != newValue.size {
                needsLayout = true
                needsDisplay = true
            }
        }
    }

    public var bounds = CGRect() {
        didSet {
            // Frame origin does not change, rather the view expands to the right/bottom.
            self.center.x += (self.bounds.size.width - oldValue.size.width) / 2.0
            self.center.y += (self.bounds.size.height - oldValue.size.height) / 2.0

            if oldValue.size != self.bounds.size {
                needsLayout = true
                needsDisplay = true
            }
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

    public var clipsToBounds : Bool {
        return true
    }

    public var layout : Layout? = AutoLayout()

    public var autosizing = AutoSize.none

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
            if sv.clipsToBounds {
                ctx.intersect(clippingRegion:sv.bounds)
            }
            sv.draw(context:ctx)
            ctx.restore()
        }
    }

    public func layoutIfNeeded() {
        print("\(self) layoutIfNeeded", self.needsLayout)
        if self.needsLayout {
            self.layoutSubviews()
        }
        else {
            for sv in self.subviews {
                sv.layoutIfNeeded()
            }
        }
    }

    public func layoutSubviews() {
        self.needsLayout = false

        // print("\(self) layoutSubviews")
        // print("layout:", self.layout)

        if let layout = self.layout {
            layout.layout(self)
        }

        for sv in self.subviews {
            if ( sv.needsLayout ) {
                sv.layoutSubviews()
            }
        }
    }

    public var preferredSize : CGSize {
        if let layout = self.layout {
            return layout.preferredSize(self)
        }
        else {
            return self.bounds.size
        }
    }

    public func sizeToFit() {
        var preferredSize = self.preferredSize

        if self.autosizing.contains(.fixedWidth) {
            preferredSize.width = self.bounds.width
        }

        if self.autosizing.contains(.fixedHeight) {
            preferredSize.height = self.bounds.height
        }

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

    public var description : String {
        return "\(self.dynamicType), frame: \(frame), subviews: \(subviews.count)"
    }
}

//
//  Label.swift
//  Nano
//
//  Created by John on 28/06/2016.
//  Copyright © 2016 Formal Technology. All rights reserved.
//

import Foundation

public class Label : View {

    public var font : Font? {
        didSet {
            needsDisplay = true
            needsLayout = true
        }
    }

    public var text : String? {
        didSet {
            needsDisplay = true
            needsLayout = true
        }
    }

    public var textAlignment : HorizontalAlignment = .left

    public var textColor = Color(white:0.0, alpha:1.0) {
        didSet {
            needsDisplay = true
        }
    }

    public var shadowColor : Color? {
        didSet {
            needsDisplay = true
            needsLayout = true
        }
    }

    public var shadowOffset = CGSize() {
        didSet {
            needsDisplay = true
            needsLayout = true
        }
    }

    public var padding = CGSize(width:5.0, height:2.0)

    public init(text: String) {
        self.text = text
        super.init(frame:CGRectZero)
    }

    override public var preferredSize : CGSize {
        guard let text = self.text else {
            return CGSizeZero
        }

        if text.isEmpty {
            return CGSizeZero
        }

        guard let context = self.context else {
            return CGSizeZero
        }

        guard let font = self.font ?? self.window?.theme.normalFont else {
            return CGSizeZero
        }

        context.save()
        context.set(font:font)
        context.set(textAlignment: TextAlignment(horizontal:self.textAlignment))
        var bounds = context.boundsFor(text:text)
        context.restore()

        if self.shadowColor != nil {
            bounds.size.width += self.shadowOffset.width
            bounds.size.height += self.shadowOffset.height
        }

        bounds.size.width += 2.0 * self.padding.width
        bounds.size.height += 2.0 * self.padding.height

        return bounds.size
    }

    override public func draw(context context: Context) {
        super.draw(context:context)

        guard let text = self.text else {
            return
        }

        if text.isEmpty {
            return
        }

        guard let font = self.font ?? self.window?.theme.normalFont else {
            return
        }

        let bounds = self.bounds.makeInset(dx:self.padding.width, dy:self.padding.height)

        func draw(text: String, at: CGPoint) {
            var point = at
            point.y = bounds.center.y

            switch self.textAlignment {
                case .left:
                    break
                case .center:
                    point.x += bounds.size.width / 2.0
                case .right:
                    point.x += bounds.size.width
            }
            context.draw(text:text, at:point)
        }

        context.set(font:font)
        context.set(textAlignment: TextAlignment(horizontal:self.textAlignment))

        // Shadow
        if let shadowColor = self.shadowColor {
            var origin = bounds.origin
            origin.x += self.shadowOffset.width
            origin.y += self.shadowOffset.height

            context.set(fillColor: shadowColor)
            context.set(fontBlur: 2.0)
            draw(text, at:origin)
        }

        // Text
        context.set(fontBlur: 0.0)
        context.set(fillColor: self.textColor)

        draw(text, at:bounds.origin)
    }
}

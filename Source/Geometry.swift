//
//  Geometry.swift
//  Nano
//
//  Created by John on 14/06/2016.
//  Copyright © 2016 Formal Technology. All rights reserved.
//

import Foundation

public enum HorizontalAlignment {
    case left
    case center
    case right
}

public enum VerticalAlignment {
    case top
    case middle
    case bottom
}

public struct Alignment {
    public var horizontal : HorizontalAlignment
    public var vertical : VerticalAlignment

    public init(horizontal: HorizontalAlignment, vertical: VerticalAlignment) {
        self.horizontal = horizontal
        self.vertical = vertical
    }

    public init(horizontal: HorizontalAlignment) {
        self.horizontal = horizontal
        self.vertical = .middle
    }
}

public struct EdgeInsets {
    public var top : CGFloat
    public var left : CGFloat
    public var bottom : CGFloat
    public var right : CGFloat

    public init(top: CGFloat = 0.0, left: CGFloat = 0.0, bottom: CGFloat = 0.0, right: CGFloat = 0.0) {
        self.top = top
        self.left = left
        self.bottom = bottom
        self.right = right
    }

    public init(all: CGFloat) {
        self.top = all
        self.left = all
        self.bottom = all
        self.right = all
    }

    public init(horizontal: CGFloat, vertical: CGFloat) {
        self.top = vertical
        self.bottom = vertical
        self.left = horizontal
        self.right = horizontal
    }
}

// CGPoint operators
func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x:left.x + right.x, y:left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x:left.x - right.x, y:left.y - right.y)
}

func += (inout left: CGPoint, right: CGPoint) {
    left = left + right
}

func -= (inout left: CGPoint, right: CGPoint) {
    left = left - right
}

prefix func - (point: CGPoint) -> CGPoint {
    return CGPoint(x: -point.x, y: -point.y)
}

extension CGSize {
    public var isEmpty : Bool {
        return (self.width == 0.0 || self.height == 0.0)
    }
}

// CGSize operators
func * (left: CGSize, right: CGFloat) -> CGSize {
    return CGSize(width: left.width * right, height: left.height * right)
}

func / (left: CGSize, right: CGFloat) -> CGSize {
    return CGSize(width: left.width / right, height: left.height / right)
}

extension CGRect {
    var maxX : CGFloat {
        return self.origin.x + self.size.width
    }

    var maxY : CGFloat {
        return self.origin.y + self.size.height
    }

    var center: CGPoint {
        get {
            let centerX = origin.x + (size.width / 2.0)
            let centerY = origin.y + (size.height / 2.0)
            return CGPoint(x: centerX, y: centerY)
        }
        set(center) {
            origin.x = center.x - (size.width / 2.0)
            origin.y = center.y - (size.height / 2.0)
        }
    }

    var topLeft: CGPoint {
        return self.origin
    }

    var topRight: CGPoint {
        return CGPoint(x:self.maxX, y:self.origin.y)
    }

    var bottomRight: CGPoint {
        return CGPoint(x:self.maxX, y:self.maxY)
    }

    var bottomLeft: CGPoint {
        return CGPoint(x:self.origin.x, y:self.maxY)
    }

    func makeInset(dx dx: CGFloat, dy: CGFloat) -> CGRect {
        return CGRect(x:self.origin.x + dx,
                      y:self.origin.y + dy,
                      width:self.size.width - 2.0 * dx,
                      height:self.size.height - 2.0 * dy)
    }

    func makeInset(left left: CGFloat, top: CGFloat, right: CGFloat, bottom: CGFloat) -> CGRect {
        return CGRect(x:self.origin.x + left,
                      y:self.origin.y + top,
                      width:self.size.width - right,
                      height:self.size.height - bottom)
    }

    func contains(point: CGPoint) -> Bool {
        return (point.x >= self.origin.x && point.y >= self.origin.y && point.x <= self.maxX && point.y <= self.maxY)
    }
}

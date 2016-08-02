//
//  Geometry.swift
//  Nano
//
//  Created by John on 14/06/2016.
//  Copyright © 2016 Formal Technology. All rights reserved.
//

import Foundation

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

    func makeInset(dx dx: CGFloat, dy: CGFloat) -> CGRect {
        var inset = self
        inset.origin.x += dx
        inset.origin.y += dy
        inset.size.width -= 2.0 * dx
        inset.size.height -= 2.0 * dy
        return inset
    }

    func contains(point: CGPoint) -> Bool {
        return (point.x >= self.origin.x && point.y >= self.origin.y && point.x <= self.maxX && point.y <= self.maxY)
    }
}

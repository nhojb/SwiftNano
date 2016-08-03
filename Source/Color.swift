//
//  Color.swift
//  Nano
//
//  Created by John on 15/06/2016.
//  Copyright © 2016 Formal Technology. All rights reserved.
//

import Foundation

public struct Color : Equatable {
    public var red : Float = 0.0
    public var green : Float = 0.0
    public var blue : Float = 0.0
    public var alpha : Float = 1.0

    public init(red r: Float = 0.0, green g: Float = 0.0, blue b: Float = 0.0, alpha a: Float = 1.0) {
        self.red = r
        self.green = g
        self.blue = b
        self.alpha = a
    }

    public init(white w: Float, alpha a: Float = 1.0) {
        self.red = w
        self.green = w
        self.blue = w
        self.alpha = a
    }

    var nvgColor : NVGcolor {
        return nvgRGBAf(self.red, self.green, self.blue, self.alpha)
    }

    public static var white : Color {
        return Color(white:1.0, alpha:1.0)
    }

    public static var black : Color {
        return Color(white:0.0, alpha:1.0)
    }

    public static var clear : Color {
        return Color(white:0.0, alpha:0.0)
    }
}

public func ==(lhs: Color, rhs: Color) -> Bool {
    return lhs.red == rhs.red
            && lhs.green == rhs.green
            && lhs.blue == rhs.blue
            && lhs.alpha == rhs.alpha
}

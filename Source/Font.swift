//
//  Font.swift
//  Nano
//
//  Created by John on 28/06/2016.
//  Copyright © 2016 Formal Technology. All rights reserved.
//

import Foundation

public struct Font {
    let handle : Int32
    public let name : String
    public var size : CGFloat

    public init(handle _handle: Int32, name _name: String, size _size: CGFloat = 12.0) {
        self.handle = _handle
        self.name = _name
        self.size = _size
    }
}

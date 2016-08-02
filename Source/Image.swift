//
//  Image.swift
//  Nano
//
//  Created by John on 06/07/2016.
//  Copyright © 2016 Formal Technology. All rights reserved.
//

import Foundation

public struct Image {
    let handle : Int32
    public let name : String
    public let size : CGSize

    public init(handle _handle: Int32, name _name: String, size _size: CGSize) {
        self.handle = _handle
        self.name = _name
        self.size = _size
    }
}

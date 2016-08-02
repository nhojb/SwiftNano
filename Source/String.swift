//
//  String.swift
//  ColorFinale
//
//  Created by John on 07/07/2016.
//  Copyright © 2016 Formal Technology. All rights reserved.
//

import Foundation

extension String {
    private var ns: NSString {
        return self as NSString
    }
    var pathExtension: String {
        return ns.pathExtension
    }
    var deletingPathExtension: String {
        return ns.stringByDeletingPathExtension
    }
    var lastPathComponent: String {
        return ns.lastPathComponent
    }
}

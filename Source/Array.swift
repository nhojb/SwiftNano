//
//  Array.swift
//  ColorFinale
//
//  Created by John on 27/07/2016.
//  Copyright © 2016 Formal Technology. All rights reserved.
//

import Foundation

extension Array where Element : Equatable {
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Generator.Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
}

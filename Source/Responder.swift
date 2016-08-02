//
//  Responder.swift
//  Nano
//
//  Created by John on 14/06/2016.
//  Copyright © 2016 Formal Technology. All rights reserved.
//

import Foundation

public class Responder : Equatable, Hashable {

    public var hashValue : Int {
        return self.identifier.hashValue
    }

    private var internalIdentifier : ObjectIdentifier?

    public var identifier : ObjectIdentifier {
        if let id = internalIdentifier {
            return id
        }
        else {
            internalIdentifier = ObjectIdentifier(self)
            return internalIdentifier!
        }
    }

    public var acceptsFirstResponder = false;

    public var nextResponder : Responder? {
        return nil
    }

    public func becomeFirstResponder() -> Bool {
        return false
    }

    public func resignFirstResponder() -> Bool {
        return true
    }

    public func mouseDown(event: Event) {
        if let next = nextResponder {
            next.mouseDown(event)
        }
    }

    public func mouseDragged(event: Event) {
        if let next = nextResponder {
            next.mouseDragged(event)
        }
    }

    public func mouseUp(event: Event) {
        if let next = nextResponder {
            next.mouseUp(event)
        }
    }

    public func mouseMoved(event: Event) {
        if let next = nextResponder {
            next.mouseMoved(event)
        }
    }

    public func mouseEntered(event: Event) {
        if let next = nextResponder {
            next.mouseEntered(event)
        }
    }

    public func mouseExited(event: Event) {
        if let next = nextResponder {
            next.mouseExited(event)
        }
    }

    public func keyDown(event: Event) {
        if let next = nextResponder {
            next.keyDown(event)
        }
    }

    public func keyUp(event: Event) {
        if let next = nextResponder {
            next.keyUp(event)
        }
    }
}

public func == (lhs: Responder, rhs: Responder) -> Bool {
    return lhs.identifier == rhs.identifier
}

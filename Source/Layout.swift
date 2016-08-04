//
//  Layout.swift
//  Nano
//
//  Created by John on 03/08/2016.
//  Copyright © 2016 Formal Technology Ltd. All rights reserved.
//

import Foundation

public protocol Layout {
    func layout(view: View)
    func preferredSize(view: View) -> CGSize
}

public class LayoutCallback : Layout {
    public let callback : (View) -> Void

    public init(_ callback: (View) -> Void) {
        self.callback = callback
    }

    public func layout(view: View) {
        self.callback(view)
    }

    public func preferredSize(view: View) -> CGSize {
        return view.bounds.size
    }
}

/// Calculates layout based on a view's autosizing property.
/// Suitable for subviews with complementary autosizing values e.g. .autoLeft and .autoRight, but not .autoWidth and .autoRight (they will overlap).
public class AutoLayout : Layout {
    public var edgeInsets : EdgeInsets

    public init(edgeInsets : EdgeInsets = EdgeInsets()) {
        self.edgeInsets = edgeInsets
    }

    public func layout(view: View) {
        let bounds = view.bounds
        let maxWidth = bounds.size.width - self.edgeInsets.left - self.edgeInsets.right
        let maxHeight = bounds.size.height - self.edgeInsets.top - self.edgeInsets.bottom

        for sv in view.subviews {
            sv.sizeToFit()

            var frame = sv.frame

            if sv.autosizing.contains(.autoWidth) {
                frame.origin.x = self.edgeInsets.left
                frame.size.width = maxWidth
            }

            if sv.autosizing.contains(.autoHeight) {
                frame.origin.y = self.edgeInsets.top
                frame.size.height = maxHeight
            }

            if sv.autosizing.contains(.autoLeft) {
                frame.origin.x = bounds.origin.x + self.edgeInsets.left
            }
            else if sv.autosizing.contains(.autoCenter) {
                frame.origin.x = bounds.center.x - frame.size.width / 2.0
            }
            else if sv.autosizing.contains(.autoRight) {
                frame.origin.y = bounds.maxX - frame.size.width - self.edgeInsets.right
            }

            if sv.autosizing.contains(.autoTop) {
                frame.origin.y = bounds.origin.y + self.edgeInsets.top
            }
            else if sv.autosizing.contains(.autoMiddle) {
                frame.origin.y = bounds.center.y - frame.size.height / 2.0
            }
            else if sv.autosizing.contains(.autoBottom) {
                frame.origin.y = bounds.maxY - frame.size.height - self.edgeInsets.bottom
            }

            sv.frame = frame
        }
    }

    public func preferredSize(view: View) -> CGSize {
        var size = view.bounds.size
        for sv in view.subviews {
            sv.sizeToFit()
            size.width = max(sv.bounds.size.width, size.width)
            size.height = max(sv.bounds.size.height, size.height)
        }
        return size
    }
}

/// Arranges subviews in a vertical row, with optional padding between subviews.
/// Also respects relevant autosizing values e.g. .autoWidth, .autoHeight
public class VerticalLayout : Layout {
    public var edgeInsets : EdgeInsets
    public var innerPadding : CGFloat
    public var alignment : Alignment
    public var fixedWidth : CGFloat?

    public init(alignment: Alignment, innerPadding: CGFloat = 0.0, edgeInsets: EdgeInsets = EdgeInsets()) {
        self.alignment = alignment
        self.innerPadding = innerPadding
        self.edgeInsets = edgeInsets
    }

    public func layout(view: View) {
        // print("\(self) layout")
        // print("view:", view)
        // print("view.subviews:", view.subviews)

        let bounds = view.bounds

        let layoutWidth = self.fixedWidth ?? view.bounds.width
        let maxWidth = layoutWidth - self.edgeInsets.left - self.edgeInsets.right

        let preferredSize = self.preferredSize(view)
        var y : CGFloat

        switch alignment.vertical {
        case .top:
            y = self.edgeInsets.top

        case .middle:
            y = bounds.center.y - preferredSize.height / 2.0

        case .bottom:
            y = bounds.maxY - preferredSize.height
        }

        for sv in view.subviews {
            // TODO: Respect .autoHeight - we'll need a first pass to work out how much space to allocate to each view...
            sv.sizeToFit()

            var frame = sv.frame

            if sv.autosizing.contains(.autoWidth) {
                frame.size.width = maxWidth
            }
            else {
                frame.size.width = min(frame.size.width, maxWidth)
            }
            frame.origin.y = y

            switch alignment.horizontal {
            case .left:
                frame.origin.x = self.edgeInsets.left

            case .center:
                frame.origin.x = bounds.center.x - frame.size.width / 2.0

            case .right:
                frame.origin.x = bounds.maxX - frame.size.width - self.edgeInsets.right
            }

            sv.frame = frame
            y += frame.size.height + self.innerPadding
        }
    }

    public func preferredSize(view: View) -> CGSize {
        var preferredSize = view.bounds.size
        if view.subviews.count == 0 {
            return preferredSize
        }
        else {
            preferredSize = CGSize(width:preferredSize.width, height:0.0)
            for sv in view.subviews {
                sv.sizeToFit()
                preferredSize.height += self.innerPadding + sv.frame.size.height
            }
            preferredSize.height += self.edgeInsets.top + self.edgeInsets.bottom
            return preferredSize
        }
    }
}

/// Arranges subviews in a horizontal row, with optional padding between subviews.
/// Also respects relevant autosizing values e.g. .autoWidth, .autoHeight
public class HorizontalLayout : Layout {
    public var edgeInsets : EdgeInsets
    public var innerPadding : CGFloat
    public var alignment : Alignment
    public var fixedHeight : CGFloat?

    public init(alignment: Alignment, innerPadding: CGFloat = 0.0, edgeInsets : EdgeInsets = EdgeInsets()) {
        self.alignment = alignment
        self.innerPadding = innerPadding
        self.edgeInsets = edgeInsets
    }

    public func layout(view: View) {
        // print("\(self) layout")
        // print("view:", view)
        // print("view.subviews:", view.subviews)

        let bounds = view.bounds

        let layoutHeight = self.fixedHeight ?? view.bounds.height
        let maxHeight = layoutHeight - self.edgeInsets.top - self.edgeInsets.bottom

        let preferredSize = self.preferredSize(view)
        var x : CGFloat

        switch alignment.horizontal {
        case .left:
            x = self.edgeInsets.left

        case .center:
            x = bounds.center.x - preferredSize.width / 2.0

        case .right:
            x = bounds.maxX - preferredSize.width
        }

        for sv in view.subviews {
            // TODO: Respect .autoWidth - we'll need a first pass to work out how much space to allocate to each view...
            sv.sizeToFit()

            var frame = sv.frame

            if sv.autosizing.contains(.autoHeight) {
                frame.size.height = maxHeight
            }
            else {
                frame.size.height = min(frame.size.height, maxHeight)
            }
            frame.origin.x = x

            switch alignment.vertical {
            case .top:
                frame.origin.y = self.edgeInsets.top

            case .middle:
                frame.origin.y = bounds.center.y - frame.size.height / 2.0

            case .bottom:
                frame.origin.y = bounds.maxY - frame.size.height - self.edgeInsets.bottom
            }

            sv.frame = frame
            x += frame.size.width + self.innerPadding
        }
    }

    public func preferredSize(view: View) -> CGSize {
        var preferredSize = view.bounds.size
        if view.subviews.count == 0 {
            return preferredSize
        }
        else {
            preferredSize = CGSize(width:0.0, height:preferredSize.height)
            for sv in view.subviews {
                sv.sizeToFit()
                preferredSize.width += self.innerPadding + sv.frame.size.width
            }
            preferredSize.width += self.edgeInsets.left + self.edgeInsets.right
            return preferredSize
        }
    }
}

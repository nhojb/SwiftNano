//
//  Theme.swift
//  Nano
//
//  Created by John on 24/06/2016.
//  Copyright © 2016 Formal Technology. All rights reserved.
//

import Foundation
import AppKit

public enum ButtonGradient {
    case focusedTop, focusedBottom
    case unfocusedTop, unfocusedBottom
    case pushedTop, pushedBottom
}

public struct Theme {
    public var windowCornerRadius : CGFloat = 2.0
    public var windowHeaderHeight : CGFloat = 30.0
    public var windowDropShadowSize : CGFloat = 10.0
    public var buttonCornerRadius : CGFloat = 2.0

    public var dropShadowColor = Color(white:0.0, alpha:0.5)
    public var borderDarkColor = Color(white:0.11, alpha:1.0)
    public var borderLightColor = Color(white:0.36, alpha:1.0)
    public var borderMediumColor = Color(white:0.14, alpha:1.0)

    public var textColor = Color(white:0.6, alpha:1.0)
    public var disabledTextColor = Color(white:0.31, alpha:1.0)
    public var textShadowColor = Color(white:0.0, alpha:1.0)

    public var iconColor = Color(white:0.6, alpha:1.0)

    public var buttonGradientColor = [ButtonGradient.focusedTop: Color(white:0.25, alpha:1.0),
                               ButtonGradient.focusedBottom: Color(white:0.19, alpha:1.0),
                               ButtonGradient.unfocusedTop: Color(white:0.29, alpha:1.0),
                               ButtonGradient.unfocusedBottom: Color(white:0.23, alpha:1.0),
                               ButtonGradient.pushedTop: Color(white:0.16, alpha:1.0),
                               ButtonGradient.pushedBottom: Color(white:0.11, alpha:1.0)]

    public var windowFillUnfocusedColor = Color(white:0.17, alpha:1.0)
    public var windowFillFocusedColor = Color(white:0.2, alpha:1.0)
    public var windowTitleUnfocusedColor = Color(white:0.54, alpha:1.0)
    public var windowTitleFocusedColor = Color(white:0.75, alpha:1.0)

    public var windowHeaderGradientTopColor = Color(white:0.29, alpha:1.0)
    public var windowHeaderGradientBottomColor = Color(white:0.23, alpha:1.0)
    public var windowHeaderSeparatorTopColor = Color(white:0.36, alpha:1.0)
    public var windowHeaderSeparatorBottomColor = Color(white:0.11, alpha:1.0)

    public var windowPopupColor = Color(white:0.2, alpha:1.0)
    public var windowPopupTransparentColor = Color(white:0.2, alpha:0.5)

    public var standardFontSize : CGFloat = 16.0
    public var buttonFontSize : CGFloat = 20.0
    public var textBoxFontSize : CGFloat = 20.0

    public var normalFont : Font?
    public var boldFont : Font?

    public init(context ctx: Context) {

        func create(font fnt: NSFont) -> Font? {
            let fontDescriptor = CTFontDescriptorCreateWithNameAndSize(fnt.fontName, fnt.pointSize)
            let url = CTFontDescriptorCopyAttribute(fontDescriptor, kCTFontURLAttribute) as! NSURL

            guard let path = url.path else {
                print("Invalid font url:", url)
                return nil
            }

            do {
                var nanoFont = try ctx.createFont(name:fnt.fontName, path:path)
                nanoFont.size = fnt.pointSize
                return nanoFont
            }
            catch ContextError.InvalidPath(let path) {
                print("Invalid font path:", path)
                return nil
            }
            catch {
                // should never get here, but Swift forces us to handle "any" error
                fatalError("Unhandled error")
            }
        }

        normalFont = create(font: NSFont.systemFontOfSize(self.standardFontSize))
        boldFont = create(font: NSFont.boldSystemFontOfSize(self.standardFontSize))
    }
}

//
//  Context.swift
//  Nano
//
//  Created by John on 06/07/2016.
//  Copyright © 2016 Formal Technology. All rights reserved.
//

import Foundation

public enum ContextError: ErrorType {
    case InvalidPath(path: String)
}

public struct ContextOptions : OptionSetType {
    public let rawValue : UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    // Must match NVGcreateFlags in nanovg_gl.h
    static public let Antialias = ContextOptions(rawValue: 1<<0)
    static public let StencilStrokes = ContextOptions(rawValue: 1<<1)
    static public let Debug = ContextOptions(rawValue: 1<<2)
}

extension Alignment {
    var nvgAlign : Int32 {
        var align : UInt32 = 0

        switch self.horizontal {
            case .left:
                align |= NVG_ALIGN_LEFT.rawValue

            case .center:
                align |= NVG_ALIGN_CENTER.rawValue

            case .right:
                align |= NVG_ALIGN_RIGHT.rawValue
        }

        switch self.vertical {
            case .top:
                align |= NVG_ALIGN_TOP.rawValue

            case .middle:
                align |= NVG_ALIGN_MIDDLE.rawValue

            case .bottom:
                align |= NVG_ALIGN_BOTTOM.rawValue

            // case .baseline:
            //     align |= NVG_ALIGN_BASELINE.rawValue
        }

        return Int32(align)
    }
}

public class Context {
    var context : COpaquePointer

    public init?(options: ContextOptions) {
        let flags = Int32(options.rawValue)
        context = Nano.nvgCreateGL(flags)

        if context == nil {
           print("nvgCreateGL returned nil")
           return nil
        }
    }

    deinit {
        if context != nil {
            Nano.nvgDeleteGL(context)
        }
    }

    /// Begin drawing a new frame.
    public func beginFrame(width w: CGFloat, height h: CGFloat, scale s: CGFloat) {
        nvgBeginFrame(context, Int32(w), Int32(h), Float(s))
    }

    public func beginFrame(size size: CGSize, scale: CGFloat) {
        nvgBeginFrame(context, Int32(size.width), Int32(size.height), Float(scale))
    }

    /// Cancel drawing current frame.
    public func cancelFrame() {
        nvgCancelFrame(context)
    }

    /// End drawing, flusing remaining render state.
    public func endFrame() {
        nvgEndFrame(context)
    }

    /// State handling
    public func save() {
        nvgSave(context)
    }

    public func restore() {
        nvgRestore(context)
    }

    public func reset() {
        nvgRestore(context)
    }

    /// Render style
    public func set(strokeColor c: Color) {
        nvgStrokeColor(context, c.nvgColor)
    }

    public func set(strokeWidth w: CGFloat) {
        nvgStrokeWidth(context, Float(w))
    }

    public func set(srokePaint p: NVGpaint) {
        nvgStrokePaint(context, p)
    }

    public func set(fillColor c: Color) {
        nvgFillColor(context, c.nvgColor)
    }

    public func set(filPaint p: NVGpaint) {
        nvgFillPaint(context, p)
    }

    /// Sets the miter limit of the stroke style.
    /// Miter limit controls when a sharp corner is beveled.
    public func set(miterLimit l: CGFloat) {
        nvgMiterLimit(context, Float(l))
    }

    public func set(lineCap c: UInt32) {
        nvgLineCap(context, Int32(c))
    }

    public func set(lineJoin j: UInt32) {
        nvgLineJoin(context, Int32(j))
    }

    /// Transforms
    public func resetTransform() {
        nvgResetTransform(context)
    }

    /// Translates current coordinate system.
    public func translate(dx dx: CGFloat, dy: CGFloat) {
        nvgTranslate(context, Float(dx), Float(dy))
    }

    /// Rotates current coordinate system.
    public func rotate(by angle: CGFloat) {
        nvgRotate(context, Float(angle))
    }

    /// Skews current coordinate system along X axis.
    public func skewX(by angle: CGFloat) {
        nvgSkewX(context, Float(angle))
    }

    /// Skews current coordinate system along Y axis.
    public func skewY(by angle: CGFloat) {
        nvgSkewY(context, Float(angle))
    }

    /// Scales current coordinate system.
    public func scale(x x: CGFloat, y: CGFloat) {
        nvgScale(context, Float(x), Float(y))
    }

    /// Images
    public func createImage(filename filename: String, flags: UInt32) throws -> Image? {
        let handle = nvgCreateImage(context, filename, Int32(flags))
        if handle == -1 {
            throw ContextError.InvalidPath(path:filename)
        }
        else {
            var w : Int32 = 0
            var h : Int32 = 0
            nvgImageSize(context, handle, &w, &h)

            let name = filename.lastPathComponent.deletingPathExtension

            return Image(handle:handle, name:name, size:CGSize(width:CGFloat(w), height:CGFloat(h)))
        }
    }

    public func release(image image: Image) {
        nvgDeleteImage(context, image.handle)
    }

    /// Gradients and Patterns

    /// Creates and returns a linear gradient.
    public func createLinearGradient(start start: CGPoint, end: CGPoint, startColor: Color, endColor: Color) -> NVGpaint {
        return nvgLinearGradient(context, Float(start.x), Float(start.y), Float(end.x), Float(end.y), startColor.nvgColor, endColor.nvgColor)
    }

    /// Creates and returns a box gradient.
    /// Box gradient is a feathered rounded rectangle, it is useful for rendering drop shadows or highlights for boxes.
    public func createBoxGradient(rect rect: CGRect, cornerRadius: CGFloat, feather: CGFloat, innerColor: Color, outerColor: Color) -> NVGpaint {
        return nvgBoxGradient(context,
                              Float(rect.origin.x), Float(rect.origin.y),
                              Float(rect.size.width), Float(rect.size.height),
                              Float(cornerRadius), Float(feather),
                              innerColor.nvgColor, outerColor.nvgColor)
    }

    /// Creates and returns a radial gradient.
    public func createRadialGradient(at point: CGPoint, innerRadius: CGFloat, outerRadius: CGFloat, innerColor: Color, outerColor: Color) -> NVGpaint {
        return nvgRadialGradient(context,
                                 Float(point.x), Float(point.y),
                                 Float(innerRadius), Float(outerRadius),
                                 innerColor.nvgColor, outerColor.nvgColor)
    }

    /// Creates and returns an image pattern
    public func createPattern(image image: Image, at point: CGPoint, alpha: CGFloat) -> NVGpaint {
        return nvgImagePattern(context,
                               Float(point.x), Float(point.y),
                               Float(image.size.width), Float(image.size.height),
                               0.0,
                               image.handle,
                               Float(alpha))
    }

    /// Clipping
    ///
    /// Clipping allows you to clip the rendering into a rectangle.

    public func set(clippingRegion rect: CGRect) {
        nvgScissor(context, Float(rect.origin.x), Float(rect.origin.y), Float(rect.size.width), Float(rect.size.height))
    }

    /// Sets a new clipping region, being the intersection of the current and new region.
    public func intersect(clippingRegion rect: CGRect) {
        nvgIntersectScissor(context, Float(rect.origin.x), Float(rect.origin.y), Float(rect.size.width), Float(rect.size.height))
    }

    /// Reset and disable clipping
    public func resetClipping() {
        nvgResetScissor(context)
    }

    /// Paths

    /// Clears the current path and sub-paths.
    public func beginPath() {
        nvgBeginPath(context)
    }

    /// Closes current sub-path with a line segment.
    public func closePath() {
        nvgClosePath(context)
    }

    /// Starts new sub-path with specified point as first point.
    public func move(to point: CGPoint) {
        nvgMoveTo(context, Float(point.x), Float(point.y))
    }

    /// Adds line segment from the last point in the path to the specified point.
    public func line(to point: CGPoint) {
        nvgLineTo(context, Float(point.x), Float(point.y))
    }

    /// Adds cubic bezier segment from last point in the path via two control points to the specified point.
    public func bezier(to point: CGPoint, control1 : CGPoint, control2: CGPoint) {
        nvgBezierTo(context, Float(control1.x), Float(control1.y), Float(control2.x), Float(control2.y), Float(point.x), Float(point.y))
    }

    /// Adds quadratic bezier segment from last point in the path via a control point to the specified point.
    public func quadBezier(to point: CGPoint, control : CGPoint) {
        nvgQuadTo(context, Float(control.x), Float(control.y), Float(point.x), Float(point.y))
    }

    /// Adds an arc segment at the corner defined by the last path point, and two specified points.
    public func arc(to to: CGPoint, via: CGPoint, radius: CGFloat) {
        nvgArcTo(context, Float(to.x), Float(to.y), Float(via.x), Float(via.y), Float(radius))
    }

    /// Sets the current sub-path winding, see NVGwinding and NVGsolidity.
    public func set(pathWindingDirection direction: UInt32) {
        nvgPathWinding(context, Int32(direction))
    }

    /// Creates new rectangle shaped sub-path.
    public func add(rect rect: CGRect, cornerRadius: CGFloat = 0.0) {
        if cornerRadius > 0.0 {
            nvgRoundedRect(context,
                           Float(rect.origin.x), Float(rect.origin.y),
                           Float(rect.size.width), Float(rect.size.height),
                           Float(cornerRadius))
        }
        else {
            nvgRect(context,
                    Float(rect.origin.x), Float(rect.origin.y),
                    Float(rect.size.width), Float(rect.size.height))
        }
    }

    /// Creates new circle arc shaped sub-path. The arc center is at cx,cy, the arc radius is r,
    /// and the arc is drawn from angle a0 to a1, and swept in direction dir (NVG_CCW, or NVG_CW).
    public func add(arcWithCenter center: CGPoint, fromAngle: CGFloat, toAngle: CGFloat, radius: CGFloat, direction: UInt32) {
        nvgArc(context,
               Float(center.x), Float(center.y),
               Float(radius), Float(fromAngle), Float(toAngle), Int32(direction))
    }

    /// Creates new ellipse shaped sub-path.
    public func add(ellipseWithCenter center: CGPoint, radiusX: CGFloat, radiusY: CGFloat) {
        nvgEllipse(context, Float(center.x), Float(center.y), Float(radiusX), Float(radiusY))
    }

    /// Creates new circle shaped sub-path.
    public func add(circleWithCenter center: CGPoint, radius: CGFloat) {
        nvgCircle(context, Float(center.x), Float(center.y), Float(radius))
    }

    /// Fills the current path with current fill style.
    public func fill() {
        nvgFill(context)
    }

    /// Fills the current path with the specified color.
    public func fill(withColor c: Color) {
        self.save()
        nvgFillColor(context, c.nvgColor)
        nvgFill(context)
        self.restore()
    }

    /// Fills the current path with the specified painter.
    public func fill(withPaint p: NVGpaint) {
        self.save()
        nvgFillPaint(context, p)
        nvgFill(context)
        self.restore()
    }

    /// Convenience method
    public func fill(rect rect: CGRect, withColor color: Color) {
        self.beginPath()
        self.add(rect:rect)
        self.fill(withColor:color)
    }

    /// Strokes the current path with current stroke style.
    public func stroke() {
        nvgStroke(context)
    }

    /// Strokes the current path with the specified color
    public func stroke(withColor c: Color) {
        self.save()
        nvgStrokeColor(context, c.nvgColor)
        nvgStroke(context)
        self.restore()
    }

    /// Convenience method
    public func stroke(rect rect: CGRect, withColor color: Color) {
        self.beginPath()
        self.add(rect:rect)
        self.stroke(withColor:color)
    }

    /// Fonts

    /// Creates font by loading it from the disk from specified file name.
    public func createFont(name name: String, path: String) throws -> Font {
        let handle = nvgCreateFont(context, name, path)
        if handle == -1 {
            throw ContextError.InvalidPath(path:path)
        }
        else {
            return Font(handle:handle, name:name)
        }
    }

    /// Returns an existing font, otherwise nil if the font has not been created.
    public func font(withName name: String) throws -> Font? {
        let handle = nvgFindFont(context, name)
        if handle == -1 {
            return nil
        }
        else {
            return Font(handle:handle, name:name)
        }
    }

    /// Sets the current font face and size.
    public func set(font font: Font) {
        nvgFontFaceId(context, font.handle)
        nvgFontSize(context, Float(font.size))
    }

    public func set(fontFace name: String) throws {
        if let font = try? self.font(withName:name) {
            self.set(font:font!)
        }
    }

    /// Sets the current font size.
    public func set(fontSize s: CGFloat) {
        nvgFontSize(context, Float(s))
    }

    /// Sets the blur of current text style.
    public func set(fontBlur b: CGFloat) {
        nvgFontBlur(context, Float(b))
    }

    /// Sets the letter spacing of current text style.
    public func set(textSpacing spacing: CGFloat) {
        nvgTextLetterSpacing(context, Float(spacing))
    }

    /// Sets the proportional line height of current text style. The line height is specified as multiple of font size.
    public func set(textLineHeight height: CGFloat) {
        nvgTextLineHeight(context, Float(height))
    }

    /// Sets the text align of current text style, see NVGalign for options.
    public func set(textAlignment alignment: Alignment) {
        nvgTextAlign(context, alignment.nvgAlign)
    }

    /// Draws text string at specified location. If breakWidth is > 0.0 then the text is rendered on multiple lines.
    public func draw(text str: String, at point: CGPoint, breakWidth: CGFloat = 0.0) {
        if ( breakWidth > 0.0 ) {
            nvgTextBox(context, Float(point.x), Float(point.y), Float(breakWidth), str, nil)
        }
        else {
            nvgText(context, Float(point.x), Float(point.y), str, nil)
        }
    }

    /// Measures the specified text string bounds. If breakWidth > 0.0 then the text is broken up onto multiple lines if necessary.
    public func boundsFor(text str: String, at point: CGPoint = CGPoint(), breakWidth: CGFloat = 0.0) -> CGRect {
        var bounds = [Float](count:4, repeatedValue:0.0)

        if ( breakWidth > 0.0 ) {
            nvgTextBoxBounds(context, Float(point.x), Float(point.y), Float(breakWidth), str, nil, &bounds)
        }
        else {
            nvgTextBounds(context, Float(point.x), Float(point.y), str, nil, &bounds)
        }

        let xmin = CGFloat(bounds[0])
        let ymin = CGFloat(bounds[1])
        let xmax = CGFloat(bounds[2])
        let ymax = CGFloat(bounds[3])

        return CGRect(x:xmin, y:ymin, width:xmax - xmin, height:ymax - ymin)
    }

    /// Returns the vertical metrics based on the current text style.
    public func textMetrics() -> TextMetrics {
        var ascender: Float = 0.0
        var descender: Float = 0.0
        var lineHeight: Float = 0.0

        nvgTextMetrics(context, &ascender, &descender, &lineHeight)

        return TextMetrics(ascender:CGFloat(ascender), descender:CGFloat(descender), lineHeight:CGFloat(lineHeight))
    }
}

public struct TextMetrics {
    public let ascender : CGFloat
    public let descender : CGFloat
    public let lineHeight : CGFloat
}

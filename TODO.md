# SwiftNano Task List

## Version 1.0

- [ ] Canvas drawing as part of the Screen/Window/View hierarchy.
Perhaps via a CanvasView View subclass? With a delegate method to permit custom drawing via the Context.
A Window can be created without a titleBar and with acceptsEvents = false, transparent background etc.

- [ ] Rename Screen as Canvas?

- [ ] Use OpenGL stencil buffer and "scissor" API to draw only specific versions of the screen (window, view etc).
Would permit more efficient drawing of the screen (dirty rects).

- [ ] View / Window could store OpenGL texture (for drawing performance). Only requires re-draw if nil ;-)

- [ ] Colorspace support (OpenGL??)


## Future Versions

- [ ] Integrate with SpriteKit
- [ ] Support other backend drawing APIs e.g. Metal

# An OpenGL vector graphics and GUI library based on nanovg. Implemented in Swift.

## Instructions

1. Checkout and build the dependencies (see below).

2. Build the Nano framework and add it to your project.

3. Also add the Neon framework (a dependency) to your project.
On macOS ensure both frameworks are added to an "Embed Frameworks" Build Phase.

4. Add a source file to your project to build the NanoVG OpenGL extensions for the version of OpenGL your app is using.
   To do this create a C or Objective-C file and simply include the appropriate header.
   e.g. For OpenGL3

        #import <Nano/nanovg_gl3.h>
   
5. If you're using Swift you will also need to add the same header to your bridging header. This imports the NanoVG symbols into Swift.

6. Before creating a Nano Context you must call the initialize method to set the appropriate NanoVG context creation/deletion functions:

        Nano.initalize(createContext: nvgCreateGL3, deleteContext: nvgDeleteGL3)

        let screen = Nano.Screen()
        ...


## Dependencies

Where possible dependencies are managed via the Carthage package management tool (https://github.com/Carthage/Carthage).
You can install Carthage via Homebrew ("brew install carthage").

Once installed you can fetch and build the dependencies using this command:

    carthage bootstrap --platform Mac


1. NanoVG
   (https://github.com/memononen/nanovg)

   Install via Carthage.

2. Neon
   (https://github.com/mamaral/Neon)
   A Swift based layout library.

   Install via Carthage.
   
3. Freetype v2.6.5
   (https://www.freetype.org/)

   Optional. Used for reading Adobe OFM fonts (e.g. on macOS).
   If you only need TTF support then remove FONS_USE_FREETYPE macro from the framework's Xcode Build Settings.
   
   Assumed to be installed on your system in /usr/local/ (e.g. via Homebrew).

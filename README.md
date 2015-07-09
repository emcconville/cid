# CID

An image feature detector utility for OS X's Core Image Detector library.

Cid is a *small* utility that brings Apple's built-in & embedded feature
detection algorithms to a common API. Facial, Rectangle, and QR codes are
currently supported. Facial features support blink & smile detection, and
both rectangle & QR support MBR and point detection.

## Getting

For pre-built binaries, checkout
[https://github.com/emcconville/cid/releases/latest](https://github.com/emcconville/cid/releases/latest)

## Usage

Basic usage can be described as ...

    cid <command> [arguments, ...] <inputImage>

Where `<command>` is a CoreImage Detection command, `[arguments, ...]` is one -or-
many optional flags & keyword. The final `<inputImage>` is a path to the input
image.

Use `cid help` to display full list if commands, flags, and keyword arguments.

A common task to locate, and decode, a QR Code may look like this.

    cid QR DSCF0720.JPG

Which will generate the following JSON output.

    [
      {
        "x" : 1,
        "y" : 1,
        "width" : 21,
        "height" : 21,
        "topLeft" : {
          "x" : 1,
          "y" : 22
        },
        "topRight" : {
          "x" : 22,
          "y" : 22
        },
        "bottomLeft" : {
          "x" : 1,
          "y" : 1
        },
        "bottomRight" : {
          "x" : 22,
          "y" : 1
        },
        "message" : "Hello World"
      }
    ]

Property-list, and SVG output formats are supported by defining the `-format`
keyword.

    cid QR -format plist DSCF0720.JPG

The coordinates of `cid` are given as bottom-left origin. Us `-yAxis` to switch
invert the coordinates to a top-left origin.

    cid face -yAxis inputImage.jpg

To write the output to a file, `-o <filepath>` keyword argument is provided.

    cid face -o faces.json inputImage.jpg


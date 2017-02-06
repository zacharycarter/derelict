# Package

version       = "0.1.0"
author        = "Zachary Carter"
description   = "A science-fiction roguelike."
license       = "MIT"

srcDir        = "src"
bin           = @["derelict"]

# Dependencies

requires "nim >= 0.16.1"
requires "sdl2 >= 1.1"
requires "opengl >= 1.1.0"
requires "https://github.com/krux02/nim-glm.git"
requires "ttf >= 0.2.3"
requires "https://github.com/zacharycarter/nanovg.nim.git"
requires "strfmt >= 0.8.4"
requires "https://github.com/zacharycarter/dEngine.git"
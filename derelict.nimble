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
requires "glm >= 0.1.1"

import opengl, os, sdl2, sdl2.image

import asset, log

type
  Texture* = ref object of Asset
    handle: GLuint
    filename: string
    data*: SurfacePtr

proc `bind`*(texture: Texture) =
  glBindTexture(GL_TEXTURE_2D, texture.handle)
    

proc loadTexture*(filename: string) : Asset {.procvar.} =
  if not fileExists(filename):
    logError "Unable to load texture with filename : " & filename & " file does not exist!"
    return

  var texture = Texture()
  texture.filename = filename
  texture.data = load(filename.cstring)

  if texture.data.isNil:
    logError "Error loading texture : " & $getError()
    return
    
  glGenTextures(1, addr texture.handle)

  glBindTexture(GL_TEXTURE_2D, texture.handle)
  
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA.ord, texture.data.w, texture.data.h, 0, GL_RGBA, GL_UNSIGNED_BYTE, texture.data.pixels)

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)

  glBindTexture(GL_TEXTURE_2D, 0)

  return texture

proc unloadTexture*(filename: string) {.procvar.} =
  let texture = Texture get(filename)
  if texture.isNil:
    logError "Unable to unload texture with filename : " & filename
    return
  
  glDeleteTextures(1, addr texture.handle)
  destroy(texture.data)
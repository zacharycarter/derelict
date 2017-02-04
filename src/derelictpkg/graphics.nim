import opengl, sdl2

import log, window

var rootWindow {.global.} : Window
var rootContext {.global.} : GlContextPtr

proc graphicsInit*() : bool =
  logInfo("Initializing graphics susbsystem...")
  if init(INIT_VIDEO) != SdlSuccess:
    logError("Error initializing SDL : " & $getError()) 
    return false
  
  discard glSetAttribute(SDL_GL_RED_SIZE, 1)
  discard glSetAttribute(SDL_GL_GREEN_SIZE, 1)
  discard glSetAttribute(SDL_GL_BLUE_SIZE, 1)
  discard glSetAttribute(SDL_GL_ALPHA_SIZE, 1)

  discard glSetAttribute(SDL_GL_DEPTH_SIZE, 24)
  discard glSetAttribute(SDL_GL_DOUBLEBUFFER, 1)

  discard glSetAttribute(SDL_GL_MULTISAMPLEBUFFERS, 1)
  discard glSetAttribute(SDL_GL_MULTISAMPLESAMPLES, 4)

  discard glSetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 4)
  discard glSetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 0)
  discard glSetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE)
  discard glSetAttribute(SDL_GL_CONTEXT_FLAGS, SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG)
  discard glSetAttribute(SDL_GL_CONTEXT_FLAGS, SDL_GL_CONTEXT_DEBUG_FLAG)

  rootWindow = newWindow("derelict", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 960, 540, false, true)
  if rootWindow.isNil:
    logError("Error creating root game window.")
    return false

  rootContext = glCreateContext(rootWindow.handle())
  if rootContext.isNil:
    logError("Error root opengl context.")
    return false

  if glMakeCurrent(rootWindow.handle(), rootContext) != 0:
    logError("Error setting current opengl context.")
    return false

  loadExtensions()

  glEnable(GL_DEPTH_TEST)
  glEnable(GL_CULL_FACE)
  glEnable(GL_MULTISAMPLE)
  glEnable(GL_BLEND)

  glClearColor(0.18, 0.18, 0.18, 1)

  logInfo("Graphics subsystem initialized.")
  return true

proc graphicsSwap*() =
  glSwapWindow(rootWindow.handle())

proc getWidth*() : int =
  var (width, _) = getSize(rootWindow.handle())
  return width

proc getHeight*() : int =
  var (_, height) = getSize(rootWindow.handle())
  return height

proc getFramebufferWidth*() : int =
  var w, h : cint
  glGetDrawableSize(rootWindow.handle(), w, h)
  return w
  
proc getFramebufferHeight*() : int =
  var w, h : cint
  glGetDrawableSize(rootWindow.handle(), w, h)
  return h

proc graphicsShutdown*() =
  logInfo("Shutting down graphics subsystem...")
  dispose(rootWindow)
  logInfo("Graphics subsystem shutdown.")
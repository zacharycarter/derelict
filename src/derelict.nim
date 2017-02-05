import glm, opengl, nvg

import 
  derelictpkg/asset
  , derelictpkg/dEngine
  , derelictpkg/graphics
  , derelictpkg/game
  , derelictpkg/gui/widgets
  , derelictpkg/log
  , derelictpkg/spritebatch
  , derelictpkg/texture

type
  Derelict = ref object of AbstractGame
    batch: SpriteBatch
    

proc init*(derelict: Derelict) =
  logInfo("Initializing derelict...")
  derelict.batch = newSpriteBatch(1000, nil)
  #load("assets/textures/test.png")
  load("assets/textures/megaman.png")
  
  let label = newLabel(
    "example label"
    , "orbitron"
    , nvgRGBA(255, 0, 0, 255)
    , vec2f(20, 20)
    , 18.0
    , "assets/fonts/orbitron/Orbitron Bold.ttf"
  )

  let panel = newPanel("example panel", vec2f(450 ,100), vec2f(250, 250))
  
proc update(derelict: Derelict, deltaTime: float) =
  discard

proc render(derelict: Derelict) =
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

  glViewport(0, 0, GLint getWidth(), GLint getHeight())

  #let texture = Texture get("assets/textures/test.png")
  let texture = Texture get("assets/textures/megaman.png")
  #texture.setFilter(GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR)
  derelict.batch.begin()
  derelict.batch.draw(texture, 0, 0, float texture.data.w, float texture.data.h)
  #derelict.batch.draw(newTextureRegion(texture, 0, 0, 1024, 1024), 20, 20)
  derelict.batch.`end`()

proc dispose(derelict: Derelict) =
  #unload("assets/textures/test.png")
  unload("assets/textures/megaman.png")
  

proc newGame() : Derelict =
  result = Derelict()

proc toDerelict*(derelict: Derelict) : IGame =
  return (
    init:      proc() = derelict.init()
    , update:  proc(deltaTime: float) = derelict.update(deltaTime)
    , render:  proc() = derelict.render()
    , dispose: proc() = derelict.dispose()
  )

let derelict = newGame()
let engine = newDEngine(toDerelict(derelict))
engine.start()
import glm, opengl, nvg

import derelictpkg/asset, derelictpkg/dEngine, derelictpkg/graphics, derelictpkg/gui, derelictpkg/game, derelictpkg/log, derelictpkg/perf, derelictpkg/spritebatch, derelictpkg/texture

type
  Derelict = ref object of AbstractGame
    batch: SpriteBatch
    gui: GUI
    

proc init*(derelict: Derelict) =
  logInfo("Initializing derelict...")
  derelict.batch = newSpriteBatch(1000, nil)
  derelict.gui = newGUI(true)
  #load("assets/textures/test.png")
  load("assets/textures/megaman.png")

  derelict.gui.init()

  
proc update(derelict: Derelict, deltaTime: float) =
  derelict.gui.update(deltaTime)

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

  derelict.gui.render()


proc dispose(derelict: Derelict) =
  #unload("assets/textures/test.png")
  unload("assets/textures/megaman.png")
  derelict.gui.dispose()
  

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
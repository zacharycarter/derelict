import opengl

import derelictpkg/asset, derelictpkg/dEngine, derelictpkg/game, derelictpkg/log, derelictpkg/spritebatch, derelictpkg/texture

type
  Derelict = ref object of AbstractGame
    batch: SpriteBatch

proc init*(derelict: Derelict) =
  logInfo("Initializing derelict...")
  derelict.batch = newSpriteBatch(1000, nil)
  load("assets/textures/test.png")
  load("assets/textures/bunny.png")

proc update(derelict: Derelict, deltaTime: float) =
  discard

proc render(derelict: Derelict) =
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);


  let texture = Texture get("assets/textures/test.png")
  let texture2 = Texture get("assets/textures/bunny.png")
  derelict.batch.begin()
  derelict.batch.draw(texture, 20, 20, float texture.data.w, float texture.data.h)
  derelict.batch.draw(texture2, 640, 40, float texture2.data.w, float texture2.data.h)
  derelict.batch.`end`()


proc dispose(derelict: Derelict) =
  unload("assets/textures/test.png")
  unload("assets/textures/bunny.png")

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
import glm, opengl, nvg, sdl2

import 
  asset
  , dEngine
  , event
  , graphics
  , game
  , gui/widgets
  , gui
  , log
  , spritebatch
  , texture

type
  Derelict = ref object of AbstractGame
    batch: SpriteBatch

var label : Label

var originalWidth, originalHeight : int

proc gameWindowResized(event: Event) : bool =
  case event.window.event
  of WindowEvent_Resized:
    var bounds = @[cfloat 0.0, cfloat 0.0, cfloat 0.0, cfloat 0.0]
    nvgFontFace(getContext(), "orbitron")
    nvgFontSize(getContext(), 72.0)
    let labelWidth = nvgTextBounds(getContext(), label.position.x, label.position.y, label.text, nil, addr bounds[0])
    label.bounds.left = (getWidth() / 2) - (labelWidth/2)
    if event.window.data1 > originalWidth:
      label.bounds.top = (getHeight() / 2) + (bounds[3] - bounds[1] / 2)
    else:
      label.bounds.top = (getHeight() / 2) + (bounds[3] - bounds[1]) / 2
  else:
    discard

proc init*(derelict: Derelict) =
  logInfo("Initializing derelict...")
  #derelict.batch = newSpriteBatch(1000, nil)
  #load("assets/textures/test.png")
  #load("assets/textures/megaman.png")
  
  label = newLabel(
    "dEngine"
    , "orbitron"
    , true
    , nvgRGBA(255, 255, 255, 150)
    , vec2f(getWidth()/2, getHeight()/2)
    , 72.0
    , "assets/fonts/orbitron/Orbitron Bold.ttf"
  )

  var bounds = @[cfloat 0.0, cfloat 0.0, cfloat 0.0, cfloat 0.0]
  nvgFontFace(getContext(), "orbitron")
  nvgFontSize(getContext(), 72.0)
  let labelWidth = nvgTextBounds(getContext(), label.position.x, label.position.y, label.text, nil, addr bounds[0])
  label.bounds.left -= labelWidth / 2
  label.bounds.top += (bounds[3] - bounds[1]) / 2

  let panel = newPanel("example panel", vec2f(450 ,100), vec2f(250, 250), newBoxLayout())

  layoutGUI()

  registerEventListener(gameWindowResized, @[WindowEvent])

  originalWidth = getWidth()
  originalHeight = getHeight()
  
proc update(derelict: Derelict, deltaTime: float) =
  discard

proc render(derelict: Derelict) =
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT)
  #glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

  #let texture = Texture get("assets/textures/test.png")
  #let texture = Texture get("assets/textures/megaman.png")
  #texture.setFilter(GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR)
  #derelict.batch.begin()
  #derelict.batch.draw(texture, 0, 0, float texture.data.w, float texture.data.h)
  #derelict.batch.draw(newTextureRegion(texture, 0, 0, 1024, 1024), 20, 20)
  #derelict.batch.`end`()

proc dispose(derelict: Derelict) =
  discard
  #unload("assets/textures/test.png")
  #unload("assets/textures/megaman.png")
  

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


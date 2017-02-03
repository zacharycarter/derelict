import sdl2

import asset, framerate, game, graphics, log, shader, spritebatch, texture

type
  DEngine = ref TDEngine
  TDEngine* = object
    game: IGame

proc newDEngine*(game: IGame) : DEngine =
  result = DEngine()
  result.game = game

proc initEngine() : bool =
  logInfo("Initializing engine...")
  
  if init(INIT_TIMER) != SdlSuccess:
    logError("Error initializing SDL : " & $getError()) 
    return false

  if not assetInit():
    return false

  let loadTexture : LoadFunc = texture.loadTexture
  let unloadTexture : UnloadFunc = texture.unloadTexture
  registerAssetLoader(loadTexture, unloadTexture, ".png")
  
  if not graphicsInit():
    return false
  
  logInfo("Engine initialized.")
  return true

var now : uint64 = getPerformanceCounter()
var last : uint64 = 0
var deltaTime : float64 = 0

proc runEngine(dEngine: DEngine) =
  var
    evt = sdl2.defaultEvent
    runGame = true

  while runGame:
    last = now
    now = getPerformanceCounter()
    deltaTime = float64(((now-last)*1000 div getPerformanceFrequency()))
    while pollEvent(evt):
      if evt.kind == QuitEvent:
        runGame = false
        break

    dEngine.game.update(deltaTime)

    dEngine.game.render()

    graphicsSwap()

    limitFrameRate()

proc shutdownEngine() =
  logInfo("Shutting down engine...")
  graphicsShutdown()
  sdl2.quit()
  logInfo("Engine shutdown. Goodbye.")
  quit(QUIT_SUCCESS)

proc start*(dEngine: DEngine) =
  logInfo("Starting engine...")

  if not initEngine():
    logFatal("Error initializing engine.")
    quit(QUIT_FAILURE)

  dEngine.game.init()

  runEngine(dEngine)

  dEngine.game.dispose()

  shutdownEngine()
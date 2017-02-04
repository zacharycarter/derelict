import glm, nvg

import graphics, perf

type
  Widget* = object
    position: Vec3f
    

  GUI* = object
    debug: bool
    fps, cpuGraph, gpuGraph: PerfGraph

var vg {.global.}: ptr NVGcontext = nil

proc newGUI*(debug: bool) : GUI =
  result = GUI()
  result.debug = debug

proc update*(gui: var GUI, deltaTime: float) =
  updateGraph(gui.fps, deltaTime)

proc render*(gui: GUI) =
  let pxRatio = getFramebufferWidth().cfloat / cfloat(getWidth())
  nvgBeginFrame(vg, getWidth().cint, getHeight().cint, pxRatio)
  renderGraph(vg, 5, 5, gui.fps)
  nvgEndFrame(vg)

proc dispose*(gui: GUI) =
  nvgDeleteGL3(vg)

proc init*(gui: var GUI) =
  if gui.debug:
    gui.fps = newGraph(GRAPH_RENDER_FPS, "Frame Time")

  vg = nvgCreateGL3(NVG_ANTIALIAS or NVG_STENCIL_STROKES or NVG_DEBUG)

  if vg == nil: 
    echo "Could not init nanovg."
    quit(QUIT_FAILURE)

  discard nvgCreateFont(vg, "sans", "assets/fonts/orbitron/Orbitron Bold.ttf");
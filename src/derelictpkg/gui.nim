import glm, nvg, os, tables

import graphics, log

var vg {.global.}: ptr NVGcontext = nil

var pxRatio {.global.} : float

type
  WidgetUpdateFunc = proc(deltaTime: float)
  WidgetRenderFunc = proc(widget: Widget, vgContext: ptr NVGContext)
  WidgetDisposeFunc = proc()

  Widget* = ref object of RootObj
    updateFunc*: WidgetUpdateFunc
    renderFunc*: WidgetRenderFunc
    disposeFunc*: WidgetDisposeFunc

var widgets {.global.} : seq[Widget]
var fonts {.global.} : Table[string, string]

proc registerWidget*(widget: Widget) =
  add(widgets, widget)

proc fontRegistered*(id: string) : bool =
  contains(fonts, id)

proc registerFont*(id: string, filename: string) : bool =
  if not fileExists(filename):
    logError "Unable to load font with filename : " & filename & " file does not exist."
    return false

  if nvgCreateFont(vg, id, filename) == -1:
    logError "Unable to create nanovg font with filename : " & filename
    return false

  add(fonts, id, filename)

  return true
    
proc guiUpdate*(deltaTime: float) =
  for widget in widgets:
    widget.updateFunc(deltaTime)

proc guiRender*() =
  nvgBeginFrame(vg, getWidth().cint, getHeight().cint, pxRatio)

  for widget in widgets:
    widget.renderFunc(widget, vg)

  nvgEndFrame(vg)

proc guiShutdown*() =
  for widget in widgets:
    widget.disposeFunc()
  nvgDeleteGL3(vg)

proc guiInit*() : bool =
  vg = nvgCreateGL3(NVG_ANTIALIAS or NVG_STENCIL_STROKES or NVG_DEBUG)
  pxRatio = getFramebufferWidth().cfloat / cfloat(getWidth())
  if vg == nil: 
    logError "Error initializing nanovg..."
    return false
  
  widgets = @[]
  fonts = initTable[string, string]()

  return true
import glm, nvg, os, sdl2, tables

import event, graphics, rectangle, log, gui/widget

var vg {.global.}: ptr NVGcontext = nil

var pxRatio {.global.} : float

var dragActive* {.global.} : bool = false

var widgetBeingDragged* {.global.} : Widget = nil
var widgetInFocus* {.global.} : Widget = nil
var widgets {.global.} : seq[Widget]
var fonts {.global.} : Table[string, string]

proc registerWidget*(widget: Widget) =
  add(widgets, widget)

proc contains(widget: Widget, x, y: float) : bool = 
  if widget.bounds.Contains(x, y):
    return true

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

proc findWidget(x, y: float) : Widget = 
  for widget in widgets:
    if widget.contains(x,y):
      return widget
    
proc guiUpdate*(deltaTime: float) =
  var x, y : cint
  getMouseState(x, y)
  let hoveredWidget = findWidget(float x, float y)
  
  for widget in widgets:
    widget.updateFunc(widget, deltaTime, hoveredWidget == widget)
  
  if hoveredWidget.isNil:
    cursor = createSystemCursor(SDL_SYSTEM_CURSOR_ARROW)
    setCursor(cursor)

proc guiRender*() =
  nvgBeginFrame(vg, getWidth().cint, getHeight().cint, pxRatio)

  for widget in widgets:
    widget.renderFunc(widget, vg)

  nvgEndFrame(vg)

proc guiShutdown*() =
  for widget in widgets:
    widget.disposeFunc()
  nvgDeleteGL3(vg)

proc listenForGUIEvent(event: Event) : bool =
  var eventHandled = false

  case event.kind
  of MouseMotion:
    var widget = findWidget(float event.motion.x, float event.motion.y)
    if not widget.isNil:
      widgetInFocus = widget
      eventHandled = true
    else:
      widgetInFocus = nil
    if dragActive:
      widgetBeingDragged.dragEventFunc(widgetBeingDragged, event)
      eventHandled = true
  of MouseButtonUp:
    if dragActive:
      dragActive = false
      widgetBeingDragged = nil
      eventHandled = true
  of MouseButtonDown:
    if not widgetInFocus.isNil:
      dragActive = true
      widgetBeingDragged = findWidget(float event.button.x, float event.button.y)
      eventHandled = true
    else:
      dragActive = false
      widgetBeingDragged = nil
  else:
    discard
  
  return eventHandled

proc guiInit*() : bool =
  vg = nvgCreateGL3(NVG_ANTIALIAS or NVG_STENCIL_STROKES or NVG_DEBUG)
  pxRatio = getFramebufferWidth().cfloat / cfloat(getWidth())
  if vg == nil: 
    logError "Error initializing nanovg..."
    return false
  
  widgets = @[]
  fonts = initTable[string, string]()

  registerEventListener(listenForGUIEvent, @[MouseMotion, MouseButtonDown, MouseButtonUp])

  return true
  
proc setDragActive*(active: bool) =
  dragActive = active

proc getContext*() : NVGContextPtr =
  vg

proc layoutGUI*() =
  for widget in widgets:
    var w = widget
    if not w.layout.isNil:
      w.layout.impl.execute()
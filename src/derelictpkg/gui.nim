import glm, nvg, os, sdl2, tables

import event, graphics, rectangle, log

var vg {.global.}: ptr NVGcontext = nil

var pxRatio {.global.} : float

var dragActive* {.global.} : bool = false

type
  WidgetUpdateFunc = proc(widget: Widget, deltaTime: float)
  WidgetRenderFunc = proc(widget: Widget, vgContext: ptr NVGContext)
  WidgetDragEventFunc = proc(widget: var Widget, event: Event)
  WidgetDisposeFunc = proc()

  Widget* = ref object of RootObj
    updateFunc*: WidgetUpdateFunc
    renderFunc*: WidgetRenderFunc
    dragEventFunc*: WidgetDragEventFunc
    disposeFunc*: WidgetDisposeFunc
    bounds*: Rectangle[float]
    hovered*: bool

var widgetBeingDragged* {.global.} : Widget = nil
var widgetInFocus* {.global.} : Widget = nil
var widgets {.global.} : seq[Widget]
var fonts {.global.} : Table[string, string]
var cursor* {.global.} : CursorPtr = nil

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
    
proc guiUpdate*(deltaTime: float) =
  for widget in widgets:
    widget.updateFunc(widget, deltaTime)

proc guiRender*() =
  nvgBeginFrame(vg, getWidth().cint, getHeight().cint, pxRatio)

  for widget in widgets:
    widget.renderFunc(widget, vg)

  nvgEndFrame(vg)

proc guiShutdown*() =
  for widget in widgets:
    widget.disposeFunc()
  nvgDeleteGL3(vg)

proc findWidget(x, y: float) : Widget = 
  for widget in widgets:
    if widget.contains(x,y):
      return widget

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
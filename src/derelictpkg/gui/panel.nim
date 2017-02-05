import math, glm, nvg, sdl2

import ../gui, ../rectangle, ../util

type
  ResizeMode = enum
    T, L, R, B, TL, TR, BL, BR

  Panel* = ref object of Widget
    title: string
    position, size: Vec2f
    headerBounds: Rectangle[float]
    beingResized: bool
    minWidth, minHeight: float

var currentResizeMode {.global.} : ResizeMode

proc scaleBounds(panel: Panel, x,y: float) =
  case currentResizeMode
  of L:
    panel.bounds.left += x
    panel.headerBounds.left += x
  of R:
    panel.bounds.right += x
    panel.headerBounds.right += x
  of T:
    panel.bounds.top += y
    panel.headerBounds.top += y
  of B:
    panel.bounds.bottom += y
    panel.headerBounds.bottom += y
  else:
    discard

proc translateBounds(panel: Panel, x,y: float) =
  panel.bounds = panel.bounds.Translate(x, y)
  panel.headerBounds = panel.headerBounds.Translate(x, y)

proc update(widget: Widget, deltaTime: float) {.procvar.} =
  var mouseX, mouseY : cint
  getMouseState(mouseX, mouseY)
  if widget.bounds.Contains(float mouseX, float mouseY):
    widget.hovered = true
  else:
    widget.hovered = false

  let panel = Panel widget
  
  if widget.hovered:
    var iSide = 0
    var iTopBot = 0

    if float(mouseX) <= panel.position.x + 5:
      iSide = 1
    if float(mouseX) >= (panel.position.x + panel.bounds.Width()) - 5:
      iSide = 2
    if float(mouseY) < panel.position.y + 5:
      iTopBot = 3
    if float(mouseY) > (panel.position.y + panel.bounds.Height()) - 5:
      iTopBot = 6
    
    let border = iSide + iTopBot

    case border:
    of 0:
      cursor = createSystemCursor(SDL_SYSTEM_CURSOR_SIZEALL)
      setCursor(cursor)
      panel.beingResized = false
    of 1, 2:
      cursor = createSystemCursor(SDL_SYSTEM_CURSOR_SIZEWE)
      setCursor(cursor)
      panel.beingResized = true
      if border == 1:
        currentResizeMode = L
      else:
        currentResizeMode = R
    of 3, 6:
      cursor = createSystemCursor(SDL_SYSTEM_CURSOR_SIZENS)
      setCursor(cursor)
      panel.beingResized = true
      if border == 3:
        currentResizeMode = T
      else:
        currentResizeMode = B
    of 5, 7:
      cursor = createSystemCursor(SDL_SYSTEM_CURSOR_SIZENESW)
      setCursor(cursor)
      panel.beingResized = true
      if border == 5:
        currentResizeMode = TR
      else:
        currentResizeMode = BL
    of 4, 8:
      cursor = createSystemCursor(SDL_SYSTEM_CURSOR_SIZENWSE)
      setCursor(cursor)
      panel.beingResized = true
      if border == 4:
        currentResizeMode = TL
      else:
        currentResizeMode = BR
    else:
      cursor = createSystemCursor(SDL_SYSTEM_CURSOR_SIZEALL)
      setCursor(cursor)
      panel.beingResized = false
  
  else:
    cursor = createSystemCursor(SDL_SYSTEM_CURSOR_ARROW)
    setCursor(cursor)
    panel.beingResized = false

proc dragEvent*(widget: var Widget, event: Event) =
  let panel = Panel widget

  if not panel.isNil:
    let mouseX = float event.motion.x
    let mouseY = float event.motion.y
    let relx = float event.motion.xrel
    let rely = float event.motion.yrel
    
    if not panel.beingResized:
      panel.position.x += relx
      panel.position.y += rely
      panel.translateBounds(relx, rely)
    
    else:
      case currentResizeMode
      of R:
        if mouseX >= panel.bounds.left + panel.minWidth + 5:
          panel.scaleBounds(relx, rely)
        else:
          return
      of L:
        if mouseX <= panel.bounds.right - panel.minWidth - 5:
          panel.position.x += relx
          panel.scaleBounds(relx, rely)
        else:
          return
      of T:
        if mouseY <= panel.bounds.bottom - panel.minHeight - 5:
          panel.position.y += rely
          panel.scaleBounds(relx, rely)
      of B:
        if mouseY >= panel.bounds.top + panel.minHeight + 5:
          panel.scaleBounds(relx, rely)
      else:
        discard

proc render(widget: Widget, nvgContext: ptr NVGContext) {.procvar.} =
  let panel = Panel(widget)
  
  let cornerRadius = 3.0
  var shadowPaint : NVGPaint
  var headerPaint : NVGPaint

  nvgSave(nvgContext)

  # panel
  nvgBeginPath(nvgContext)
  nvgRoundedRect(nvgContext, panel.position.x, panel.position.y, panel.bounds.Width(), panel.bounds.Height(), cornerRadius)
  nvgFillColor(nvgContext, nvgRGBA(28,30,34,192))
  nvgFill(nvgContext)

  # drop shadow
  shadowPaint = nvgBoxGradient(
    nvgContext
    , panel.position.x
    , panel.position.y + 2
    , panel.bounds.Width()
    , panel.bounds.Height()
    , cornerRadius * 2, 10
    , nvgRGBA(0,0,0,128)
    , nvgRGBA(0,0,0,0)
  )
  nvgBeginPath(nvgContext)
  nvgRect(
    nvgContext
    , panel.position.x - 10
    , panel.position.y - 10
    , panel.bounds.Width() + 20
    , panel.bounds.Height() + 30
  )
  nvgRoundedRect(
    nvgContext
    , panel.position.x
    , panel.position.y
    , panel.bounds.Width()
    , panel.bounds.Height()
    , cornerRadius
  )
  nvgPathWinding(nvgContext, NVG_HOLE.cint)
  nvgFillPaint(nvgContext, shadowPaint)
  nvgFill(nvgContext)

  # header
  headerPaint = nvgLinearGradient(
    nvgContext
    , panel.position.x
    , panel.position.y
    , panel.position.x
    , panel.position.y + 15
    , nvgRGBA(255,255,255,8)
    , nvgRGBA(0,0,0,16),
  )
  nvgBeginPath(nvgContext)
  nvgRoundedRect(
    nvgContext
    , panel.position.x + 1
    , panel.position.y + 1
    , panel.bounds.Width() - 2
    , 30
    , cornerRadius - 1
  )

#  nvgStrokeColor(nvgContext, nvgRGBA(255,0,0,255))
#  nvgBeginPath(nvgContext)
#  nvgRoundedRect(
#    nvgContext
#    , panel.headerBounds.left
#    , panel.headerBounds.top + 1
#    , panel.headerBounds.Width()
#    , panel.headerBounds.Height()
#    , cornerRadius - 1
#  )
#  nvgStroke(nvgContext)

#  nvgStrokeColor(nvgContext, nvgRGBA(255,0,0,255))
#  nvgBeginPath(nvgContext)
#  nvgRoundedRect(
#    nvgContext
#    , panel.bounds.left
#    , panel.bounds.top + 1
#    , panel.bounds.Width()
#    , panel.bounds.Height()
#    , cornerRadius - 1
#  )
#  nvgStroke(nvgContext)
  
  nvgFillPaint(nvgContext, headerPaint)
  nvgFill(nvgContext)
  nvgBeginPath(nvgContext)
  nvgMoveTo(nvgContext, panel.position.x + 0.5, panel.position.y + 0.5 + 30)
  nvgLineTo(nvgContext, panel.position.x + 0.5 + panel.bounds.Width() - 1, panel.position.y + 0.5 + 30)
  nvgStrokeColor(nvgContext, nvgRGBA(0,0,0,32))
  nvgStroke(nvgContext)

  nvgFontSize(nvgContext, 18.0)
  nvgFontFace(nvgContext, "orbitron")
  nvgTextAlign(nvgContext, NVG_ALIGN_CENTER.int or NVG_ALIGN_MIDDLE.int)

  nvgFontBlur(nvgContext, 2)
  nvgFillColor(nvgContext, nvgRGBA(0,0,0,128))
  discard nvgText(nvgContext, panel.position.x + panel.bounds.Width() / 2, panel.position.y + 16 + 1, panel.title, nil)

  nvgFontBlur(nvgContext, 0)
  nvgFillColor(nvgContext, nvgRGBA(220,220,220,160))
  discard nvgText(nvgContext, panel.position.x + panel.bounds.Width() / 2, panel.position.y + 16 + 1, panel.title, nil)

  nvgRestore(nvgContext)

proc destroy() {.procvar.} =
  discard

proc newPanel*(title: string, position, size: Vec2f, minWidth, minHeight: float = 100) : Panel =
  result = Panel()
  result.title = title
  result. position = position
  result.size = size
  result.minWidth = minWidth
  result.minHeight = minHeight
  result.updateFunc = update
  result.renderFunc = render
  result.dragEventFunc = dragEvent
  result.disposeFunc = destroy
  result.bounds = newRectangle[float](result.position.x, result.position.y, result.position.x + result.size.x, result.position.y + result.size.y)
  result.headerBounds = newRectangle[float](result.position.x, result.position.y, result.position.x + result.size.x, result.position.y + 32)
  registerWidget(result)
import glm, nvg, sdl2

import ../graphics, ../rectangle, layout

type  
  WidgetUpdateFunc = proc(widget: Widget, deltaTime: float, hovered: bool)
  WidgetRenderFunc = proc(widget: Widget, vgContext: ptr NVGContext)
  WidgetDragEventFunc = proc(widget: var Widget, event: Event)
  WidgetDisposeFunc = proc()

  Widget* = ref object of RootObj
    updateFunc*: WidgetUpdateFunc
    renderFunc*: WidgetRenderFunc
    dragEventFunc*: WidgetDragEventFunc
    disposeFunc*: WidgetDisposeFunc
    bounds*: Rectangle[float]
    position*, size*: Vec2f
    layout*: Layout

  ResizeMode* = enum
    T, L, R, B, TL, TR, BL, BR

  MovableWidget* = ref object of Widget
    movable*: IMovable

  ResizableWidget* = ref object of MovableWidget
    resizeMode*: ResizeMode
    beingResized*: bool
    minWidth*, minHeight*: float
    resizable*: IResizable

  IResizable* = object
    resize*: proc(widget: var ResizableWidget, x, y: float) {.closure.}
  
  IMovable* = object
    move*: proc(widget: var MovableWidget, x, y: float) {.closure.}

proc dragEvent*(widget: var Widget, event: Event) {.procvar.} =
  if not widget.isNil:
    var movableWidget : MovableWidget = nil
    var resizableWidget : ResizableWidget = nil

    if widget of MovableWidget:
      movableWidget = MovableWidget widget
    if widget of ResizableWidget:
      resizableWidget = ResizableWidget widget
      
    let mouseX = float event.motion.x
    let mouseY = float event.motion.y
    let relx = float event.motion.xrel
    let rely = float event.motion.yrel

    if not resizableWidget.isNil:
      if not resizableWidget.beingResized:
        resizableWidget.position.x += relx
        resizableWidget.position.y += rely
        resizableWidget.movable.move(MovableWidget resizableWidget, relx, rely)
      
      else:
        case resizableWidget.resizeMode
        of R:
          if mouseX >= resizableWidget.bounds.left + resizableWidget.minWidth + 5:
            resizableWidget.resizable.resize(resizableWidget, relx, rely)
          else:
            return
        of L:
          if mouseX <= resizableWidget.bounds.right - resizableWidget.minWidth - 5:
            resizableWidget.position.x += relx
            resizableWidget.resizable.resize(resizableWidget, relx, rely)
          else:
            return
        of T:
          if mouseY <= resizableWidget.bounds.bottom - resizableWidget.minHeight - 5:
            resizableWidget.position.y += rely
            resizableWidget.resizable.resize(resizableWidget, relx, rely)
          else:
            return
        of B:
          if mouseY >= resizableWidget.bounds.top + resizableWidget.minHeight + 5:
            resizableWidget.resizable.resize(resizableWidget, relx, rely)
          else:
            return
        else:
          discard
    
    elif not movableWidget.isNil:
      movableWidget.movable.move(movableWidget, relx, rely)
      
    


proc resize*(resizableWidget: ResizableWidget) =
  discard

proc update*(widget: Widget, deltaTime: float, hovered: bool) {.procvar.} =
  # TODO: Handle corner resizing
  var mouseX, mouseY : cint
  getMouseState(mouseX, mouseY)
  
  if hovered:
    var iSide = 0
    var iTopBot = 0

    if float(mouseX) <= widget.position.x + 5:
      iSide = 1
    if float(mouseX) >= (widget.position.x + widget.bounds.Width()) - 5:
      iSide = 2
    if float(mouseY) <= widget.position.y + 5:
      iTopBot = 3
    if float(mouseY) >= (widget.position.y + widget.bounds.Height()) - 5:
      iTopBot = 6
    
    var resizableWidget : ResizableWidget
    if widget of ResizableWidget:
      resizableWidget = ResizableWidget widget

    if not resizableWidget.isNil:
      let border = iSide + iTopBot

      case border:
      of 0:
        cursor = createSystemCursor(SDL_SYSTEM_CURSOR_SIZEALL)
        setCursor(cursor)
        resizableWidget.beingResized = false
      of 1, 2:
        cursor = createSystemCursor(SDL_SYSTEM_CURSOR_SIZEWE)
        setCursor(cursor)
        resizableWidget.beingResized = true
        if border == 1:
          resizableWidget.resizeMode = L
        else:
          resizableWidget.resizeMode = R
      of 3, 6:
        cursor = createSystemCursor(SDL_SYSTEM_CURSOR_SIZENS)
        setCursor(cursor)
        resizableWidget.beingResized = true
        if border == 3:
          resizableWidget.resizeMode = T
        else:
          resizableWidget.resizeMode = B
      of 5, 7:
        cursor = createSystemCursor(SDL_SYSTEM_CURSOR_SIZENESW)
        setCursor(cursor)
        resizableWidget.beingResized = true
        if border == 5:
          resizableWidget.resizeMode = TR
        else:
          resizableWidget.resizeMode = BL
      of 4, 8:
        cursor = createSystemCursor(SDL_SYSTEM_CURSOR_SIZENWSE)
        setCursor(cursor)
        resizableWidget.beingResized = true
        if border == 4:
          resizableWidget.resizeMode = TL
        else:
          resizableWidget.resizeMode = BR
      else:
        cursor = createSystemCursor(SDL_SYSTEM_CURSOR_SIZEALL)
        setCursor(cursor)
    else:
      cursor = createSystemCursor(SDL_SYSTEM_CURSOR_SIZEALL)
      setCursor(cursor)

proc performLayout*(widget: var Widget) {.procvar.} =
  echo "Performing layout!"
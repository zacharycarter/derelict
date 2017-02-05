import glm, nvg

import ../gui, ../log, ../rectangle, widget

type
  Label* = ref object of MovableWidget
    text: string
    textColor: NVGColor
    fontId: string
    fontSize: float

proc moveLabel(widget: var MovableWidget, x, y: float) =
  widget.bounds = widget.bounds.Translate(x,y)  

proc render(widget: Widget, nvgContext: ptr NVGContext) {.procvar.} =
  let label = Label(widget)

  nvgFontFace(nvgContext, label.fontId)
  nvgFontSize(nvgContext, label.fontSize)
  nvgFillColor(nvgContext, label.textColor)
  nvgTextAlign(nvgContext, NVG_ALIGN_LEFT.int or NVG_ALIGN_MIDDLE.int);
  discard nvgText(nvgContext, label.bounds.left, label.bounds.top + label.bounds.Height()/2, label.text, nil)

#[
  nvgStrokeColor(nvgContext, nvgRGBA(255,0,0,255))
  nvgBeginPath(nvgContext)
  nvgRect(
    nvgContext
    , label.bounds.left
    , label.bounds.top
    , label.bounds.Width()
    , label.bounds.Height()
  )
  nvgStroke(nvgContext)
]#

proc destroy() {.procvar.} =
  discard

let
  movable: IMovable = IMovable(move: moveLabel)

proc newLabel*(
    text: string
    , fontId: string
    , textColor: NVGColor = nvgRGBA(255, 255, 255, 255)
    , position: Vec2f = vec2f(0)
    , fontSize: float = 12.0
    , fontFilename: string = nil
) : Label =
  result = Label()
  result.text  = text
  result.textColor = textColor
  result.fontId = fontId
  result.fontSize = fontSize
  result.position = position
  result.updateFunc = update
  result.renderFunc = render
  result.dragEventFunc = dragEvent
  result.disposeFunc = destroy
  result.movable = movable

  if not fontRegistered(fontId):
    if fontFilename.isNil:
      logError("Font with id " & fontId & " not yet loaded. Must provide filename.")
      return
    if not registerFont(fontId, fontFilename) :
      return

  var labelBounds : seq[cfloat] = @[cfloat 0.0, cfloat 0.0, cfloat 0.0, cfloat 0.0]
  discard nvgTextBounds(getContext(), result.position.x, result.position.y, result.text, nil, addr labelBounds[0])
  result.bounds = newRectangle[float](labelBounds[0], labelBounds[1], labelBounds[2], labelBounds[3])

  registerWidget(result)
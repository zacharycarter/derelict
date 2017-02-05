import glm, nvg

import ../gui, ../log

type
  Label* = ref object of Widget
    text: string
    textColor: NVGColor
    fontId: string
    fontSize: float
    position: Vec2f

proc update(widget: Widget, deltaTime: float) {.procvar.} =
  discard

proc render(widget: Widget, nvgContext: ptr NVGContext) {.procvar.} =
  let label = Label(widget)

  nvgFontFace(nvgContext, label.fontId)
  nvgFontSize(nvgContext, label.fontSize)
  nvgFillColor(nvgContext, label.textColor)
  nvgTextAlign(nvgContext, NVG_ALIGN_LEFT.int or NVG_ALIGN_MIDDLE.int);
  discard nvgText(nvgContext, label.position.x, label.position.y, label.text, nil)


proc destroy() {.procvar.} =
  discard

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
  result.disposeFunc = destroy

  if not fontRegistered(fontId):
    if fontFilename.isNil:
      logError("Font with id " & fontId & " not yet loaded. Must provide filename.")
      return
    if not registerFont(fontId, fontFilename) :
      return
  registerWidget(result)
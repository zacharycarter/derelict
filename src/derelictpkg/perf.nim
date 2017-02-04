import
  nvg, os, strfmt

type
  GraphRenderStyle* = enum
    GRAPH_RENDER_FPS, GRAPH_RENDER_MS, GRAPH_RENDER_PERCENT

const GRAPH_HISTORY_COUNT = 100

type
  PerfGraph* = object
    renderStyle: GraphRenderStyle
    name: string
    values: array[GRAPH_HISTORY_COUNT, float]
    head: int

const GPU_QUERY_COUNT = 5

type
  GPUTimer = object
    supported: bool
    cur, ret: int
    queries: array[GPU_QUERY_COUNT, uint]

proc newGraph*(renderStyle: GraphRenderStyle, name: string) : PerfGraph =
  result = PerfGraph()
  result.renderStyle = renderStyle
  result.name = name

proc updateGraph*(graph: var PerfGraph, frameTime: float) =
  graph.head = (graph.head + 1) mod GRAPH_HISTORY_COUNT
  graph.values[graph.head] = frameTime

proc getGraphAverage(graph: PerfGraph) : float =
  var avg = 0.0
  for i in 0..<GRAPH_HISTORY_COUNT:
    avg = avg + graph.values[i]
  return avg / float(GRAPH_HISTORY_COUNT)

proc renderGraph*(vg: NVGcontextPtr, x, y: float, graph: PerfGraph) =
  let avg = getGraphAverage(graph)

  let width = 200.0
  let height = 35.0

  nvgBeginPath(vg)
  nvgRect(vg, x, y, width, height)
  nvgFillColor(vg, nvgRGBA(0,0,0,128))
  nvgFill(vg)

  nvgBeginPath(vg)
  nvgMoveTo(vg, x, y + height)
  if graph.renderStyle == GRAPH_RENDER_FPS:
    for i in 0..<GRAPH_HISTORY_COUNT:
      var v = (0.00001f + graph.values[(graph.head+i) mod GRAPH_HISTORY_COUNT])
      var vx, vy : float
      if v > 80.0: 
        v = 80.0
      vx = x + (float(i/GRAPH_HISTORY_COUNT-1)) * width
      vy = y + height - ((v / 80.0) * height)
      nvgLineTo(vg, vx, vy)
  
  nvgLineTo(vg, x + width, y + height)
  nvgFillColor(vg, nvgRGBA(255,192,0,128))
  nvgFill(vg)

  nvgFontFace(vg, "sans")
  
  if not graph.name.isNil:
    nvgFontSize(vg , 14.0)
    nvgTextAlign(vg, NVG_ALIGN_LEFT.int or NVG_ALIGN_TOP.int)
    nvgFillColor(vg, nvgRGBA(240,240,240,192))
    discard nvgText(vg, x+3, y+1, graph.name, nil)

  nvgFontSize(vg, 18.0)
  nvgTextAlign(vg, NVG_ALIGN_RIGHT.int or NVG_ALIGN_TOP.int)
  nvgFillColor(vg, nvgRGBA(240,240,240,255))
  discard nvgText(vg, x+width-3,y+1, "{:.2f} ms".fmt(avg), nil)


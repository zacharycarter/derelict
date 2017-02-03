type
  Color* = object
    r*, g*, b*, a* : float

proc newColor*(r: float, g: float, b: float, a: float) : Color =
  result = Color()
  result.r = r
  result.g = g
  result.b = b
  result.a = a
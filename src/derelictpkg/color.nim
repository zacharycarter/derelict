type
  Color* = object
    r*, g*, b*, a* : float

proc intToFloatColor(value: int) : float =
  return float(value and 0xfeffffff)

proc toFloatBits*(color: Color) : float =
  let color = (`shl`[int](int(255 * color.a), 24) or `shl`[int](int(255 * color.b), 16) or `shl`[int](int(255 * color.g), 8) or int(255 * color.r))
  return intToFloatColor(color)

proc rgba8888ToColor(value: int64) : Color =
  result = Color()
  result.r = float(`shr`[int64]((value and 0xff000000),  24)) / 255.0
  result.g = float(`shr`[int64]((value and 0x00ff0000),  16)) / 255.0
  result.b = float(`shr`[int64]((value and 0x0000ff00),  8)) / 255.0
  result.a = float(value and 0x000000ff) / 255.0

proc newColor(rgba8888: int64) : Color =
  rgba8888ToColor(rgba8888)

const WHITE* = newColor(0xffffffff)
const RED* = newColor(0xff0000ff)
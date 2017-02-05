type
  Alignment = enum
    Minimum, Middle, Maximum, Fill

  Orientation = enum
    Horizontal, Vertical
  
  Layout* {.pure inheritable.} = ref object of RootObj
    impl*: ILayout

  BoxLayout = ref object of Layout
    orientation: Orientation
    alignment: Alignment
    margin: float
    spacing: float

  ILayout = object
    execute*: proc() {.closure.}

proc executeBoxLayout*() =
  echo "Executing box layout"

proc newBoxLayout*() : BoxLayout =
  result = BoxLayout()
  result.impl = ILayout(execute:executeBoxLayout)
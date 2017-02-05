import glm

proc lerp*(v1, v2: Vec2f, alpha: float) : Vec2f =
  let invAlpha = 1.0 - alpha
  vec2f((v1.x * invAlpha) + (v2.x * alpha), (v1.y * invAlpha) + (v2.y * alpha))
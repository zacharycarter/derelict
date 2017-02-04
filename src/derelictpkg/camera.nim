import glm, opengl

type
  Camera {.pure, inheritable.} = ref object of RootObj
    viewportX, viewportY, viewportWidth, viewportHeight: int
    aspect, fov, nearClip, farClip: float
    heading, pitch: float
    maxPitchRate, maxHeadingRate: float
    moveCamera: bool
    position*, positionDelta, lookAt, direction: Vec3f
    up, mousePosition: Vec3f
    projection, view, model, mvp*: Mat4x4[GLfloat]

  OrthographicCamera* = ref object of Camera
    zoom: float

proc newOrthographicCamera*(viewportX, viewportY, viewportWidth, viewportHeight : int) : OrthographicCamera =
  result = OrthographicCamera()
  result.up = vec3f(0, 1, 0)
  result.direction = vec3f(0, 0, -1)
  result.lookAt = result.position + result.direction
  result.fov = 45
  result.positionDelta = vec3f(0)
  result.maxPitchRate = 5
  result.maxHeadingRate = 5
  result.moveCamera = false
  result.viewportX = viewportX
  result.viewportY = viewportY
  result.viewportWidth = viewportWidth
  result.viewportHeight = viewportHeight
  result.zoom = 1

proc update*(orthographicCamera: OrthographicCamera) =
  glViewport(-480, -270, GLsizei orthographicCamera.viewportWidth, GLsizei orthographicCamera.viewportHeight)
  orthographicCamera.projection = ortho[GLfloat](
    orthographicCamera.zoom * float(-orthographicCamera.viewportWidth) / 2
    , orthographicCamera.zoom * (orthographicCamera.viewportWidth / 2)
    , orthographicCamera.zoom * -(orthographicCamera.viewportHeight / 2)
    , orthographicCamera.zoom * float(orthographicCamera.viewportHeight) / 2
    , -1.0, 1.0
  )
  orthographicCamera.view = lookAt(orthographicCamera.position, orthographicCamera.position + orthographicCamera.direction, orthographicCamera.up)
  orthographicCamera.mvp = orthographicCamera.projection * orthographicCamera.view
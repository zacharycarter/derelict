import glm, opengl

import color, graphics, ibo, log, mesh, shader, texture, vbo, vertexattribute

type
  SpriteBatch* = ref object of RootObj
    vao: GLuint
    vbo: VBO
    ibo: IBO
    mesh: Mesh
    vertices: seq[GLfloat]
    maxSprites: int
    lastTexture: Texture
    projectionMatrix: Mat4x4[GLfloat]
    transformMatrix : Mat4x4[GLfloat]
    combinedMatrix: Mat4x4[GLfloat]
    shader: ShaderProgram
    color: float

proc createDefaultShader() : ShaderProgram =
  let vertexShaderSource = """
    #version 330 core
    layout (location = 0) in vec4 vertex; // <vec2 position, vec2 texCoords>

    out vec2 TexCoords;

    uniform mat4 model;
    uniform mat4 projection;

    void main()
    {
        TexCoords = vertex.zw;
        gl_Position = projection * model * vec4(vertex.xy, 0.0, 1.0);
    }
  """
  let fragmentShaderSource = """
    #version 330 core
    in vec2 TexCoords;
    out vec4 color;

    uniform sampler2D image;
    uniform vec3 spriteColor;

    void main()
    {    
        color =  texture(image, TexCoords);
    }  
  """

  let shaderProgram = newShaderProgram(vertexShaderSource, fragmentShaderSource)
  if not shaderProgram.isCompiled:
    logError "Error compiling shader : " & shaderProgram.log
  return shaderProgram

proc flush(spriteBatch: SpriteBatch) =
  if spriteBatch.lastTexture.isNil:
    return

  var m = mat4[GLfloat](1.0)
  spriteBatch.shader.setUniformMatrix("model", m)

  spriteBatch.lastTexture.`bind`()
  
  glBindVertexArray(spriteBatch.vao)

  spriteBatch.vbo.`bind`()
  spriteBatch.ibo.`bind`()

  glVertexAttribPointer(0, 4, cGL_FLOAT, GL_FALSE, 4 * sizeof(GLfloat), nil)
  glEnableVertexAttribArray(0)
  
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, spriteBatch.ibo.handle())
  glDrawElements(GL_TRIANGLES, GLsizei spriteBatch.ibo.size(),GL_UNSIGNED_SHORT,nil)

  glDisableVertexAttribArray(0)
  glBindVertexArray(0)

  spriteBatch.vbo.clear()

proc switchTexture(spriteBatch: SpriteBatch, texture: Texture) =
  flush(spriteBatch)
  spriteBatch.lastTexture = texture

proc draw*(spriteBatch: var SpriteBatch, texture: Texture, x: float, y: float, width: float, height: float) =
  if texture != spriteBatch.lastTexture:
    switchTexture(spriteBatch, texture)
  
  let vertices : seq[GLfloat] = @[
    GLfloat x, GLfloat y, GLfloat 0.0, GLfloat 0.0,
    GLfloat x, GLfloat y + height, GLfloat 0.0, GLfloat 1.0,
    GLfloat x + width, GLfloat y + height, GLfloat 1.0, GLfloat 1.0,
    GLfloat x + width, GLfloat y, GLfloat 1.0, GLfloat 0.0
  ]

  spriteBatch.vbo.add(vertices)

  if int(spriteBatch.ibo.size() / 6) >= spriteBatch.maxSprites:
    flush(spriteBatch)

proc newSpriteBatch*(maxSprites: int, defaultShader: ShaderProgram) : SpriteBatch =
  result = SpriteBatch()
  result.maxSprites = maxSprites
  result.vertices = @[]
  glGenVertexArrays(1, addr result.vao)
  result.vbo = newVBO(true)
  result.ibo = newIBO(true)
  #result.mesh = newMesh(true)

  var i = 0
  var j : GLushort = 0
  var indices : seq[GLushort] = @[]
  while i < maxSprites:
    indices.add(j)
    indices.add(j + 1)
    indices.add(j + 2)
    indices.add(j + 2)
    indices.add(j + 3)
    indices.add(j)
    inc(j, 4)
    inc(i, 6)

  result.ibo.add(indices)

  if defaultShader.isNil:
    result.shader = createDefaultShader()
  else:
    result.shader = defaultShader

  result.shader.`begin`()

  result.shader.setUniformi("image", 0)

  var p = ortho[GLfloat](0, 960, 540, 0, 0.0, 1.0)

  result.shader.setUniformMatrix("projection", p)

  result.shader.`end`()


proc begin*(spriteBatch: SpriteBatch) =
  spriteBatch.shader.begin()


proc `end`*(spriteBatch: SpriteBatch) =
  if spriteBatch.ibo.size() > 0:
    flush(spriteBatch)
  
  spriteBatch.lastTexture = nil

  spriteBatch.shader.`end`()
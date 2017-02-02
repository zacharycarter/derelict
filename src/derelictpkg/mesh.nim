import opengl

import ibo, vbo

type
  Mesh* = object
    vao: GLuint
    vbo: VBO
    ibo: IBO
    dynamic: bool

proc newMesh*(dynamic: bool) : Mesh =
  result = Mesh()
  result.dynamic = dynamic
  result.vbo = newVBO(dynamic)
  result.ibo = newIBO(dynamic)
  glGenVertexArrays(1, addr result.vao)

proc setIndices*(mesh: var Mesh, indices: seq[GLushort]) =
  mesh.ibo.setIndices(indices)

proc addVertices*(mesh: var Mesh, vertices: seq[GLfloat]) =
  mesh.vbo.add(vertices)

proc `bind`*(mesh: var Mesh) =
  glBindVertexArray(mesh.vao)
  mesh.vbo.`bind`()
  mesh.ibo.`bind`()

proc render*(mesh: var Mesh) =
  glVertexAttribPointer(0, 4, cGL_FLOAT, GL_FALSE, 4 * sizeof(GLfloat), nil)
  glEnableVertexAttribArray(0)
  
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, mesh.ibo.handle())
  glDrawElements(GL_TRIANGLES, GLsizei mesh.ibo.size(),GL_UNSIGNED_SHORT,nil)

  glDisableVertexAttribArray(0)
  glBindVertexArray(0)

  mesh.vbo.clear()

proc indexCount*(mesh: var Mesh) : int =
  return mesh.ibo.size()
import opengl

import ibo, vbo

type
  Mesh* = object
    vbo: VBO
    ibo: IBO
    dynamic: bool

proc newMesh*(dynamic: bool) : Mesh =
  result = Mesh()
  result.vbo = newVBO(dynamic)
  result.ibo = newIBO(dynamic)

proc setIndices*(mesh: var Mesh, indices: seq[GLushort]) =
  mesh.ibo.setIndices(indices)

proc setVertices*(mesh: var Mesh, vertices: seq[GLfloat]) =
  mesh.vbo.setVertices(vertices)
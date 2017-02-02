import opengl

const position*: int = 1
const colorUnpacked*: int = 2
const colorPacked*: int = 4
const normal*: int  = 8
const textureCoordinates*: int = 16

type
  VertexAttribute* = object
    usage: int
    numComponents*: int
    normalized*: bool
    `type`*: GLenum
    offset*: int
    alias*: string
    unit: int

  VertexAttributes* = object
    attributes: seq[VertexAttribute]
    vertexSize*: int

proc newVertexAttribute*(usage: int, numComponents: int, `type`: GLenum, normalized: bool, alias: string, unit: int) : VertexAttribute =
  result = VertexAttribute()
  result.usage = usage
  result.numComponents = numComponents
  result.`type` = `type`
  result.normalized = normalized
  result.alias = alias
  result.unit = unit

proc newVertexAttribute*(usage: int, numComponents: int, alias: string, unit: int) : VertexAttribute =
  if usage == colorPacked:
    return newVertexAttribute(usage, numComponents, GL_UNSIGNED_BYTE, usage == colorPacked, alias, unit) 
  else:
    return newVertexAttribute(usage, numComponents, cGL_FLOAT, usage == colorPacked, alias, unit) 

proc newVertexAttribute*(usage: int, numComponents: int, alias: string) : VertexAttribute =
  newVertexAttribute(usage, numComponents, alias, 0)

proc getSizeInBytes(vertexAttribute: VertexAttribute) : int =
  case vertexAttribute.`type`
  of cGL_FLOAT:
    return 4 * vertexAttribute.numComponents
  of cGL_UNSIGNED_BYTE:
    return vertexAttribute.numComponents
  of cGL_UNSIGNED_SHORT:
    return 2 * vertexAttribute.numComponents
  else:
    return 0

proc calculateOffsets(vertexAttributes: var VertexAttributes) : int =
  var count = 0
  for attribute in vertexAttributes.attributes.mitems:
    attribute.offset = count
    count += getSizeInBytes(attribute)

  return count

proc get*(vertexAttributes: VertexAttributes, index: int) : VertexAttribute =
  return vertexAttributes.attributes[index]

proc size*(vertexAttributes: VertexAttributes) : int =
  return vertexAttributes.attributes.len
  
proc newVertexAttributes*(attributes: varargs[VertexAttribute]) : VertexAttributes =
  result = VertexAttributes()

  var list : seq[VertexAttribute] = @[]
  for attribute in attributes:
    add(list, attribute)

  result.attributes = list
  result.vertexSize = calculateOffsets(result)
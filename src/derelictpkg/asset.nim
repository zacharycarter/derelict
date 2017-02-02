import hashes, os, tables

import log

type 
  Asset* {.pure, inheritable.} = ref object of RootObj
    name: string

  LoadFunc* = proc(filename: string) : Asset
  UnloadFunc* = proc(filename: string)

  AssetLoader = object
    load: LoadFunc
    unload: UnloadFunc
    extension: string

var assets : Table[Hash, Asset]
var assetLoaders: seq[AssetLoader]

proc assetInit*() : bool =
  assets = initTable[Hash, Asset]()
  assetLoaders = @[]
  return true

proc registerAssetLoader*(loadFunc: LoadFunc, unloadFunc: UnloadFunc, extension: string) =
  var loader = AssetLoader()
  loader.load = loadFunc
  loader.unload = unloadFunc
  loader.extension = extension
  assetLoaders.add(loader)

proc get*(filename: string) : Asset =
  if filename.isNil:
    logError "Cannot get asset with nil filename!"
    return
  
  if not contains(assets, hash(filename)):
    logWarn "Asset with filename : " & filename & " not loaded!"
    return
  
  return assets[hash(filename)]


proc load*(filename: string) =
  if filename.isNil:
    logError "Cannot load asset with nil filename!"
    return
  
  var (_, _, extension) = splitFile(filename)

  for assetLoader in assetLoaders:
    if extension == assetLoader.extension:
      let asset = assetLoader.load(filename)
      add(assets, hash(filename), asset)
      return

  logWarn("Asset loader not registered for file extension : " & extension)

proc unload*(filename: string) =
  if filename.isNil:
    logError "Cannot unload file with nil filename!"
    return
  
  var (_, _, extension) = splitFile(filename)

  for assetLoader in assetLoaders:
    if extension == assetLoader.extension:
      assetLoader.unload(filename)
      del(assets, hash(filename))
      return

  logWarn("Asset loader not registered for file extension : " & extension)
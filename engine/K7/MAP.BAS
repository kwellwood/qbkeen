DEFINT A-Z
'$INCLUDE: 'engine.bi'
'$INCLUDE: 'xms.bi'
'$INCLUDE: 'tiles.bi'
'$INCLUDE: 'player.bi'
'$INCLUDE: 'items.bi'
'$INCLUDE: 'enemies.bi'
'$INCLUDE: 'teleport.bi'
'$INCLUDE: 'lifts.bi'
'$INCLUDE: 'weapons.bi'
'$INCLUDE: 'switches.bi'
'$INCLUDE: 'render.bi'
'$INCLUDE: 'sound.bi'
'$INCLUDE: 'map.bi'
'$STATIC

CONST mapsysver = 3

ON ERROR GOTO ErrorHandler

DIM SHARED MapHandle, MapFGHandle, mapxsize, mapysize
DIM SHARED file AS STRING * 12, bitl(0) AS LONG
DIM SHARED mapidtag AS STRING * 3
'============================================================================
ErrorHandler:
e = ERR
ErrorHandlerSub e
RESUME NEXT

SUB LoadMap (file$)

f = FREEFILE
OPEN file$ FOR BINARY AS f
  '-- check file format --
  GET #f, , mapidtag
  IF mapidtag <> "CK7" THEN ErrorHandlerSub 130

  '-- map dimensions --
  GET #f, , mapxsize
  GET #f, , mapysize
 
  '-- background music --
  GET #f, , file
  IF UCASE$(RTRIM$(file)) <> "NONE" THEN
    LoadMusic UCASE$(RTRIM$(file))
  END IF

  '--- load map tile data ---
  FOR ry = 1 TO mapysize
    FOR rx = 1 TO mapxsize
      GET #f, , t1&
      GET #f, , t2&
      GET #f, , s&
      SetSwitchTag rx, ry, s&
      SetMap rx, ry, t1&
      SetMapFG rx, ry, t2&
    NEXT rx
  NEXT ry

  '--- initialize player state ---
  GET #f, , player(0).x: GET #f, , player(0).y
  player(0).xdir = left
  InitPlayerState
  FocusCamera
  UpdateClipPoints

  '-----[ Load Objects ]-----
  ClearItems
  ClearSprites
  LoadItems f
  LoadEnemies f
  LoadPortals f
  LoadPlatforms f

  '--- clear active shots ---
  ClearShots
 
  '--- reset switch values ---
  FOR s = 1 TO 25: SetSwitch s, 0: NEXT s
CLOSE f

END SUB

FUNCTION Map& (x, y)

mapxsize& = mapxsize: x& = x: y& = y
BiosXRead MapHandle, ((y& * mapxsize& - mapxsize&) + x&) * 4& - 4&, 4, VARSEG(bitl(0)), VARPTR(bitl(0))
Map& = bitl(0)

END FUNCTION

SUB MapCloseXMS

BiosXClose MapHandle
BiosXClose MapFGHandle

END SUB

FUNCTION MapFG& (x, y)

mapxsize& = mapxsize: x& = x: y& = y
BiosXRead MapFGHandle, ((y& * mapxsize& - mapxsize&) + x&) * 4& - 4&, 4, VARSEG(bitl(0)), VARPTR(bitl(0))
MapFG& = bitl(0)

END FUNCTION

SUB MapGetXMS

BiosXOpen 2048, MapHandle, a
IF a THEN ErrorHandlerSub 111

BiosXOpen 2048, MapFGHandle, a
IF a THEN ErrorHandlerSub 112

END SUB

FUNCTION MapHeight

MapHeight = mapysize

END FUNCTION

FUNCTION MapWidth

MapWidth = mapxsize

END FUNCTION

SUB SetMap (x, y, t&)

mapxsize& = mapxsize: x& = x: y& = y
bitl(0) = t&
BiosXWrite MapHandle, ((y& * mapxsize& - mapxsize&) + x&) * 4& - 4&, 4, VARSEG(bitl(0)), VARPTR(bitl(0))

END SUB

SUB SetMapFG (x, y, t&)

mapxsize& = mapxsize: x& = x: y& = y
bitl(0) = t&
BiosXWrite MapFGHandle, ((y& * mapxsize& - mapxsize&) + x&) * 4& - 4&, 4, VARSEG(bitl(0)), VARPTR(bitl(0))

END SUB


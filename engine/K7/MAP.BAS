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

DIM SHARED MapHandle, MapFGHandle, ChangingTilesHandle
DIM SHARED mapxsize, mapysize
DIM SHARED file AS STRING * 12, bitl(0) AS LONG
DIM SHARED mapidtag AS STRING * 3, lastupdate
'============================================================================
ErrorHandler:
e = ERR
ErrorHandlerSub e
RESUME NEXT

SUB AddChangingTile (x, y)

BiosXRead ChangingTilesHandle, 0, 4, VARSEG(bitl(0)), VARPTR(bitl(0)): numtiles& = bitl(0)
numtiles& = numtiles& + 1
bitl(0) = numtiles&: BiosXWrite ChangingTilesHandle, 0, 4, VARSEG(bitl(0)), VARPTR(bitl(0))

biti(0) = x: BiosXWrite ChangingTilesHandle, numtiles& * 4, 2, VARSEG(biti(0)), VARPTR(biti(0))
biti(0) = y: BiosXWrite ChangingTilesHandle, numtiles& * 4 + 2, 2, VARSEG(biti(0)), VARPTR(biti(0))

END SUB

SUB ClearChangingTiles

bitl(0) = 0: BiosXWrite ChangingTilesHandle, 0, 4, VARSEG(biti(0)), 0

END SUB

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
  ClearChangingTiles
  FOR ry = 1 TO mapysize
    FOR rx = 1 TO mapxsize
      GET #f, , t1&
      GET #f, , t2&
      GET #f, , s&
      SetSwitchTag rx, ry, s&
      SetMap rx, ry, t1&
      SetMapFG rx, ry, t2&
      IF TileType2(t2&) = 14 THEN AddChangingTile rx, ry
    NEXT rx
  NEXT ry

  '--- initialize player state ---
  GET #f, , player(0).x: GET #f, , player(0).y
  GET #f, , player(0).xdir
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
BiosXClose ChangingTilesHandle

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

BiosXOpen 2048, ChangingTilesHandle, a
IF a THEN ErrorHandlerSub 116

END SUB

FUNCTION MapHeight

MapHeight = mapysize

END FUNCTION

FUNCTION MapWidth

MapWidth = mapxsize

END FUNCTION

FUNCTION NumChangingTiles

BiosXRead ChangingTilesHandle, 0, 4, VARSEG(bitl(0)), VARPTR(bitl(0))
NumChangingTiles = bitl(0)

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

SUB UpdateChangingTiles

IF anmcounter = lastupdate THEN EXIT SUB    ' dont do twice in one animation
                                            '  clock tick

BiosXRead ChangingTilesHandle, 0, 4, VARSEG(bitl(0)), VARPTR(bitl(0)): numtiles& = bitl(0)

' x = 4 + (t& * 4 - 4)
' y = 4 + ((t& * 4 - 4) + 2)

FOR t& = 1 TO numtiles&
  BiosXRead ChangingTilesHandle, t& * 4, 2, VARSEG(biti(0)), VARPTR(biti(0)): x = biti(0)
  BiosXRead ChangingTilesHandle, t& * 4 + 2, 2, VARSEG(biti(0)), VARPTR(biti(0)): y = biti(0)

  tile& = MapFG&(x, y)
  nexttile& = SlopeMask&(tile&)
  delay = AnmLength(tile&)

  IF anmcounter \ delay = anmcounter / delay THEN SetMapFG x, y, nexttile&
NEXT t&

lastupdate = anmcounter

END SUB


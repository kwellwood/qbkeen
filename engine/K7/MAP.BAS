DEFINT A-Z
'$DYNAMIC

'$INCLUDE: 'engine.bi'
'$INCLUDE: 'directqb.bi'
'$INCLUDE: 'xms.bi'
'$INCLUDE: 'paklib.bi'
'$INCLUDE: 'plugins.bi'

ON ERROR GOTO ErrorHandler

'============================================================================
ErrorHandler:
e = ERR
ErrorHandlerSub e
RESUME NEXT

REM $STATIC
SUB LoadMap (file$)

f = FREEFILE
OPEN file$ FOR BINARY AS f
  '-- check file version --
  GET #f, , version
  IF version <> mapsysver THEN ErrorHandlerSub 130

  '-- map dimensions --
  GET #f, , mapxsize
  GET #f, , mapysize
 
  '-- background music --
  GET #f, , file(0)
  IF UCASE$(RTRIM$(file(0))) <> "NONE" THEN
    LoadMusic UCASE$(RTRIM$(file(0)))
  END IF

  '--- load map tile data ---
  FOR ry = 1 TO mapysize
    FOR rx = 1 TO mapxsize
      GET #f, , t1&
      GET #f, , t2&
      GET #f, , s&
      IF s& > 0 THEN debuglog "found switchtag" + STR$(s&) + " at" + STR$(rx) + "," + STR$(ry)
      SetSwitchTag rx, ry, s&
      SetMap rx, ry, t1&
      SetMapFG rx, ry, t2&

      '----[ Get switch tag ]----
      'IF TileType(t1&) = 4 THEN
      '  GET #f, , s                 'switch here,
      '  SetSwitchTag rx, ry, s      ' set the tag
      ' ELSE SetSwitchTag rx, ry, 0  'no swich here
      'END IF
   
    NEXT rx
  NEXT ry

  '--- initialize player state ---
  GET #f, , player(0).x: GET #f, , player(0).y
  player(0).xv = 0: player(0).yv = 0
  camera(0).x = player(0).x: camera(0).y = player(0).y
  player(0).xdir = left: player(0).action = moving
  player(0).idletime = 0
  UpdateClipPoints

  '-----[ Load Objects ]-----
  activeitemstack(0) = ""
  ClearSprites
  LoadItems f
  LoadEnemies f
  LoadPortals f
  LoadPlatforms f

  '--- clear active shots ---
  FOR s = 1 TO 5: shot(s).active = 0: NEXT s
 
  '--- reset switch values ---
  FOR s = 1 TO 25: switch(s) = 0: NEXT s
CLOSE f

END SUB

FUNCTION Map& (x, y)

BiosXRead MapHandle, ((y * mapxsize - mapxsize) + x) * 4 - 4, 4, VARSEG(bitl(0)), VARPTR(bitl(0))
Map& = bitl(0)

END FUNCTION

FUNCTION MapFG& (x, y)

BiosXRead MapFGHandle, ((y * mapxsize - mapxsize) + x) * 4 - 4, 4, VARSEG(bitl(0)), VARPTR(bitl(0))
MapFG& = bitl(0)

END FUNCTION

SUB SetMap (x, y, t&)

bitl(0) = t&
BiosXWrite MapHandle, ((y * mapxsize - mapxsize) + x) * 4 - 4, 4, VARSEG(bitl(0)), VARPTR(bitl(0))

END SUB

SUB SetMapFG (x, y, t&)

bitl(0) = t&
BiosXWrite MapFGHandle, ((y * mapxsize - mapxsize) + x) * 4 - 4, 4, VARSEG(bitl(0)), VARPTR(bitl(0))

END SUB


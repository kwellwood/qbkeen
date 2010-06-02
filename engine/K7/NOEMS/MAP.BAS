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

OPEN file$ FOR BINARY AS 1
GET #1, , version
  IF version <> mapsysver THEN ErrorHandlerSub 130

  GET #1, , mapxsize
  GET #1, , mapysize
  GET #1, , file(0)

  IF UCASE$(RTRIM$(file(0))) <> "NONE" THEN
    a = LoadFromPAK(RTRIM$(file(0)), scrbuf)
    IF a THEN ErrorHandlerSub 130 + a
    DQBput backdroppage, 0, 0, VARSEG(scr(0)), VARPTR(scr(0))
    backgroundused = 1
   ELSE backgroundused = 0
  END IF

  FOR ry = 1 TO mapysize
    FOR rx = 1 TO mapxsize
      GET #1, , t1&
      GET #1, , t2&
      bitl(0) = t1&
      BiosXWrite MapHandle, ((ry * mapxsize - mapxsize) + rx) * 4 - 4, 4, VARSEG(bitl(0)), VARPTR(bitl(0))
      bitl(0) = t2&
      BiosXWrite MapFGHandle, ((ry * mapxsize - mapxsize) + rx) * 4 - 4, 4, VARSEG(bitl(0)), VARPTR(bitl(0))
   
      '========[ SWITCHES PLUGIN ]========
      IF TileType(t1&) = 4 THEN
        GET #1, , s
        SetSwitchTag rx, ry, s
       ELSE SetSwitchTag rx, ry, 0
      END IF
      '===================================
    NEXT rx
  NEXT ry

  GET #1, , player(0).x: GET #1, , player(0).y
  player(0).xv = 0: player(0).yv = 0
  camera(0).x = player(0).x: camera(0).y = player(0).y
  player(0).xdir = left: player(0).action = moving
  UpdateClipPoints

  '========[ ITEMS PLUGIN ]========
  activeitemstack(0) = ""    'clear item stack
  ClearSprites
 
  GET #1, , numitems
  IF numitems > 255 THEN DebugLog "WARNING: Items in map <" + file$ + ">:" + STR$(numitems): numitems = 255
  FOR i = 1 TO numitems
    GET #1, , item(i).x
    GET #1, , item(i).y
    GET #1, , item(i).id
    item(i).sframe = bonus(item(i).id).sframe
    item(i).frames = bonus(item(i).id).frames
    item(i).delay = bonus(item(i).id).delay
    item(i).xsize = bonus(item(i).id).xsize
    item(i).ysize = bonus(item(i).id).ysize
    item(i).scored = 0
    activeitemstack(0) = activeitemstack(0) + CHR$(i)
  NEXT i
  '================================

  '=======[ ENEMIES PLUGIN ]=======
  activefoestack(0) = ""    'clear enemy stack
  GET #1, , numenemies
  IF numenemies > 100 THEN DebugLog "WARNING: Enemies in map <" + file$ + ">:" + STR$(numenemies): numenemies = 100
  FOR e = 1 TO numenemies
    GET #1, , enemy(e).x
    GET #1, , enemy(e).y
    GET #1, , enemy(e).id
    enemy(e).xv = 0: enemy(e).yv = 0
    enemy(e).xdir = left
    enemy(e).onground = 0
    enemy(e).onslope = 0
    enemy(e).action = 0: enemy(e).actiontime = 0
    enemy(e).status = 0: enemy(e).statustime = 0
    enemy(e).xmax = 1: enemy(e).ymax = 1
    activefoestack(0) = activefoestack(0) + CHR$(e)
    AssignEnemyFrame e
  NEXT e
  '================================

  '=======[ TELEPORT PLUGIN ]======
  numportals = 0  ' clear portals stack
  GET #1, , numportals
  IF numportals > 32 THEN DebugLog "WARNING: Portals in map <" + file$ + ">:" + STR$(numenemies): numportals = 32
  FOR p = 1 TO numportals
    GET #1, , portal(p).x
    GET #1, , portal(p).y
    GET #1, , portal(p).destx
    GET #1, , portal(p).desty
  NEXT p
  '================================

  '=======[ SWITCHES PLUGIN ]======
  FOR s = 1 TO 25: switch(s) = 0: NEXT s
  '================================
CLOSE 1

END SUB

FUNCTION Map& (x, y)

BiosXRead MapHandle, ((y * mapxsize - mapxsize) + x) * 4 - 4, 4, VARSEG(bitl(0)), VARPTR(bitl(0))
Map& = bitl(0)

END FUNCTION

FUNCTION MapFG& (x, y)

BiosXRead MapFGHandle, ((y * mapxsize - mapxsize) + x) * 4 - 4, 4, VARSEG(bitl(0)), VARPTR(bitl(0))
MapFG& = bitl(0)

END FUNCTION


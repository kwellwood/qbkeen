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
 
  a = LoadFromPAK(RTRIM$(file(0)), scrbuf)
  IF a THEN ErrorHandlerSub 130 + a
  DQBput backdroppage, 0, 0, VARSEG(scr(0)), VARPTR(scr(0))

  FOR ry = 1 TO mapysize
    FOR rx = 1 TO mapxsize
      GET #1, , t1&
      GET #1, , t2&
      bitl(0) = t1&
      BiosXWrite MapHandle, ((ry * mapxsize - mapxsize) + rx) * 4 - 4, 4, VARSEG(bitl(0)), VARPTR(bitl(0))
      bitl(0) = t2&
      BiosXWrite MapFGHandle, ((ry * mapxsize - mapxsize) + rx) * 4 - 4, 4, VARSEG(bitl(0)), VARPTR(bitl(0))
    NEXT rx
  NEXT ry
 
  GET #1, , player(0).x: GET #1, , player(0).y
  camera(0).x = player(0).x: camera(0).y = player(0).y
  player(0).xdir = right
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


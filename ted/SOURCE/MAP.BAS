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
ErrorHandlerSub 0
RESUME NEXT

CheckFile:
RESUME NEXT

REM $STATIC
SUB DrawTile (x, y, t&)
     
IF fgvisible THEN
  IF MapFG&(x, y) <> t& THEN
    SetMapFG x, y, t&
    SetSwitchTag x, y, 0
    IF TileType(t&) = 7 THEN
      DQBbox drawpage, 100, 93, 215, 105, 15
      DQBboxf drawpage, 101, 94, 214, 104, 14
      DQBprint drawpage, "Door X:", 102, 96, 71
      DrawpageToVideo
      dx = VAL(RTRIM$(LTRIM$(GetNumber$(139, 96))))
      DQBbox drawpage, 100, 110, 215, 122, 15
      DQBboxf drawpage, 101, 111, 214, 121, 14
      DQBprint drawpage, "Door Y:", 102, 113, 71
      DrawpageToVideo
      dy = VAL(RTRIM$(LTRIM$(GetNumber$(139, 113))))
      s& = (dy * mapxsize - mapxsize) + dx
      SetSwitchTag x, y, s&
    END IF
    refresh = 1
  END IF
 ELSEIF tlvisible THEN
  IF Map&(x, y) <> t& THEN
    SetMap x, y, t&
    SetSwitchTag x, y, 0
    IF TileType(t&) = 4 THEN
      DQBbox drawpage, 116, 93, 205, 105, 15
      DQBboxf drawpage, 117, 94, 204, 104, 14
      DQBprint drawpage, "Tag:", 118, 96, 71
      DrawpageToVideo
      s& = VAL(RTRIM$(LTRIM$(GetNumber$(139, 96))))
      SetSwitchTag x, y, s&
    END IF
    refresh = 1
  END IF
END IF

END SUB

SUB LoadMap (file$)

ON ERROR GOTO CheckFile
OPEN file$ FOR INPUT AS 1: fs& = LOF(1): CLOSE 1
IF fs& = 0 THEN EXIT SUB
ON ERROR GOTO ErrorHandler

OPEN file$ FOR BINARY AS 1
  GET #1, , mapidtag(0)
  IF mapidtag(0) <> "CK7" THEN ErrorHandlerSub 0

  GET #1, , mapxsize
  GET #1, , mapysize
  GET #1, , file(0)
 
  backgroundused = 0
  bgfile$ = RTRIM$(file(0))

  FOR ry = 1 TO mapysize
    FOR rx = 1 TO mapxsize
      GET #1, , t1&
      GET #1, , t2&
      GET #1, , s&
      SetSwitchTag rx, ry, s&
      SetMap rx, ry, t1&
      SetMapFG rx, ry, t2&
    NEXT rx
  NEXT ry
 
  GET #1, , player(0).x: GET #1, , player(0).y
  GET #1, , player(0).xdir
  camera(0).x = 160: camera(0).y = 100

  '-------------[ Items ]-------------
  activeitemstack(0) = ""
  unuseditemstack(0) = ""
  GET #1, , numitems
  IF numitems > 255 THEN numitems = 255
  FOR i = 1 TO numitems
    GET #1, , item(i).x
    GET #1, , item(i).y
    GET #1, , item(i).id
    activeitemstack(0) = activeitemstack(0) + CHR$(i)
  NEXT i
  FOR i = numitems + 1 TO 255
    unuseditemstack(0) = unuseditemstack(0) + CHR$(i)
  NEXT i

  '-------------[ Enemies ]-------------
  activefoestack(0) = ""
  unusedfoestack(0) = ""
  GET #1, , numenemies
  IF numenemies > 100 THEN numenemies = 100
  FOR e = 1 TO numenemies
    GET #1, , enemy(e).x
    GET #1, , enemy(e).y
    GET #1, , enemy(e).id
    activefoestack(0) = activefoestack(0) + CHR$(e)
  NEXT e
  FOR e = numenemies + 1 TO 100
    unusedfoestack(0) = unusedfoestack(0) + CHR$(e)
  NEXT e

  '-------------[ Portals ]-------------
  activeportalstack(0) = ""
  unusedportalstack(0) = ""
  GET #1, , numportals
  IF numportals > 32 THEN numportals = 32
  FOR p = 1 TO numportals
    GET #1, , portal(p).x
    GET #1, , portal(p).y
    GET #1, , portal(p).destx
    GET #1, , portal(p).desty
    activeportalstack(0) = activeportalstack(0) + CHR$(p)
  NEXT p
  FOR p = numportals + 1 TO 32
    unusedportalstack(0) = unusedportalstack(0) + CHR$(p)
  NEXT p

  '-------------[ Platforms ]-------------
  '--- load locators ---
  FOR t = 1 TO 16                 'loop through tracks
    GET #1, , numlocators(t)      'locators on this track
    FOR l = 1 TO numlocators(t)   'loop through locators
      GET #1, , locator(t, l).x
      GET #1, , locator(t, l).y
      GET #1, , locator(t, l).delay
      GET #1, , locator(t, l).locksw
    NEXT l
  NEXT t


  '--- load lifts ---
  GET #1, , numlifts
  FOR l = 1 TO numlifts
    GET #1, , lift(l).track
    GET #1, , lift(l).target
    lift(l).x = locator(lift(l).track, lift(l).target).x
    lift(l).y = locator(lift(l).track, lift(l).target).y
  NEXT l
CLOSE 1

END SUB

FUNCTION Map& (x, y)

IF x < 1 OR x > mapxsize OR y < 1 OR y > mapysize THEN Map& = 0: EXIT FUNCTION

mxs& = mapxsize: x& = x: y& = y
BiosXRead MapHandle, ((y& * mxs& - mxs&) + x&) * 4& - 4&, 4, VARSEG(bitl(0)), VARPTR(bitl(0))
Map& = bitl(0)

END FUNCTION

FUNCTION MapFG& (x, y)

IF x < 1 OR x > mapxsize OR y < 1 OR y > mapysize THEN MapFG& = 0: EXIT FUNCTION

mxs& = mapxsize: x& = x: y& = y
BiosXRead MapFGHandle, ((y& * mxs& - mxs&) + x&) * 4& - 4&, 4, VARSEG(bitl(0)), VARPTR(bitl(0))
MapFG& = bitl(0)

END FUNCTION

SUB NewMap

' ==== RESET MAP ARRAYS ====
FOR y = 1 TO mapysize
  FOR x = 1 TO mapxsize
    SetMap x, y, 0         ' map layer
    SetMapFG x, y, 0       ' foreground
    SetSwitchTag x, y, 0   ' switches
  NEXT x
NEXT y

' ==== RESET BACKGROUND ====
bgfile$ = ""

' ==== RESET PLAYER AND CAMERA ====
player(0).x = 40: player(0).y = 40
camera(0).x = 160: camera(0).y = 100

' ==== RESET ITEMS ====
activeitemstack(0) = ""
unuseditemstack(0) = ""
FOR i = 1 TO 255: unuseditemstack(0) = unuseditemstack(0) + CHR$(i): NEXT i
 
' ==== RESET ENEMIES ====
activefoestack(0) = ""
unusedfoestack(0) = ""
FOR e = 1 TO 100: unusedfoestack(0) = unusedfoestack(0) + CHR$(e): NEXT e

' ==== RESET PORTALS ====
activeportalstack(0) = ""
unusedportalstack(0) = ""
FOR p = 1 TO 32: unusedportalstack(0) = unusedportalstack(0) + CHR$(p): NEXT p

' ==== RESET LIFTS ====
FOR t = 1 TO 16: numlocators(t) = 0: NEXT t
numlifts = 0

END SUB

SUB ReplaceTile (t1&, t2&)

FOR x = 1 TO mapxsize
  FOR y = 1 TO mapysize
    IF Map&(x, y) = t1& THEN SetMap x, y, t2&
    IF MapFG&(x, y) = t1& THEN SetMapFG x, y, t2&
  NEXT y
NEXT x

END SUB

SUB SaveMap (file$)

IF INSTR(file$, "\") THEN file$ = "error.map"

OPEN file$ FOR BINARY AS 1
  mapidtag(0) = "CK7"
  PUT #1, , mapidtag(0)

  PUT #1, , mapxsize
  PUT #1, , mapysize
  file(0) = bgfile$
  PUT #1, , file(0)

  FOR ry = 1 TO mapysize
    FOR rx = 1 TO mapxsize
      t1& = Map&(rx, ry)
      t2& = MapFG&(rx, ry)
      s& = SwitchTag&(rx, ry)
      PUT #1, , t1&
      PUT #1, , t2&
      PUT #1, , s&
    NEXT rx
  NEXT ry

  PUT #1, , player(0).x: PUT #1, , player(0).y
  PUT #1, , player(0).xdir

  numitems = LEN(activeitemstack(0))
  PUT #1, , numitems
  FOR i = 1 TO LEN(activeitemstack(0))
    k = ASC(MID$(activeitemstack(0), i, 1))
    PUT #1, , item(k).x
    PUT #1, , item(k).y
    PUT #1, , item(k).id
  NEXT i

  numenemies = LEN(activefoestack(0))
  PUT #1, , numenemies
  FOR e = 1 TO LEN(activefoestack(0))
    k = ASC(MID$(activefoestack(0), e, 1))
    PUT #1, , enemy(k).x
    PUT #1, , enemy(k).y
    PUT #1, , enemy(k).id
  NEXT e

  numportals = LEN(activeportalstack(0))
  PUT #1, , numportals
  FOR p = 1 TO numportals
    k = ASC(MID$(activeportalstack(0), p, 1))
    PUT #1, , portal(k).x
    PUT #1, , portal(k).y
    PUT #1, , portal(k).destx
    PUT #1, , portal(k).desty
  NEXT p

  '-------------[ Platforms ]-------------
  '--- load locators ---
  FOR t = 1 TO 16                 'loop through tracks
    PUT #1, , numlocators(t)      'locators on this track
    FOR l = 1 TO numlocators(t)   'loop through locators
      PUT #1, , locator(t, l).x
      PUT #1, , locator(t, l).y
      PUT #1, , locator(t, l).delay
      PUT #1, , locator(t, l).locksw
    NEXT l
  NEXT t

  '--- load lifts ---
  PUT #1, , numlifts
  FOR l = 1 TO numlifts
    PUT #1, , lift(l).track
    PUT #1, , lift(l).target
    lift(l).x = locator(lift(l).track, lift(l).target).x
    lift(l).y = locator(lift(l).track, lift(l).target).y
  NEXT l
CLOSE 1

END SUB

SUB SetMap (x, y, t&)

bitl(0) = t&
mxs& = mapxsize: x& = x: y& = y
BiosXWrite MapHandle, ((y& * mxs& - mxs&) + x&) * 4& - 4&, 4, VARSEG(bitl(0)), VARPTR(bitl(0))

END SUB

SUB SetMapFG (x, y, t&)

mxs& = mapxsize: x& = x: y& = y
bitl(0) = t&
BiosXWrite MapFGHandle, ((y& * mxs& - mxs&) + x&) * 4& - 4&, 4, VARSEG(bitl(0)), VARPTR(bitl(0))

END SUB


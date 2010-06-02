DEFINT A-Z
'$DYNAMIC

'$INCLUDE: 'engine.bi'
'$INCLUDE: 'directqb.bi'
'$INCLUDE: 'xms.bi'
'$INCLUDE: 'paklib.bi'
'$INCLUDE: 'plugins.bi'

RANDOMIZE TIMER
ON ERROR GOTO ErrorHandler
IF UCASE$(COMMAND$) = "NOEMS" THEN ems = 0 ELSE ems = 1
a = DQBinit(ems * 1, 0, 0): IF a THEN ErrorHandlerSub 0
a = InitPAKLib: IF a THEN ErrorHandlerSub 0
AllocXMS

'--------- Core Engine ---------
DIM SHARED player(0) AS playertype, scr(32004), file(0) AS STRING * 12
DIM SHARED biti(0) AS INTEGER, bitl(0) AS LONG, Pal(255) AS hues
DIM SHARED matrix(0, 0) AS LONG, matrixoffset(0) AS intcoordinate
DIM SHARED mapidtag(0) AS STRING * 3

'-------- Render System --------
DIM SHARED camera(0) AS camtype

'--------- Items System --------
DIM SHARED item(1 TO 255) AS itemclass, bonus(1 TO 13) AS itemtypeclass
DIM SHARED activeitemstack(0) AS STRING, unuseditemstack(0) AS STRING

'------- Enemies System --------
DIM SHARED enemy(100) AS enemytype, eframe(numenemytypes) AS LONG
DIM SHARED activefoestack(0) AS STRING, unusedfoestack(0) AS STRING
DIM SHARED efsize(numenemytypes) AS intcoordinate

'------- Teleport System -------
DIM SHARED portal(1 TO 32) AS portaltype, activeportalstack(0) AS STRING
DIM SHARED unusedportalstack(0) AS STRING

'--------- Lift System ---------
DIM SHARED locator(1 TO 16, 1 TO 16) AS locatortype, numlocators(1 TO 16)
DIM SHARED lift(1 TO 16) AS lifttype

PRINT "Loading..."
InitEngine
LoadTiles
InitItems
InitEnemies
InitLifts
LoadMap "default.map"

ClosePAKLib


DQBinitVGA: SCREEN 13
SetPalette
DQBresetMouse
DQBsetMousePos 160, 100
DQBmouseShow

MainLoop

DQBinitText
SCREEN 0: WIDTH 80, 25
DQBremoveKeyboard
DeallocXMS
DQBclose
END

'============================================================================
ErrorHandler:
e = ERR
ErrorHandlerSub 0
RESUME NEXT

REM $STATIC
SUB AllocXMS

'===========[ Tiles System ]===========
BiosXOpen 16, TileTypeHandle, a
IF a THEN ErrorHandlerSub 0
BiosXOpen 16, TileType2Handle, a
IF a THEN ErrorHandlerSub 0
BiosXOpen 16, AnmLengthHandle, a
IF a THEN ErrorHandlerSub 0
BiosXOpen 16, AnmDelayHandle, a
IF a THEN ErrorHandlerSub 0

'=========[ Graphics System ]==========
BiosXOpen 4096, ArtHandle, a
IF a THEN ErrorHandlerSub 0
BiosXOpen 32, ArtOffSetHandle, a
IF a THEN ErrorHandlerSub 0
BiosXOpen 32, ArtLengthHandle, a
IF a THEN ErrorHandlerSub 0

'============[ Map System ]============
BiosXOpen 2048, MapHandle, a
IF a THEN ErrorHandlerSub 0
BiosXOpen 2048, MapFGHandle, a
IF a THEN ErrorHandlerSub 0

'=========[ Switches Plugin ]===========
BiosXOpen 2048, SwitchTagHandle, a
IF a THEN ErrorHandlerSub 0

END SUB

SUB DeallocXMS

'===========[ Tiles System ]===========
BiosXClose TileTypeHandle
BiosXClose TileType2Handle
BiosXClose AnmLengthHandle
BiosXClose AnmDelayHandle

'=========[ Graphics System ]==========
BiosXClose ArtHandle
BiosXClose ArtOffSetHandle
BiosXClose ArtLengthHandle

'============[ Map System ]============
BiosXClose MapHandle
BiosXClose MapFGHandle

'=========[ Switches Plugin ]==========
BiosXClose SwitchTagHandle

END SUB

SUB DebugLog (t$)

'IF UCASE$(COMMAND$) = "-LOG" THEN
  ff = FREEFILE
  OPEN "debug.log" FOR APPEND AS ff
    t$ = "TIME: " + LTRIM$(RTRIM$(STR$(TIMER))) + "  ACTION: " + t$
    PRINT #ff, t$
  CLOSE ff
'END IF

END SUB

SUB DoInput

'objmode tags:
'0 tiles
'1 matrix
'2 item
'3 enemy
'4 player start
'5 teleport
'6 locator
'7 lift
'8 set location tag (switchtag)

'================[ KEYBOARD INPUT ]================
IF DQBkey(KEYRIGHT) THEN camera(0).x = camera(0).x + scrollspeed: refresh = 1
IF DQBkey(KEYLEFT) THEN camera(0).x = camera(0).x - scrollspeed: refresh = 1
IF DQBkey(keyup) THEN camera(0).y = camera(0).y - scrollspeed: refresh = 1
IF DQBkey(keydown) THEN camera(0).y = camera(0).y + scrollspeed: refresh = 1

IF DQBkey(2) THEN
  IF tlvisible = 1 THEN tlvisible = 0 ELSE tlvisible = 1
  WHILE DQBkey(2): WEND
  refresh = 1
 ELSEIF DQBkey(3) THEN
  IF fgvisible = 1 THEN fgvisible = 0 ELSE fgvisible = 1
  WHILE DQBkey(3): WEND
  refresh = 1
END IF

IF DQBkey(12) THEN
  Zoom = Zoom - 4 '/2
  IF Zoom < 4 THEN Zoom = 4
  WHILE DQBkey(12): WEND
  refresh = 1
 ELSEIF DQBkey(13) THEN
  Zoom = Zoom + 4 '*2
  IF Zoom > ts THEN Zoom = ts
  WHILE DQBkey(13): WEND
  refresh = 1
END IF
'IF DQBkey(59) THEN
'  IF DisplayHud = 1 THEN DisplayHud = 0 ELSE DisplayHud = 1
'  WHILE DQBkey(59): WEND
'  refresh = 1
'END IF
IF DQBkey(20) THEN
  WHILE DQBkey(20): WEND
  SelectTile
  refresh = 1
END IF

IF placingportal THEN
  IF DQBmouseLB THEN
    x = (DQBmouseX + camera(0).vx1) * (ts / Zoom)
    y = (DQBmouseY + camera(0).vy1) * (ts / Zoom)
    SetPortalDest placingportal, x, y
    placingportal = 0
    WHILE DQBmouseLB: WEND
    refresh = 1
  END IF
  EXIT SUB
END IF

IF DQBkey(keyesc) AND TIMER >= keypress! THEN
  IF gamemode = ingame THEN gamemode = inmenu ELSE gamemode = ingame
  keypress! = TIMER + .25
  refresh = 1
END IF

IF DQBkey(KEYDELETE) THEN
  x = (DQBmouseX + camera(0).vx1) * (ts / Zoom)
  y = (DQBmouseY + camera(0).vy1) * (ts / Zoom)
  DeleteItem x, y
  DeleteEnemy x, y
  DeletePortal x, y
  DeleteLift x, y
  DeleteLocator x, y
  WHILE DQBkey(KEYDELETE): WEND
  refresh = 1
END IF

'==================[ MOUSE INPUT ]=================
IF DQBmouseLB THEN
  llcx = DQBmouseX: llcy = DQBmouseY
  IF gamemode = ingame OR (llcy >= 18) THEN
    SELECT CASE objmode
     CASE 0
      llcx = (llcx + camera(0).vx1) * (ts / Zoom): llcy = (llcy + camera(0).vy1) * (ts / Zoom)
      mx = INT(llcx / ts) + 1: my = INT(llcy / ts) + 1
      IF mx > 0 AND mx <= mapxsize AND my > 0 AND my <= mapysize THEN
        DrawTile mx, my, pentile&
      END IF
     CASE 1
      llcx = (llcx + camera(0).vx1) * (ts / Zoom): llcy = (llcy + camera(0).vy1) * (ts / Zoom)
      mx = INT(llcx / ts) + 1: my = INT(llcy / ts) + 1
      IF mx > 0 AND mx <= mapxsize AND my > 0 AND my <= mapysize THEN
        mx2 = mx + matrixoffset(curitem).x
        my2 = my + matrixoffset(curitem).y
        dx = mx2 MOD mxsize: IF dx = 0 THEN dx = mxsize
        dy = my2 MOD mysize: IF dy = 0 THEN dy = mysize
        DrawTile mx, my, matrix(dx, dy)
      END IF
     CASE 2
      x = (llcx + camera(0).vx1) * (ts / Zoom)
      y = (llcy + camera(0).vy1) * (ts / Zoom)
      IF gridsnapitems THEN
        x = (INT(x / ts) + 1) * ts - (ts / 2)
        y = (INT(y / ts) + 1) * ts - (ts / 2)
      END IF
      AddItem x, y, curitem
      WHILE DQBmouseLB: WEND
      refresh = 1
     CASE 3
      ex = (llcx + camera(0).vx1) * (ts / Zoom)
      ey = (llcy + camera(0).vy1) * (ts / Zoom)
      IF gridsnapitems THEN
        IF curitem >= spearup AND curitem <= spearright THEN
          ex = (INT(ex / ts) + 1) * ts - (ts / 2)
          ey = (INT(ey / ts) + 1) * ts - (ts / 2)
         ELSEIF curitem = shooterdown OR curitem = shooterleft THEN
          ex = (INT(ex / ts) + 1) * ts - (ts / 2)
          ey = (INT(ey / ts) + 1) * ts - (ts / 2)
         ELSEIF curitem = shooterup THEN
          ex = (INT(ex / ts) + 1) * ts - (ts / 2)
          ey = (INT(ey / ts) + 1) * ts
         ELSEIF curitem = shooterright THEN
          ex = (INT(ex / ts) + 1) * ts
          ey = (INT(ey / ts) + 1) * ts - (ts / 2)
        END IF
      END IF
      SpawnEnemy ex, ey, curitem
      WHILE DQBmouseLB: WEND
      refresh = 1
     CASE 4
      player(0).x = (llcx + camera(0).vx1) * (ts / Zoom): player(0).y = (llcy + camera(0).vy1) * (ts / Zoom)
      GroundPlayer
      IF DQBkey(KEYLEFT) THEN
        player(0).xdir = left
        WHILE DQBkey(KEYLEFT): WEND
       ELSEIF DQBkey(KEYRIGHT) THEN
        player(0).xdir = right
        WHILE DQBkey(KEYRIGHT): WEND
      END IF
      refresh = 1
     CASE 5
      x = (llcx + camera(0).vx1) * (ts / Zoom)
      y = (llcy + camera(0).vy1) * (ts / Zoom)
      placingportal = AddPortal(x, y)
      objmode = 0
      DQBmouseHide
      WHILE DQBmouseLB: WEND
      DQBmouseShow
      refresh = 1
     CASE 6
      x = (llcx + camera(0).vx1) * (ts / Zoom)
      y = (llcy + camera(0).vy1) * (ts / Zoom)
      DQBmouseHide
      AddLocator x, y
      WHILE DQBmouseLB: WEND
      DQBmouseShow
      refresh = 1
     CASE 7
      x = (llcx + camera(0).vx1) * (ts / Zoom)
      y = (llcy + camera(0).vy1) * (ts / Zoom)
      AddLift x, y
      objmode = 0
      DQBmouseHide
      WHILE DQBmouseLB: WEND
      DQBmouseShow
      refresh = 1
     CASE 8
      IF Zoom = ts THEN
        mx = INT((llcx + camera(0).vx1) / ts) + 1
        my = INT((llcy + camera(0).vy1) / ts) + 1
        DQBbox drawpage, 116, 93, 205, 105, 15
        DQBboxf drawpage, 117, 94, 204, 104, 14
        DQBprint drawpage, "Tag:", 118, 96, 71
        DrawpageToVideo
        s& = VAL(GetNumber$(139, 96))
        SetSwitchTag mx, my, s&
        refresh = 1
      END IF
    END SELECT
   ELSEIF gamemode = inmenu THEN HandleMenuInput llcx, llcy, left
  END IF
END IF

IF DQBmouseRB THEN
  lrcx = DQBmouseX: lrcy = DQBmouseY
  IF gamemode = ingame OR (lrcy >= 18) THEN
    lrcx = (lrcx + camera(0).vx1) * (ts / Zoom): lrcy = (lrcy + camera(0).vy1) * (ts / Zoom)
    mx = INT(lrcx / ts) + 1: my = INT(lrcy / ts) + 1
    IF mx > 0 AND mx <= mapxsize AND my > 0 AND my <= mapysize THEN
      IF fgvisible THEN
        pentile& = MapFG&(mx, my)
        refresh = 1
       ELSEIF tlvisible THEN
        pentile& = Map&(mx, my)
        refresh = 1
      END IF
    END IF
   ELSEIF gamemode = inmenu THEN HandleMenuInput lrcx, lrcy, right
  END IF
END IF

END SUB

SUB DrawpageToVideo

DQBmouseHide
DQBcopyLayer drawpage, video
DQBmouseShow

END SUB

SUB ErrorHandlerSub (e)

DQBinitText
SCREEN 0: WIDTH 80, 25

PRINT "Error"; e

DQBremoveKeyboard
DeallocXMS
DQBclose
END

END SUB

SUB GroundPlayer

mx = INT(player(0).x / ts) + 1: my = INT((player(0).y + player(0).ysize / 2) / ts) + 1

DO
  my = my + 1
LOOP WHILE TileType(Map&(mx, my)) = 0 AND TileType(MapFG&(mx, my)) = 0 AND my <= mapysize

IF my > mapysize THEN EXIT SUB

my = my - 1
player(0).y = (my * ts - 1) - (player(0).ysize / 2) - 1

END SUB

SUB InitEngine

SELECT CASE ems
 CASE 0: drawpage = 0
 CASE 1: drawpage = 1
END SELECT


OPEN "engine.dat" FOR INPUT AS 1
  INPUT #1, ver
  IF ver <> enginever THEN ErrorHandlerSub 0
  INPUT #1, ts
  INPUT #1, maxfps
  INPUT #1, tileset$
  INPUT #1, scrollspeed
  INPUT #1, matrices
  INPUT #1, player(0).xsize
  INPUT #1, player(0).ysize
  player(0).xdir = left
CLOSE 1

citem = 0
StartTile& = 1
Zoom = ts
objmode = 0
curitem = 0
REDIM matrixoffset(matrices) AS intcoordinate

DEF SEG = VARSEG(Pal(0))
BLOAD "palette.dat", 0
DEF SEG

a = DQBloadFont("font.dat")
IF a THEN ErrorHandlerSub 0

DQBinstallKeyboard

gamemode = ingame
pentile& = 0
tlvisible = 1
fgvisible = 0

END SUB

SUB MainLoop

refresh = 1

DO
  DoInput
  IF refresh OR DQBkey(59) THEN
    refresh = 0
    DoCamera
    DrawScreen
  END IF
LOOP UNTIL quitgame

END SUB

SUB SetPalette

OUT &H3C8, 0

FOR i = 0 TO 255
  OUT &H3C9, Pal(i).red: OUT &H3C9, Pal(i).grn: OUT &H3C9, Pal(i).blu
NEXT

END SUB


DEFINT A-Z
'$DYNAMIC

'$INCLUDE: 'engine.bi'
'$INCLUDE: 'directqb.bi'
'$INCLUDE: 'xms.bi'
'$INCLUDE: 'paklib.bi'
'$INCLUDE: 'plugins.bi'

RANDOMIZE TIMER
ON ERROR GOTO ErrorHandler
a = DQBinit(4, 0, 0): IF a THEN ErrorHandlerSub 0
a = InitPAKLib: IF a THEN ErrorHandlerSub 0
AllocXMS

'--------- Core Engine ---------
DIM SHARED player(0) AS playertype, scr(32004), file(0) AS STRING * 12
DIM SHARED biti(0) AS INTEGER, bitl(0) AS LONG, pal(255) AS hues

'-------- Render System --------
DIM SHARED camera(0) AS camtype

InitEngine
LoadTiles
LoadMap "test.map"

DQBinitVGA: SCREEN 13
SetPalette

MainLoop

DQBinitText
SCREEN 0: WIDTH 80, 25
DQBremoveKeyboard
DeallocXMS
ClosePAKLib
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
BiosXOpen 4, TileTypeHandle, a
IF a THEN ErrorHandlerSub 0
BiosXOpen 4, AnmLengthHandle, a
IF a THEN ErrorHandlerSub 0
BiosXOpen 4, AnmDelayHandle, a
IF a THEN ErrorHandlerSub 0

'=========[ Graphics System ]==========
BiosXOpen 2048, ArtHandle, a
IF a THEN ErrorHandlerSub 0
BiosXOpen 8, ArtOffsetHandle, a
IF a THEN ErrorHandlerSub 0
BiosXOpen 8, ArtLengthHandle, a
IF a THEN ErrorHandlerSub 0

'============[ Map System ]============
BiosXOpen 1024, MapHandle, a
IF a THEN ErrorHandlerSub 0
BiosXOpen 1024, MapFGHandle, a
IF a THEN ErrorHandlerSub 0

END SUB

SUB DeallocXMS

'===========[ Tiles System ]===========
BiosXClose TileTypeHandle
BiosXClose AnmLengthHandle
BiosXClose AnmDelayHandle

'=========[ Graphics System ]==========
BiosXClose ArtHandle
BiosXClose ArtOffsetHandle
BiosXClose ArtLengthHandle

'============[ Map System ]============
BiosXClose MapHandle
BiosXClose MapFGHandle

END SUB

SUB DoInput

IF DQBkey(keyright) THEN player(0).x = player(0).x + 2
IF DQBkey(keyleft) THEN player(0).x = player(0).x - 2
IF DQBkey(keyup) THEN player(0).y = player(0).y - 2
IF DQBkey(keydown) THEN player(0).y = player(0).y + 2
IF DQBkey(keyesc) THEN quitgame = 1

IF player(0).x < 0 THEN player(0).x = 0
IF player(0).y < 0 THEN player(0).y = 0
IF player(0).x > (mapxsize * ts) - 1 THEN player(0).x = (mapxsize * ts) - 1
IF player(0).y > (mapysize * ts) - 1 THEN player(0).y = (mapysize * ts) - 1

END SUB

SUB ErrorHandlerSub (e)

DQBinitText
SCREEN 0: WIDTH 80, 25

PRINT "Error"; e

DQBremoveKeyboard
DeallocXMS
ClosePAKLib
DQBclose
END

END SUB

SUB InitEngine

OPEN "engine.dat" FOR INPUT AS 1
  INPUT #1, ver
  IF ver <> enginever THEN ErrorHandlerSub 0
  INPUT #1, ts
  INPUT #1, maxfps
  INPUT #1, player(0).xmax
  INPUT #1, player(0).ymax
  INPUT #1, player(0).xsize
  INPUT #1, player(0).ysize
CLOSE 1

DEF SEG = VARSEG(pal(0))
BLOAD "palette.dat", 0
DEF SEG

a = DQBloadFont("font.dat")
IF a THEN ErrorHandlerSub 0

DQBinstallKeyboard

END SUB

SUB MainLoop

DO
  'DoInput
  'DoPhysics
  'DoTimers
  DoInput
  DoCamera
  DrawScreen
LOOP UNTIL quitgame

END SUB

SUB SetPalette

OUT &H3C8, 0

FOR i = 0 TO 255
  OUT &H3C9, pal(i).red: OUT &H3C9, pal(i).grn: OUT &H3C9, pal(i).blu
NEXT

END SUB


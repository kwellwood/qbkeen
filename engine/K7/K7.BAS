DEFINT A-Z
'$DYNAMIC

'$INCLUDE: 'engine.bi'
'$INCLUDE: 'directqb.bi'
'$INCLUDE: 'xms.bi'
'$INCLUDE: 'paklib.bi'
'$INCLUDE: 'plugins.bi'

RANDOMIZE TIMER
ON ERROR GOTO ErrorHandler
a = DQBinit(4, 0, 0): IF a THEN ErrorHandlerSub 99 + a
a = InitPAKLib: IF a THEN ErrorHandlerSub 104
AllocXMS

'--------- Core Engine ---------
DIM SHARED player(0) AS playertype, scr(32004), file(0) AS STRING * 12
DIM SHARED biti(0) AS INTEGER, bitl(0) AS LONG, pal(255) AS hues
DIM SHARED pframe(11) AS LONG

'-------- Render System --------
DIM SHARED camera(0) AS camtype

InitEngine
InitMenu
LoadTiles
LoadMap "keen16.map"

DQBinitVGA: SCREEN 13
SetPalette

MainLoop

DQBinitText
SCREEN 0: WIDTH 80, 25
DQBremoveKeyboard
DeallocXMS
ClosePAKLib
DQBclose
PRINT "Powered by K7 Engine technology (Build 3B)."
PRINT "K7 Engine (c) Kevin Wellwood 2000": PRINT
PRINT "Compiled November 10, 2000"
END

'============================================================================
ErrorHandler:
e = ERR
ErrorHandlerSub e
RESUME NEXT

REM $STATIC
SUB AllocXMS

'===========[ Tiles System ]===========
BiosXOpen 4, TileTypeHandle, a
IF a THEN ErrorHandlerSub 105
BiosXOpen 4, AnmLengthHandle, a
IF a THEN ErrorHandlerSub 106
BiosXOpen 4, AnmDelayHandle, a
IF a THEN ErrorHandlerSub 107

'=========[ Graphics System ]==========
BiosXOpen 2048, ArtHandle, a
IF a THEN ErrorHandlerSub 108
BiosXOpen 8, ArtOffsetHandle, a
IF a THEN ErrorHandlerSub 109
BiosXOpen 8, ArtLengthHandle, a
IF a THEN ErrorHandlerSub 110

'============[ Map System ]============
BiosXOpen 1024, MapHandle, a
IF a THEN ErrorHandlerSub 111
BiosXOpen 1024, MapFGHandle, a
IF a THEN ErrorHandlerSub 112

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

SELECT CASE gamemode
 CASE ingame
  IF DQBkey(keyright) THEN MovePlayer right
  IF DQBkey(keyleft) THEN MovePlayer left
  IF DQBkey(keyup) THEN MovePlayer up
  IF DQBkey(keydown) THEN MovePlayer down
  IF DQBkey(keyesc) AND TIMER >= menudelay! THEN gamemode = inmenu: menudelay! = TIMER + .2
 CASE inmenu
  IF DQBkey(keyesc) THEN HandleMenu keyesc
  IF DQBkey(keyup) THEN HandleMenu keyup
  IF DQBkey(keydown) THEN HandleMenu keydown
  IF DQBkey(keyenter) THEN HandleMenu keyenter
END SELECT

END SUB

SUB DoTimers

IF TIMER - realtimer! > .1 THEN
  anmcounter = anmcounter + 1
  IF anmcounter > 840 THEN anmcounter = 0
  realtimer! = TIMER
END IF

END SUB

SUB ErrorHandlerSub (e)

DQBinitText
SCREEN 0: WIDTH 80, 25: CLS

f = FREEFILE
OPEN "errors.dat" FOR INPUT AS f
  DO
    INPUT #f, k
    INPUT #f, errtext$
    IF k = e THEN errfound = 1
    IF k = 999 THEN errfound = 1
  LOOP UNTIL errfound
CLOSE f

PRINT "Powered by K7 Engine technology (Build 3B)."
PRINT "K7 Engine (c) Kevin Wellwood 2000": PRINT
PRINT "Compiled November 10, 2000"

PRINT "Error (" + LTRIM$(STR$(e)) + "):"
PRINT "* " + errtext$

DQBremoveKeyboard
DeallocXMS
ClosePAKLib
DQBclose
END

END SUB

SUB InitEngine

OPEN "engine.dat" FOR INPUT AS 1
  INPUT #1, ver
  IF ver <> enginever THEN ErrorHandlerSub 125
  INPUT #1, ts
  INPUT #1, maxfps
  INPUT #1, tileset$
  INPUT #1, player(0).xmax
  INPUT #1, player(0).ymax
  INPUT #1, player(0).jumpheight
  INPUT #1, player(0).xsize
  INPUT #1, player(0).ysize
  INPUT #1, player(0).txsize
  INPUT #1, player(0).tysize
CLOSE 1
gamemode = ingame

OPEN "player.dat" FOR INPUT AS 1
  INPUT #1, player(0).adelay  ' animation speed
  INPUT #1, pframe(0)   ' stand left
  INPUT #1, pframe(1)   ' walk left start
  INPUT #1, pframe(2)   ' walk left frames
  INPUT #1, pframe(3)   ' stand right
  INPUT #1, pframe(4)   ' walk right start
  INPUT #1, pframe(5)   ' walk right frames
  INPUT #1, pframe(6)   ' left jump up
  INPUT #1, pframe(7)   ' left jump apex
  INPUT #1, pframe(8)   ' left falling
  INPUT #1, pframe(9)   ' right jump up
  INPUT #1, pframe(10)  ' right jump apex
  INPUT #1, pframe(11)  ' right falling
CLOSE 1

DEF SEG = VARSEG(pal(0))
BLOAD "palette.dat", 0
DEF SEG

a = DQBloadFont("font.dat")
IF a THEN ErrorHandlerSub 125 + a

DQBinstallKeyboard

END SUB

SUB MainLoop

DQBsetFrameRate maxfps

DO
  DoTimers
  IF DQBframeReady THEN
    DoInput
    DoPhysics
    CheckOnGround
    CheckJumpHeight
    DoPlayerFrame
    DoCamera
    DrawScreen
  END IF
LOOP UNTIL quitgame

END SUB

SUB SetPalette

OUT &H3C8, 0

FOR i = 0 TO 255
  OUT &H3C9, pal(i).red: OUT &H3C9, pal(i).grn: OUT &H3C9, pal(i).blu
NEXT

END SUB


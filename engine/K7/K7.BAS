DEFINT A-Z
'$DYNAMIC

'$INCLUDE: 'engine.bi'
'$INCLUDE: 'directqb.bi'
'$INCLUDE: 'xms.bi'
'$INCLUDE: 'paklib.bi'
'$INCLUDE: 'plugins.bi'

RANDOMIZE TIMER
ON ERROR GOTO ErrorHandler
a = DQBinit(4, maxsounds, 0): IF a THEN ErrorHandlerSub 99 + a
a = InitPAKLib: IF a THEN ErrorHandlerSub 104
AllocXMS

'--------- Core Engine ---------
DIM SHARED player(0) AS playertype, scr(32004), file(0) AS STRING * 12
DIM SHARED biti(0) AS INTEGER, bitl(0) AS LONG, pal(255) AS hues
DIM SHARED pframe(21) AS LONG, fsize(21) AS intcoordinate

'-------- Render System --------
DIM SHARED camera(0) AS camtype

'-------- Physics System -------
DIM SHARED ClipPoint(1 TO 10) AS coordinate

'--------- Items System --------
DIM SHARED item(1 TO 255) AS itemclass, bonus(1 TO 10) AS itemtypeclass
DIM SHARED activeitemstack(0) AS STRING, activespritestack(0) AS STRING
DIM SHARED sprite(1 TO 100) AS spriteclass, unusedspritestack(0) AS STRING

'-------- Weapons System -------
DIM SHARED shot(1 TO 5) AS shottype

'------- Switches System -------
DIM SHARED switch(1 TO 25)

'-------- Enemies System -------
DIM SHARED enemy(100) AS enemytype, eframe(16) AS LONG
DIM SHARED efsize(16) AS intcoordinate, activefoestack(0) AS STRING

PRINT "Loading...";
InitEngine

'--plugins--
InitMenu
InitScoreboard
InitItems
InitWeapons
InitEnemies
InitSound
'-----------

'--core assets--
LoadTiles
LoadMap "keen7.map"
'---------------

PRINT "Ok"

DQBinitVGA: SCREEN 13
SetPalette

Intro
MainLoop

DQBinitText
SCREEN 0: WIDTH 80, 25
DQBremoveKeyboard
DeallocXMS
ClosePAKLib
DQBclose
PRINT "Powered by K7 Engine technology (Build 6)."
PRINT "K7 Engine (c) Kevin Wellwood 2001": PRINT
PRINT "Compiled January 25, 2001"
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

'=========[ SWITCHES PLUGIN ]==========
BiosXOpen 512, SwitchTagHandle, ErrCode
IF ErrCode THEN ErrorHandlerSub 113

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

'=========[ Switches Plugin ]==========
BiosXClose SwitchTagHandle

END SUB

SUB DebugLog (t$)

ff = FREEFILE
OPEN "debug.log" FOR APPEND AS ff
  t$ = "TIME: " + LTRIM$(RTRIM$(STR$(TIMER))) + "  ACTION: " + t$
  PRINT #ff, t$
CLOSE ff

END SUB

SUB DoInput

player(0).aim = -1  ' dont aim up or down

SELECT CASE gamemode
 CASE ingame
  IF gameplay = running THEN
    'IF DQBkey(30) THEN player(0).ammo = 50
    IF DQBkey(keyright) THEN MovePlayer right
    IF DQBkey(keyleft) THEN MovePlayer left
    IF DQBkey(keyup) THEN player(0).aim = up: CheckSwitch
    IF DQBkey(keydown) AND player(0).onground = 0 THEN player(0).aim = down
    IF DQBkey(keyctrl) THEN MovePlayer up   ' (ie: jump)

    IF DQBkey(73) THEN camera(0).y = camera(0).y - 2
    IF DQBkey(81) THEN camera(0).y = camera(0).y + 2
    IF DQBkey(keyspace) THEN SpawnPlayerShot
  END IF
 
  IF DQBkey(25) THEN  ' Pause - 'p'
    IF gameplay = running THEN gameplay = paused ELSE gameplay = running
    WHILE DQBkey(25): WEND
  END IF
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
  LOOP UNTIL errfound OR EOF(f)
CLOSE f

PRINT "Powered by K7 Engine technology (Build 6)."
PRINT "K7 Engine (c) Kevin Wellwood 2001": PRINT
PRINT "Compiled January 25, 2001"

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
  IF ver <> enginever THEN CLOSE 1: ErrorHandlerSub 125
  INPUT #1, ts
  INPUT #1, maxfps
  INPUT #1, friction!    ' velocity friction co-efficient
  INPUT #1, tileset$
  INPUT #1, soundset$
  INPUT #1, maxchannels
  INPUT #1, player(0).xmax
  INPUT #1, player(0).ymax
  INPUT #1, player(0).jumpheight
  INPUT #1, player(0).xsize
  INPUT #1, player(0).ysize
  INPUT #1, player(0).txsize
  INPUT #1, player(0).tysize
CLOSE 1
gamemode = ingame
gameplay = running
SoundEnabled = 0

OPEN "player.dat" FOR INPUT AS 1
  INPUT #1, player(0).adelay  ' animation speed
  INPUT #1, pframe(0)
  INPUT #1, fsize(0).x
  INPUT #1, fsize(0).y
  INPUT #1, pframe(1)
  INPUT #1, fsize(1).x
  INPUT #1, fsize(1).y
  INPUT #1, pframe(2)
  INPUT #1, pframe(3)
  INPUT #1, fsize(3).x
  INPUT #1, fsize(3).y
  INPUT #1, pframe(4)
  INPUT #1, fsize(4).x
  INPUT #1, fsize(4).y
  INPUT #1, pframe(5)
  FOR f = 6 TO 22
    INPUT #1, pframe(f)
    INPUT #1, fsize(f).x
    INPUT #1, fsize(f).y
  NEXT f
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
    IF gameplay = running THEN
      DoPhysics
      DoSprites
      DoItems
      DoShots
      HandleEnemies
      PlayerState
      DoCamera
    END IF
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


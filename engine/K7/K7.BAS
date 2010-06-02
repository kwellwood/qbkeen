DEFINT A-Z
'$DYNAMIC
'$INCLUDE: 'engine.bi'
'$INCLUDE: 'directqb.bi'
'$INCLUDE: 'xms.bi'
'$INCLUDE: 'paklib.bi'
'$INCLUDE: 'dextern.bi'
'$INCLUDE: 'plugins.bi'
RANDOMIZE TIMER
ON ERROR GOTO ErrorHandler

'Changes for disabling EMM:
'K7: dqbinit, exit messages, nextlevel(copylayer)
'ENGINE.BI: page constants
'RENDER: scoreboard, copylayer, clearlayer, dqbwait
'============================================================================
IF UCASE$(COMMAND$) = "-NOEMS" THEN ems = 0 ELSE ems = 1
IF ems = 0 THEN PRINT "* EMS memory use disabled *"

e = DQBinit(ems * 2, 0, 0): IF e THEN ErrorHandlerSub 99 + e
e = InitPAKLib: IF e THEN ErrorHandlerSub 104
AllocXMS

'--------- Core Engine ---------
DIM SHARED player(0) AS playertype, ClipPoint(1 TO 10) AS coordinate
DIM SHARED scr(32004), file(0) AS STRING * 12
DIM SHARED biti(0) AS INTEGER, bitl(0) AS LONG, pal(255) AS hues
DIM SHARED pframe(51) AS LONG, fsize(51) AS intcoordinate

'--------- Items System --------
DIM SHARED item(1 TO 255) AS itemclass, bonus(1 TO 13) AS itemtypeclass
DIM SHARED activeitemstack(0) AS STRING, activespritestack(0) AS STRING
DIM SHARED sprite(1 TO 100) AS spriteclass, unusedspritestack(0) AS STRING

'-------- Weapons System -------
DIM SHARED shot(1 TO 5) AS shottype

'------- Switches System -------
DIM SHARED Switch(0 TO 25)

'-------- Enemies System -------
DIM SHARED enemy(100) AS enemytype, eframe(20) AS LONG
DIM SHARED efsize(20) AS intcoordinate, activefoestack(0) AS STRING
DIM SHARED EClipPoint(4) AS coordinate

'------- Teleport System -------
DIM SHARED portal(1 TO 32) AS portaltype, activeportalstack(0) AS STRING

'------- Platform System -------
DIM SHARED locator(1 TO 16, 1 TO 16) AS locatortype, numlocators(1 TO 16)
DIM SHARED lift(1 TO 16) AS lifttype
'============================================================================
PRINT "Loading..."

'----------[ Initialize ]----------
InitEngine
InitMenu
InitScoreboard
InitItems
InitWeapons
InitEnemies
InitSound
LoadTiles
LoadLevel
ClosePAKLib

PRINT "Ok"

'--------[ Set Screen Mode ]--------
DQBinitVGA: SCREEN 13
SetPalette
DQBsetFrameRate maxfps

'---------[ Start the Game ]--------
Intro
MainLoop

'------[ Shutdown the Engine ]------
DQBinitText
SCREEN 0: WIDTH 80, 25

ShutdownSound
DQBremoveKeyboard
DeallocXMS
DQBclose

PRINT "Powered by K7 Engine technology (Build 13)."
PRINT "K7 Engine (c) Kevin Wellwood 2001": PRINT
'PRINT "Development version."
END
'============================================================================
ErrorHandler:
e = ERR
ErrorHandlerSub e
RESUME NEXT

REM $STATIC
SUB AllocXMS

'-----------[ Tiles System ]-----------
BiosXOpen 8, TileTypeHandle, A
IF A THEN ErrorHandlerSub 105
BiosXOpen 8, AnmLengthHandle, A
IF A THEN ErrorHandlerSub 106
BiosXOpen 8, AnmDelayHandle, A
IF A THEN ErrorHandlerSub 107
BiosXOpen 8, TileType2Handle, A
IF A THEN ErrorHandlerSub 114
BiosXOpen 8, SlopeMaskHandle, A
IF A THEN ErrorHandlerSub 115

'---------[ Graphics System ]----------
BiosXOpen 2048, ArtHandle, A
IF A THEN ErrorHandlerSub 108
BiosXOpen 8, ArtOffSetHandle, A
IF A THEN ErrorHandlerSub 109
BiosXOpen 8, ArtLengthHandle, A
IF A THEN ErrorHandlerSub 110

'------------[ Map System ]------------
BiosXOpen 1024, MapHandle, A
IF A THEN ErrorHandlerSub 111
BiosXOpen 1024, MapFGHandle, A
IF A THEN ErrorHandlerSub 112

'---------[ SWITCHES PLUGIN ]----------
BiosXOpen 1024, SwitchTagHandle, ErrCode
IF ErrCode THEN ErrorHandlerSub 113

END SUB

SUB DeallocXMS

'-----------[ Tiles System ]-----------
BiosXClose TileTypeHandle
BiosXClose TileType2Handle
BiosXClose AnmLengthHandle
BiosXClose AnmDelayHandle

'---------[ Graphics System ]----------
BiosXClose ArtHandle
BiosXClose ArtOffSetHandle
BiosXClose ArtLengthHandle

'------------[ Map System ]------------
BiosXClose MapHandle
BiosXClose MapFGHandle

'---------[ Switches Plugin ]----------
BiosXClose SwitchTagHandle

END SUB

SUB DebugLog (t$)

IF UCASE$(COMMAND$) = "-LOG" THEN
  ff = FREEFILE
  OPEN "debug.log" FOR APPEND AS ff
    t$ = "TIME: " + LTRIM$(RTRIM$(STR$(TIMER))) + "  ACTION: " + t$
    PRINT #ff, t$
  CLOSE ff
END IF

END SUB

SUB DoInput

player(0).aim = -1
IncreaseIdleTime

SELECT CASE gamemode
 CASE ingame
  IF gameplay = running THEN
    IF DQBkey(30) THEN player(0).ammo = 99     ' add ammo (a)
    IF DQBkey(KEYRIGHT) THEN MovePlayer RIGHT  ' move right (right key)
    IF DQBkey(KEYLEFT) THEN MovePlayer LEFT    ' move left (left key)
    IF DQBkey(KEYUP) THEN
      player(0).idletime = 0
      player(0).aim = up                   ' aim up or climb up (up key)
      IF player(0).action = climbing THEN  ' continue climbing up
        ClimbUp                            '
       ELSEIF player(0).action = hanging THEN ' climb up from a ledge
        HangClimbUp                           '
       ELSE
        CheckSwitch                        ' check to flip a switch
        CheckTeleport                      ' check to teleport
        CheckClimb                         ' check to grab a pole
      END IF
    END IF
    IF DQBkey(KEYDOWN) THEN       ' aim down or climb down (down key)
      player(0).idletime = 0
      IF player(0).onground = 0 OR player(0).action = climbing THEN player(0).aim = DOWN
      IF player(0).action = climbing THEN ClimbDown
      IF player(0).action <> climbing AND player(0).onground THEN CheckClimb
    END IF
    IF DQBkey(KEYCTRL) THEN                            ' jump (ctrl)
      MovePlayer up                                    '
     ELSEIF player(0).holdingjump THEN                 ' not pressing jump
      player(0).holdingjump = 0                        '  do not allow
      player(0).stoppedjump = 1                        '  jumping to continue
    END IF
    IF DQBkey(KEYALT) THEN TogglePogo                  ' Pogostick (alt)
    IF DQBkey(73) THEN camera(0).y = camera(0).y - 2   ' Camera Up (pg up)
    IF DQBkey(81) THEN camera(0).y = camera(0).y + 2   ' Camera Down (pg dn)
    IF DQBkey(KEYSPACE) THEN SpawnPlayerShot           ' Shoot gun (space)
  END IF
 
  ' Pause (p)
  IF DQBkey(25) THEN
    IF gameplay = running THEN gameplay = paused ELSE gameplay = running
    WHILE DQBkey(25): WEND
  END IF
  ' Toggle menu (esc)
  IF DQBkey(KEYESC) AND TIMER >= menudelay! AND player(0).action <> dying THEN gamemode = inmenu: menudelay! = TIMER + .2

  ' Skip level (F5)
  IF DQBkey(63) THEN NextLevel

 CASE inmenu
  IF DQBkey(KEYESC) THEN HandleMenu KEYESC
  IF DQBkey(KEYUP) THEN HandleMenu KEYUP
  IF DQBkey(KEYDOWN) THEN HandleMenu KEYDOWN
  IF DQBkey(KEYENTER) THEN HandleMenu KEYENTER
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

PRINT "Powered by K7 Engine technology (Build 13)."
PRINT "K7 Engine (c) Kevin Wellwood 2001": PRINT
'PRINT "Development version."

PRINT "Error (" + LTRIM$(STR$(e)) + "):"
PRINT "* " + errtext$

DQBremoveKeyboard
DeallocXMS
ShutdownSound
DQBclose
END

END SUB

SUB IncreaseIdleTime

IF gameplay = paused THEN EXIT SUB

IF player(0).action = moving AND player(0).onground THEN
  IF player(0).idletime < 1000 THEN player(0).idletime = player(0).idletime + 1
END IF

END SUB

SUB InitEngine

SELECT CASE ems
 CASE 0: drawpage = 0: menupage = 0
 CASE 1: drawpage = 1: menupage = 2
END SELECT

OPEN "engine.dat" FOR INPUT AS 1
  DO: INPUT #1, text$
  LOOP UNTIL UCASE$(text$) = "[ENGINE.DAT]"
  INPUT #1, v
  IF v <> enginever THEN CLOSE 1: ErrorHandlerSub 125
  INPUT #1, ts
  INPUT #1, maxfps
  INPUT #1, friction!    ' velocity friction co-efficient
  INPUT #1, gravity!
  INPUT #1, tileset$
  INPUT #1, soundset$
  INPUT #1, maxchannels
  INPUT #1, player(0).xmax
  INPUT #1, player(0).ymax
  INPUT #1, player(0).jumpheight
  INPUT #1, player(0).xsize
  INPUT #1, player(0).ysize
CLOSE 1

curlevel = 1

OPEN "engine.dat" FOR INPUT AS 1
  DO: INPUT #1, text$
  LOOP UNTIL UCASE$(text$) = "[PLAYER.DAT]"
  INPUT #1, player(0).adelay  ' animation speed
  FOR f = 0 TO 51
    INPUT #1, pframe(f)
    INPUT #1, fsize(f).x
    INPUT #1, fsize(f).y
  NEXT f
CLOSE 1
player(0).lives = 3
player(0).ammo = 5
player(0).score = 0

DEF SEG = VARSEG(pal(0))
BLOAD "palette.dat", 0
DEF SEG

A = DQBloadFont("font.dat")
IF A THEN ErrorHandlerSub 125 + A

DQBinstallKeyboard

END SUB

SUB LoadLevel

'====[ LOAD MAP ]====
OPEN "levels.dat" FOR INPUT AS 1
  INPUT #1, numlevels
  IF curlevel > numlevels OR curlevel < 0 THEN
    DebugLog "Level not in list:" + STR$(curlevel)
    ErrorHandlerSub 129
  END IF
  FOR l = 1 TO numlevels
    INPUT #1, mapfile$
    INPUT #1, mapname$
    IF l = curlevel THEN EXIT FOR
  NEXT l
CLOSE 1
LoadMap mapfile$

'---[ Set Game State ]---
gamemode = ingame
gameplay = running

'----[ Reset Player Status ]----
player(0).onground = 0
player(0).onslope = 0
player(0).canjump = 0
player(0).reload = 0
player(0).shooting = 0
player(0).shootingframe = 0
player(0).aim = -1
player(0).action = moving
player(0).actiontime = 0
player(0).frozen = 0
player(0).usingportal = 0

END SUB

SUB MainLoop

DO
  DoTimers
  IF DQBframeReady THEN
    DoInput
    IF gameplay = running THEN
      DoPhysics
      DoPlayerOnLift
      HandleLifts
      'DoPlayerOnLift
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

SUB NextLevel

t! = TIMER
DS4QB.StopMusic 1
PlaySound 2

curlevel = curlevel + 1
PutSprite 74, 49, 57, drawpage

OPEN "levels.dat" FOR INPUT AS 1
  INPUT #1, numlevels
  IF curlevel > numlevels OR curlevel < 0 THEN
    DebugLog "Level not in list:" + STR$(curlevel)
    ErrorHandlerSub 129
  END IF
  FOR l = 1 TO numlevels
    INPUT #1, mapfile$
    INPUT #1, mapname$
    IF l = curlevel THEN EXIT FOR
  NEXT l
CLOSE 1
IF DQBlen(mapname$) > 140 THEN
  totallen = DQBlen(mapname$)
  temp$ = mapname$: mapname$ = "": mapname2$ = ""
  WHILE DQBlen(mapname$ + LEFT$(temp$, INSTR(temp$, " "))) <= 144 AND INSTR(temp$, " ")
    mapname$ = mapname$ + LEFT$(temp$, INSTR(temp$, " "))
    temp$ = RIGHT$(temp$, LEN(temp$) - INSTR(temp$, " "))
  WEND
  mapname2$ = temp$
END IF
DQBprint drawpage, mapname$, 112, 78, 14
IF mapname2$ > "" THEN DQBprint drawpage, mapname2$, 120, 88, 14
IF ems THEN DQBcopyLayer drawpage, video

LoadLevel
DO: LOOP UNTIL TIMER - t! > 1!

END SUB

SUB SetPalette

OUT &H3C8, 0

FOR i = 0 TO 255
  OUT &H3C9, pal(i).red: OUT &H3C9, pal(i).grn: OUT &H3C9, pal(i).blu
NEXT

OUT &H3C7, -1
OUT &H3C9, 0
OUT &H3C9, 32
OUT &H3C9, 32

END SUB


DEFINT A-Z
'$DYNAMIC
'$INCLUDE: 'engine.bi'
'$INCLUDE: 'directqb.bi'
'$INCLUDE: 'timer.bi'
'$INCLUDE: 'k7.bi'

RANDOMIZE TIMER
ON ERROR GOTO ErrorHandler
'============================================================================
ReadParameters      ' Override presets from the command line
e = DQBinit(ems * 2, 0, 0): IF e THEN ErrorHandlerSub 99 + e
AllocXMS

'------- K7 Private variables -------
DIM SHARED pal(255) AS hues

'--------- Global variables ---------
DIM SHARED scr(32002)
DIM SHARED player(0) AS playertype, ClipPoint(1 TO 10) AS coordinate
DIM SHARED enemy(100) AS enemytype, EClipPoint(4) AS coordinate
DIM SHARED eframe(33) AS LONG, efsize(33) AS intcoordinate
DIM SHARED global(0) AS globalvars
'============================================================================
PRINT "Loading..."

'----------[ Initialize ]----------
InitEngine
InitMenu
InitScoreboard
InitLifts
InitItems
InitWeapons
InitEnemies
InitSound
LoadTiles tileset$
LoadLevel

PRINT "Ok"

'--------[ Set Screen Mode ]--------
DQBinitVGA: SCREEN 13
SetPalette
ERASE pal

'---------[ Start the Game ]--------
Intro
MainLoop

'------[ Shutdown the Engine ]------
DQBinitText
SCREEN 0: WIDTH 80, 25
PRINT "Shutting down...": PRINT

ShutdownSound
DQBremoveKeyboard
csRemoveTimer
DeallocXMS
DQBclose

PRINT "Powered by K7 Engine technology (Build 14)."
PRINT "K7 Engine (c) Kevin Wellwood 2002": PRINT
'PRINT "Development version."
END
'============================================================================
ErrorHandler:
e = ERR
ErrorHandlerSub e
RESUME NEXT

REM $STATIC
SUB AllocXMS

TilesGetXMS
MapGetXMS
SwitchesGetXMS

END SUB

SUB DeallocXMS

TilesCloseXMS
MapCloseXMS
SwitchesCloseXMS

END SUB

SUB debuglog (t$)

IF dolog THEN
  ff = FREEFILE
  OPEN "debug.log" FOR APPEND AS ff
    t$ = "TIME: " + LTRIM$(RTRIM$(STR$(TIMER))) + "  ACTION: " + t$
    't$ = "ACTION: " + t$
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
      player(0).aim = UP                   ' aim up or climb up (up key)
      IF player(0).action = climbing THEN  ' continue climbing up
        ClimbUp                            '
       ELSEIF player(0).action = hanging THEN  ' climb up from a ledge
        HangClimbUp                            '
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
      MovePlayer UP                                    '
     ELSEIF player(0).holdingjump THEN                 ' not pressing jump
      player(0).holdingjump = 0                        '  do not allow
      player(0).stoppedjump = 1                        '  jumping to continue
    END IF
    IF DQBkey(KEYALT) THEN TogglePogo                  ' Pogostick (alt)
    IF DQBkey(73) THEN MoveCamera 0, -2                ' Camera Up (pg up)
    IF DQBkey(81) THEN MoveCamera 0, 2                 ' Camera Down (pg dn)
    IF DQBkey(KEYSPACE) THEN SpawnPlayerShot           ' Shoot gun (space)
  END IF
 
  ' Pause (p)
  IF DQBkey(25) THEN
    IF gameplay = running THEN gameplay = paused ELSE gameplay = running
    WHILE DQBkey(25): WEND
  END IF
  ' Toggle menu (esc)
  IF DQBkey(KEYESC) AND TimerTicks(HiResTimer) > menutimermark& AND player(0).action <> dying THEN
    gamemode = inmenu
    menutimermark& = TimerTicks(HiResTimer) + (200 \ 5)
  END IF

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

IF TimerTicked(AnmTimer) THEN
  PlaySoundBuffer
  anmcounter = anmcounter + 1
  IF anmcounter > 840 THEN anmcounter = 0
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

PRINT "Powered by K7 Engine technology (Build 14)."
PRINT "K7 Engine (c) Kevin Wellwood 2002": PRINT
'PRINT "Development version."

PRINT "Error (" + LTRIM$(STR$(e)) + "):"
PRINT "* " + errtext$

PRINT : PRINT "Shutting down..."
DQBremoveKeyboard
csRemoveTimer
DeallocXMS
ShutdownSound
DQBclose
END

END SUB

FUNCTION FrameReady

IF TimerTicked(FrameTimer) THEN
  FrameReady = 1
  EXIT FUNCTION
END IF

FrameReady = 0

END FUNCTION

SUB IncreaseIdleTime

IF gameplay = paused THEN EXIT SUB

IF player(0).action = moving AND player(0).onground THEN
  IF player(0).idletime < 1000 THEN player(0).idletime = player(0).idletime + 1
END IF

END SUB

SUB InitEngine

drawpage = ems * 1: menupage = ems * 2

OPEN "engine.dat" FOR INPUT AS 1
  DO: INPUT #1, Text$
  LOOP UNTIL UCASE$(Text$) = "[ENGINE.DAT]"
  INPUT #1, v
  IF v <> enginever THEN CLOSE 1: ErrorHandlerSub 125
  INPUT #1, ts
  INPUT #1, maxfps
  INPUT #1, friction!
    SetPlayerFriction friction!  ' friction co-efficient
    SetEnemyFriction friction!   '
  INPUT #1, gravity!
    SetPlayerGravity gravity!    ' gravity acceleration
    SetEnemyGravity gravity!     '
  INPUT #1, tileset$
  INPUT #1, soundset$: SetSoundSet soundset$
  INPUT #1, maxchannels
  INPUT #1, player(0).xmax
  INPUT #1, player(0).ymax
  INPUT #1, player(0).jumpheight
  INPUT #1, player(0).xsize
  INPUT #1, player(0).ysize
CLOSE 1

InitPlayer
curlevel = 1

DEF SEG = VARSEG(pal(0))
BLOAD "palette.dat", 0
DEF SEG

a = DQBloadFont("font.dat")
IF a THEN ErrorHandlerSub 125 + a

DQBinstallKeyboard

csInstallTimer
csSetTimer FrameTimer, INT((1000 \ maxfps) / 5) * 5   'framerate
csSetTimer AnmTimer, 100                              'anmcounter (1/10 sec)
csSetTimer HiResTimer, 5                              'generic 5ms timer

END SUB

SUB LoadLevel

'====[ LOAD MAP ]====
OPEN "levels.dat" FOR INPUT AS 1
  INPUT #1, numlevels
  IF curlevel > numlevels OR curlevel < 0 THEN
    debuglog "Level not in list:" + STR$(curlevel)
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
  IF FrameReady THEN
    DoInput
    IF gameplay = running THEN
      DoPhysics
      DoPlayerOnLift
      HandleLifts
      DoSprites
      DoItems
      DoShots
      HandleEnemies
      DoPlayerState
      DoCamera
    END IF
    DrawScreen
  END IF
LOOP UNTIL quitgame

END SUB

SUB NextLevel

mark& = TimerTicks(HiResTimer) + (1000 \ 5)

EndMusic                   ' stop music
PlaySound 2                ' end of level sound

curlevel = curlevel + 1    ' increment level

DrawLoadingBox             ' draw loading screen

LoadLevel                  ' load next level to memory

WHILE TimerTicks(HiResTimer) < mark&: WEND

END SUB

SUB ReadParameters

ems = 1         ' Turn on EMS
SetSoundSys 0   ' Turn off sound system
dolog = 0       ' Turn off logging

l$ = COMMAND$

FOR c = 1 TO LEN(l$)
  IF ASC(MID$(l$, c, 1)) = ASC(" ") OR c = LEN(l$) THEN
    IF c = LEN(l$) AND ASC(MID$(l$, c, 1)) <> ASC(" ") THEN arg$ = arg$ + MID$(l$, c, 1)
    SELECT CASE arg$
     CASE "-NOEMS": ems = 0: PRINT "* EMS memory use disabled *"
     'CASE "-SOUND": SetSoundSys 1: PRINT "* Sound system enabled *"
     CASE "-LOG": dolog = 1: PRINT "* Debugging log enabled *"
    END SELECT
    arg$ = ""
   ELSE
    arg$ = arg$ + MID$(l$, c, 1)
  END IF
NEXT c

END SUB

SUB ResetTimer (tmr)

csResetTicks tmr

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

FUNCTION TileUnitsInt (pixels)

TileUnitsInt = INT(pixels / ts) + 1

END FUNCTION

FUNCTION TileUnitsSin (pixels!)

TileUnitsSin = INT(pixels! / ts) + 1

END FUNCTION

FUNCTION TimerTicked (tmr)

TimerTicked = CSTimerFlag(tmr)

END FUNCTION

FUNCTION TimerTicks& (tmr)

ticks& = CSElapsedTicks&(tmr)
TimerTicks& = ticks&

END FUNCTION


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
DIM SHARED pal(0) AS STRING * 768

'--------- Global variables ---------
DIM SHARED scr(32002)
DIM SHARED player(0) AS playertype, ClipPoint(1 TO 10) AS coordinate
DIM SHARED enemy(100) AS enemytype, EClipPoint(4) AS coordinate
DIM SHARED eframe(maxenemyframes) AS LONG, efsize(maxenemyframes) AS intcoordinate
DIM SHARED global(0) AS globalvars
DIM SHARED levelscomplete(0)
'============================================================================
PRINT "Loading... ";

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
LoadLevel curlevel

DQBfadeTo 0, 0, 0

'--------[ Set Screen Mode ]--------
DQBinitVGA  ': SCREEN 13

'---------[ Start the Game ]--------
Intro
SetPalette
MainLoop

'------[ Shutdown the Engine ]------
DQBinitText
SCREEN 0: WIDTH 80, 25
PRINT "Powered by K7 Engine technology (Build 16)."
PRINT "K7 Engine (c) Kevin Wellwood 2002": PRINT
PRINT "Development version.": PRINT

PRINT "Shutting down..."

ShutdownSound
DQBremoveKeyboard
csRemoveTimer
DeallocXMS
DQBclose

END
'============================================================================
ErrorHandler:
e = ERR
ErrorHandlerSub e
RESUME NEXT

CheckFile:
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
    IF movemode = jumpmode THEN
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
      IF DQBkey(KEYCTRL) THEN                          ' jump (ctrl)
        MovePlayer UP                                  '
       ELSEIF player(0).holdingjump THEN               ' not pressing jump
        player(0).holdingjump = 0                      '  do not allow
        player(0).stoppedjump = 1                      '  jumping to continue
      END IF
      IF DQBkey(KEYALT) THEN TogglePogo                ' Pogostick (alt)
      IF DQBkey(73) THEN MoveCamera 0, -2              ' Camera Up (pg up)
      IF DQBkey(81) THEN MoveCamera 0, 2               ' Camera Down (pg dn)
      IF DQBkey(KEYSPACE) THEN SpawnPlayerShot         ' Shoot gun (space)
      IF DQBkey(KEYENTER) AND showdropdownheight = -181 THEN
        showdropdownheight = showdropdownheight + 1
      END IF
     ELSEIF movemode = mapmode THEN
      IF DQBkey(KEYRIGHT) THEN MovePlayer RIGHT  ' move right (right key)
      IF DQBkey(KEYLEFT) THEN MovePlayer LEFT    ' move left (left key)
      IF DQBkey(KEYUP) THEN MovePlayer UP        ' move up (up key)
      IF DQBkey(KEYDOWN) THEN MovePlayer DOWN    ' move down (down key)
      IF DQBkey(KEYCTRL) THEN                    ' enter a level (ctrl)
        CheckEnterLevel
      END IF
      IF DQBkey(KEYENTER) AND showdropdownheight = -181 THEN
        showdropdownheight = showdropdownheight + 1
      END IF
    END IF
  END IF

  ' Pause (p)       ' \/ cant pause/unpause when dropdown status is moving
  IF DQBkey(25) AND showdropdownheight = -181 THEN
    IF gameplay = running THEN
      gameplay = paused: pausedingame = 1
     ELSE
      gameplay = running: pausedingame = 0
    END IF
    WHILE DQBkey(25): WEND
  END IF
  ' Toggle menu (esc)
  IF DQBkey(KEYESC) AND TimerTicks(HiResTimer) > menutimermark& AND player(0).action <> dying AND showdropdownheight = -181 THEN
    gamemode = inmenu
    gameplay = paused
    menutimermark& = TimerTicks(HiResTimer) + (200 \ 5)
  END IF
  ' Help and info menu (F1)
  IF DQBkey(59) THEN HelpMenu

  ' Take a Screenshot (F9)
  IF DQBkey(67) THEN
    TakeScreenshot
    WHILE DQBkey(67): WEND
  END IF

 CASE inmenu
  IF DQBkey(KEYESC) THEN HandleMenu KEYESC
  IF DQBkey(KEYUP) THEN HandleMenu KEYUP
  IF DQBkey(KEYDOWN) THEN HandleMenu KEYDOWN
  IF DQBkey(KEYENTER) THEN HandleMenu KEYENTER
  IF DQBkey(59) THEN HelpMenu    ' Help and info menu (F1)
 
  ' Take a Screenshot (F9)
  IF DQBkey(67) THEN
    TakeScreenshot
    WHILE DQBkey(67): WEND
  END IF
END SELECT

END SUB

SUB DoPlayerDead

SLEEP 1
choice = TryAgainMenu
IF choice = 0 THEN
  player(0).lives = player(0).lives - 1
  LoadLevel curlevel  ' restart the level
 ELSE
  player(0).lives = player(0).lives - 1
  EndLevel 0          ' exit the level without victory
END IF

END SUB

SUB DoTimers

IF TimerTicked(AnmTimer) THEN
  PlaySoundBuffer
  anmcounter = anmcounter + 1
  IF anmcounter > 840 THEN anmcounter = 0
END IF

END SUB

SUB EndGame

gameoverflag = 0
gameplay = stopped: gamemode = inmenu
curlevel = 1
LoadLevel curlevel
gameplay = stopped
gamemode = inmenu
movemode = jumpmode

END SUB

SUB EndLevel (victory)
' End regular level and enter map

mark& = TimerTicks(HiResTimer) + (1000 \ 5)

EndMusic                        ' stop music
IF victory THEN
  PlaySound 2                   ' end of level sound
  levelscomplete(curlevel) = 1  ' set this level completed
END IF

curlevel = 2               ' set level to overhead map
DrawLoadingBox curlevel    ' draw loading screen
LoadLevel curlevel         ' load overhead map to memory
PrepareOverheadMap         ' put up the complete flags etc

IF player(0).mapx > 0 OR player(0).mapy > 0 THEN
  player(0).x = player(0).mapx
  player(0).y = player(0).mapy
  player(0).xdir = player(0).mapxdir
END IF

gameplay = running: pausedingame = 0
movemode = mapmode
gamemode = ingame

WHILE TimerTicks(HiResTimer) < mark&: WEND

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

PRINT "Powered by K7 Engine technology (Build 16)."
PRINT "K7 Engine (c) Kevin Wellwood 2002": PRINT
PRINT "Development version."

PRINT "Error (" + LTRIM$(STR$(e)) + "):"
PRINT "* " + errtext$
debuglog "CRASH: Error" + STR$(e)
debuglog "* " + errtext$

PRINT : PRINT "Shutting down..."
DQBremoveKeyboard
csRemoveTimer
DeallocXMS
ShutdownSound
DQBclose

SLEEP 3
END

END SUB

SUB FadeInPalette

DQBfadeIn pal(0)

END SUB

SUB FadeInPaletteStep

DQBfadeStepIn pal(0)

END SUB

FUNCTION FrameReady

IF TimerTicked(FrameTimer) THEN
  FrameReady = 1
  EXIT FUNCTION
END IF

FrameReady = 0

END FUNCTION

FUNCTION GameComplete

GameComplete = gamecompleteflag

END FUNCTION

FUNCTION GameOver

GameOver = gameoverflag

END FUNCTION

SUB IncreaseIdleTime

IF gameplay <> running OR movemode = mapmode THEN EXIT SUB

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
  INPUT #1, totalancients
CLOSE 1

' Create the array to store completed levels
OPEN "levels.dat" FOR INPUT AS 1: INPUT #1, numlevels: CLOSE 1
IF numlevels < 3 THEN ErrorHandlerSub 124
REDIM levelscomplete(numlevels)

InitPlayer
curlevel = 1
gamemode = inmenu
gameplay = stopped
movemode = jumpmode

a = DQBloadFont("font.dat")
IF a THEN ErrorHandlerSub 125 + a

LoadPalette

DQBinstallKeyboard

csInstallTimer
csSetTimer FrameTimer, INT((1000 \ maxfps) / 5) * 5   'framerate
csSetTimer AnmTimer, 100                              'anmcounter (1/10 sec)
csSetTimer HiResTimer, 5                              'generic 5ms timer

END SUB

FUNCTION LevelComplete

IF levelcompleteflag THEN
  levelcompleteflag = 0
  LevelComplete = 1
 ELSE
  LevelComplete = 0
END IF

END FUNCTION

SUB LoadLevel (level)

'====[ LOAD MAP ]====
OPEN "levels.dat" FOR INPUT AS 1
  INPUT #1, temp
  FOR l = 1 TO level
    INPUT #1, mapfile$
    INPUT #1, maplocation$: INPUT #1, temp$
    INPUT #1, temp: INPUT #1, temp: INPUT #1, temp
    FOR t = 1 TO temp
      INPUT #1, temp2: INPUT #1, temp2: INPUT #1, temp2: INPUT #1, temp2&
    NEXT t
  NEXT l
CLOSE 1

LoadMap mapfile$

'----[ Reset Player Status ]----
player(0).dead = 0
player(0).onground = 0
player(0).onslope = 0
player(0).onlift = 0
player(0).onball = 0
player(0).canjump = 0
player(0).reload = 0
player(0).shooting = 0
player(0).shootingframe = 0
player(0).aim = -1
player(0).action = moving
player(0).actiontime = 0
player(0).frozen = 0
player(0).usingportal = 0
player(0).keyred = 0
player(0).keygrn = 0
player(0).keyblu = 0
player(0).keyyel = 0
DoCamera

END SUB

SUB LoadPalette

'--- Set the palette ---
OPEN "palette.dat" FOR BINARY AS 1: GET #1, , pal(0): CLOSE 1

'--- Load the blender map ---
'a = DQBcreateBMap(1, 144, 144): IF a THEN ErrorHandlerSub 180
'a = DQBloadBMap(1, "blue.bln"): IF a THEN ErrorHandlerSub 180 + a

END SUB

SUB MainLoop

DO
  DoTimers
  IF FrameReady THEN
    DoInput
    IF gameplay = running THEN
      IF movemode = jumpmode THEN
        UpdateChangingTiles
        DoPhysics
        DoPlayerOnLift
        HandleLifts
        DoSprites
        DoItems
        DoShots
        HandleEnemies
        DoPlayerState
        DoCamera
       ELSEIF movemode = mapmode THEN
        DoMapModePhysics
        DoSprites
        DoMapModePlayerState
        DoMapModePlayerFrame
        DoCamera
      END IF
    END IF
    DoDropdownStatus
    DrawScreen
  END IF
 
  IF LevelComplete THEN EndLevel 1             ' end level with victory
  IF GameComplete THEN gamecompleteflag = 0: WinGame
  IF player(0).dead THEN DoPlayerDead          ' end level or try again menu
  IF GameOver THEN gameoverflag = 0: EndGame   ' return to start screen
 
LOOP UNTIL quitgame

END SUB

SUB PrepareOverheadMap

f = FREEFILE
OPEN "levels.dat" FOR INPUT AS f
  INPUT #f, numlevels
  FOR l = 1 TO numlevels
    INPUT #f, temp$: INPUT #f, temp$: INPUT #f, temp$
    INPUT #f, flagx: INPUT #f, flagy
    IF levelscomplete(l) AND l > 2 AND flagx >= 0 AND flagy >= 0 THEN a = AddSprite(flagx, flagy, 1342, 1345, 6, 26, 32, 0, 1, -1)
    INPUT #f, tilestochange
    FOR t = 1 TO tilestochange
      INPUT #f, tilelayer: INPUT #f, tilex: INPUT #f, tiley
      INPUT #f, newtile&
      IF levelscomplete(l) THEN
        IF tilelayer = 0 THEN SetMap tilex, tiley, newtile&
        IF tilelayer = 1 THEN SetMapFG tilex, tiley, newtile&
      END IF
    NEXT t
  NEXT l
CLOSE f

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

SUB SetGameComplete

gamecompleteflag = 1

END SUB

SUB SetGameOver

gameoverflag = 1

END SUB

SUB SetLevelComplete

levelcompleteflag = 1

END SUB

SUB SetPalette

DQBsetPal pal(0)

'--- Set the border color ---
'OUT &H3C7, -1
'OUT &H3C9, 0
'OUT &H3C9, 32
'OUT &H3C9, 32

END SUB

SUB StartLevel (level)
' Exit map and start a regular level

IF levelscomplete(level) THEN EXIT SUB    ' exit if already played

mark& = TimerTicks(HiResTimer) + (1000 \ 5)

EndMusic                   ' stop music
PlaySound 2                ' end of level sound

player(0).mapx = player(0).x
player(0).mapy = player(0).y
player(0).mapxdir = player(0).xdir

curlevel = level           ' set level to overhead map
DrawLoadingBox curlevel    ' draw loading screen
LoadLevel curlevel         ' load next level to memory

gameplay = running: pausedingame = 0
movemode = jumpmode
gamemode = ingame

WHILE TimerTicks(HiResTimer) < mark&: WEND

END SUB

SUB TakeScreenshot

slot = 0

DO
  slot$ = LTRIM$(STR$(slot))
  slot$ = STRING$(4 - LEN(slot$), "0") + slot$
  file$ = "SHOT" + slot$ + ".BMP": f = FREEFILE

  '--- Check for file existance ---
  ON ERROR GOTO CheckFile
  OPEN file$ FOR INPUT AS f: fs& = LOF(f): CLOSE f
  ON ERROR GOTO ErrorHandler
  IF fs& = 0 THEN
    DQBprint drawpage, "Commander Keen 7: Build 16", 189, 192, 15
    a = DQBsaveImage(drawpage, 0, 0, 319, 199, file$, pal(0), 1)
    IF a THEN debuglog "WARNING: Unable to write screenshot to " + file$ + "."
    shotsaved = 1 + a
   ELSE
    fs& = 0: slot = slot + 1
  END IF
LOOP UNTIL shotsaved

IF shotsaved = 1 THEN DQBprint drawpage, "Saved to " + file$, 207, 2, 15
DQBcopyLayer drawpage, video
mark& = TimerTicks(HiResTimer) + 50
WHILE TimerTicks(HiResTimer) < mark&: WEND

END SUB

FUNCTION TimerTicked (tmr)

TimerTicked = CSTimerFlag(tmr)

END FUNCTION

FUNCTION TimerTicks& (tmr)

ticks& = CSElapsedTicks&(tmr)
TimerTicks& = ticks&

END FUNCTION


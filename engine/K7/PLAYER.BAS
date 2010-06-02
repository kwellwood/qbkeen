DEFINT A-Z
'$INCLUDE: 'engine.bi'
'$INCLUDE: 'tiles.bi'
'$INCLUDE: 'map.bi'
'$INCLUDE: 'sound.bi'
'$INCLUDE: 'switches.bi'
'$INCLUDE: 'teleport.bi'
'$INCLUDE: 'climbing.bi'
'$INCLUDE: 'weapons.bi'
'$INCLUDE: 'render.bi'
'$INCLUDE: 'player.bi'
DECLARE SUB DoCantSwim ()
DECLARE SUB DoGetScubaGear ()
DECLARE SUB TryAgainMenu ()
DECLARE FUNCTION BounderTouchPlayer ()
'$STATIC

ON ERROR GOTO ErrorHandler

DIM SHARED friction!, gravity!
DIM SHARED pframe(maxplayerframes) AS LONG, fsize(maxplayerframes) AS intcoordinate
'============================================================================
ErrorHandler:
e = ERR
ErrorHandlerSub e
RESUME NEXT

SUB CheckEnterLevel

' Used for entering a level from the overhead map

' Entry tile has a tiletag2 of 12 and the switchtag is level to go to

tx = INT(player(0).x / ts + 1)
ty = INT(player(0).y / ts + 1)

IF TileType2(Map&(tx, ty)) = 12 OR TileType2(MapFG&(tx, ty)) THEN
  StartLevel INT(SwitchTag&(tx, ty))
END IF

END SUB

SUB CheckJumpHeight

'--- rest jump allowed ---
IF player(0).onground THEN player(0).canjump = ts * player(0).jumpheight

'--- decrease jump allowed ---
IF player(0).yv < 0 THEN player(0).canjump = player(0).canjump + player(0).yv
IF player(0).canjump < 0 THEN player(0).canjump = 0

END SUB

SUB ClipPlayerToMap

IF player(0).action = dying THEN EXIT SUB

FOR cp = 1 TO 8
  SELECT CASE HitPoint(clippoint(cp).x, clippoint(cp).y)
   CASE 1: HitWall cp, clippoint(cp).x, clippoint(cp).y
   CASE 2: IF cp = 2 THEN HitSlope clippoint(cp).x, clippoint(cp).y, 0
   CASE 3: KillPlayer
   CASE 6: IF cp = 2 AND player(0).yv >= 0 THEN HitWall cp, clippoint(cp).x, clippoint(cp).y
   CASE 7: IF cp = 2 THEN UnlockDoor
   CASE 8: IF cp = 2 THEN HitSlope clippoint(cp).x, clippoint(cp).y, 1
   CASE 9: HitWall cp, clippoint(cp).x, clippoint(cp).y
   CASE 10: SetLevelComplete
   CASE 13: DoGetScubaGear: SetLevelComplete
  END SELECT
  UpdateClipPoints
NEXT cp

END SUB

SUB DoMapModePhysics

UpdateClipPoints
'=============================[ MOVE PLAYER ]================================

'--- Max speed ---
IF player(0).xv > 2.4 THEN player(0).xv = 2.4
IF player(0).yv > 2! THEN player(0).yv = 2!
IF player(0).xv < -2.4 THEN player(0).xv = -2.4
IF player(0).yv < -2! THEN player(0).yv = -2!

'--- Move Player ---
player(0).x = player(0).x + player(0).xv
player(0).y = player(0).y + player(0).yv

'--- Friction ---
player(0).xv = player(0).xv * (friction! / 2)
player(0).yv = player(0).yv * (friction! / 2)
IF player(0).xv < .2 AND player(0).xv > 0 THEN player(0).xv = 0
IF player(0).xv > -.2 AND player(0).xv < 0 THEN player(0).xv = 0
IF player(0).yv < .2 AND player(0).yv > 0 THEN player(0).yv = 0
IF player(0).yv > -.2 AND player(0).yv < 0 THEN player(0).yv = 0

'--- Map boundaries ---
IF player(0).x - 7! < 0 THEN player(0).x = 7!: player(0).xv = 0
IF player(0).y - 7! < 0 THEN player(0).y = 7!: player(0).yv = 0
IF player(0).x + 7! > (MapWidth * ts) - 1 THEN player(0).x = (MapWidth * ts) - 1 - 7!
IF player(0).y + 7! > (MapHeight * ts) - 1 THEN player(0).y = (MapHeight * ts) - 1 - 7!

UpdateClipPoints
'===============================[ CLIPPING ]=================================
' 3--1--4
' |     |
' 5     6
' |     |
' 7     8
' |     |
' 9--2-10

MapModeClipPlayer
UpdateClipPoints

END SUB

SUB DoMapModePlayerFrame

IF player(0).xdir = UP THEN frameslot = 52
IF player(0).xdir = DOWN THEN frameslot = 53
IF player(0).xdir = left THEN frameslot = 54
IF player(0).xdir = right THEN frameslot = 55
IF player(0).xdir = UPLEFT THEN frameslot = 56
IF player(0).xdir = UPRIGHT THEN frameslot = 57
IF player(0).xdir = DOWNLEFT THEN frameslot = 58
IF player(0).xdir = DOWNRIGHT THEN frameslot = 59

IF player(0).action = moving THEN
  IF player(0).xv <> 0 OR player(0).yv <> 0 THEN
    anmframe = 1 + INT(anmcounter / player(0).adelay) MOD 4
    IF anmframe = 1 THEN anmframe = 0      ' standing
    IF anmframe = 2 THEN anmframe = 1      ' left step
    IF anmframe = 3 THEN anmframe = 0      ' standing
    IF anmframe = 4 THEN anmframe = 2      ' right step
   ELSE
    anmframe = 0                           ' standing still
  END IF
 ELSEIF player(0).action = swimming THEN
  anmframe = INT(anmcounter / player(0).adelay) MOD 2
  frameslot = frameslot + 8
END IF

player(0).frame = PlayerFrame&(frameslot) + anmframe
player(0).txsize = PFrameSizeX(frameslot)
player(0).tysize = PFrameSizeY(frameslot)

END SUB

SUB DoMapModePlayerState

'---[ player action ]---
mx = INT(player(0).x / ts) + 1
my = INT(player(0).y / ts) + 1
IF TileType(Map&(mx, my)) = 13 THEN
  IF player(0).scuba = 0 THEN
    xv! = player(0).xv / (friction! / 2)
    yv! = player(0).yv / (friction! / 2)
    player(0).x = player(0).x - xv!: player(0).xv = 0
    player(0).y = player(0).y - yv!: player(0).yv = 0
    DoCantSwim
    player(0).action = moving
   ELSE
    player(0).action = swimming
  END IF
 ELSE
  player(0).action = moving
END IF

'---[ player direction ]---
IF player(0).action = moving OR player(0).action = swimming THEN
  IF player(0).xv = 0 AND player(0).yv < 0 THEN player(0).xdir = UP
  IF player(0).xv > 0 AND player(0).yv < 0 THEN player(0).xdir = UPRIGHT
  IF player(0).xv > 0 AND player(0).yv = 0 THEN player(0).xdir = right
  IF player(0).xv > 0 AND player(0).yv > 0 THEN player(0).xdir = DOWNRIGHT
  IF player(0).xv = 0 AND player(0).yv > 0 THEN player(0).xdir = DOWN
  IF player(0).xv < 0 AND player(0).yv > 0 THEN player(0).xdir = DOWNLEFT
  IF player(0).xv < 0 AND player(0).yv = 0 THEN player(0).xdir = left
  IF player(0).xv < 0 AND player(0).yv < 0 THEN player(0).xdir = UPLEFT
END IF

END SUB

SUB DoPhysics

'--- No physics if doing these actions ---
IF player(0).action = climbing THEN EXIT SUB
IF player(0).action = hanging OR player(0).action = hangclimb THEN EXIT SUB

UpdateClipPoints
'=============================[ MOVE PLAYER ]================================

'--- Pogo Stick ---
IF player(0).action = pogo THEN HandlePogoStick

'--- Gravity ---
IF player(0).onground = 0 THEN player(0).yv = player(0).yv + gravity!

'--- Max speed ---
IF player(0).xv > player(0).xmax THEN player(0).xv = player(0).xmax
IF player(0).yv > player(0).ymax THEN player(0).yv = player(0).ymax
IF player(0).xv < -player(0).xmax THEN player(0).xv = -player(0).xmax
IF player(0).yv < -player(0).ymax THEN player(0).yv = -player(0).ymax

'--- Move Player ---
player(0).x = player(0).x + player(0).xv
player(0).y = player(0).y + player(0).yv

'--- Friction ---
IF player(0).action <> pogo THEN player(0).xv = player(0).xv * friction!
IF player(0).xv < .2 AND player(0).xv > 0 THEN player(0).xv = 0
IF player(0).xv > -.2 AND player(0).xv < 0 THEN player(0).xv = 0

'--- Map boundaries ---
IF player(0).x - player(0).xsize / 2 < 0 THEN player(0).x = player(0).xsize / 2: player(0).xv = 0
IF player(0).y - player(0).ysize / 2 < 0 THEN player(0).y = player(0).ysize / 2: player(0).yv = 0
IF player(0).x + player(0).xsize / 2 > (MapWidth * ts) - 1 THEN player(0).x = (MapWidth * ts) - 1 - (player(0).xsize / 2)
IF player(0).y + player(0).ysize / 2 > (MapHeight * ts) - 1 THEN player(0).y = (MapHeight * ts) - 1 - (player(0).ysize / 2)

UpdateClipPoints
'===============================[ CLIPPING ]=================================

'-- If player not on ground then start falling, or stick to slopes --
'--   if standing on them                                          --
EntityOnGround player(0).onground, player(0).onslope, player(0).onlift OR player(0).onball, player(0).x, player(0).y, player(0).yv, player(0).ysize
  player(0).onground = global(0).onground
  player(0).onslope = global(0).onslope
  player(0).y = global(0).y: player(0).yv = global(0).yv
  '-- Allow player to jump again --
  IF player(0).onground THEN player(0).stoppedjump = 0
  UpdateClipPoints
ClipPlayerToMap
UpdateClipPoints
'========================[ CHECK NEW PLAYER STATE ]==========================
CheckJumpHeight   ' has player reached the apogee of a jump?
DoPlayerOnBall    ' check if the player is riding a bounder

END SUB

SUB DoPlayerFrame

'===========================[ NEW FRAME SYSTEM ]=============================
SELECT CASE player(0).action
 CASE moving
  MovingFrames
 CASE switching
  SwitchingFrames
 CASE dying
  DyingFrames
 CASE teleporting
  TeleportingFrames
 CASE climbing
  ClimbingFrames
 CASE pogo
  PogoFrames
 CASE hanging
  HangingFrames
 CASE hangclimb
  HangClimbFrames
 CASE idle
  IdleFrames
END SELECT

IF player(0).shooting THEN ShootingFrames

'pframe(0)  - stand left
'pframe(1)  - walk left start
'pframe(2)  - walk left frames
'pframe(3)  - stand right
'pframe(4)  - walk right start
'pframe(5)  - walk right frames
'pframe(6)  - left jump up
'pframe(7)  - left jump apex
'pframe(8)  - left falling
'pframe(9)  - right jump up
'pframe(10) - right jump apex
'pframe(11) - right falling
'pframe(12) - looking up
'pframe(13) - looking down
'pframe(14) - shoot walk left
'pframe(15) - shoot walk right
'pframe(16) - shoot stand up
'pframe(17) - shoot jump left
'pframe(18) - shoot jump right
'pframe(19) - shoot jump up
'pframe(20) - shoot jump down

END SUB

SUB DoPlayerOnBall

'--- is keen on a bounder? ---
player(0).onball = 0
IF player(0).action = hangclimb THEN EXIT SUB   ' if hanging from a ledge
IF player(0).action = dying THEN EXIT SUB       ' if already dead
IF player(0).onlift THEN EXIT SUB               ' if on a lift

onball = BounderTouchPlayer

IF onball AND player(0).yv >= 0 THEN
  player(0).onball = onball
  e = onball

  '--- clip player to ball ---
  player(0).yv = 0
  player(0).y = (enemy(e).y - (enemy(e).tysize / 2)) - (player(0).ysize / 2) + 1!
  player(0).onground = 1
  player(0).canjump = ts * player(0).jumpheight
  IF player(0).action = hanging THEN player(0).action = moving
  player(0).holdingjump = 0
  player(0).stoppedjump = 0
  UpdateClipPoints
END IF

END SUB

SUB DoPlayerState

'---[ idletime start ]---
IF player(0).action = moving AND player(0).xv = 0 AND player(0).yv = 0 THEN
  IF player(0).frozen = 0 AND player(0).idletime > maxfps * 10 THEN
    player(0).action = idle
    player(0).actiontime = maxfps * 5.75
    player(0).frozen = 1
  END IF
END IF

'---[ idletime handing ]---
IF player(0).action = idle THEN
  IF player(0).idletime > 0 THEN
    IF player(0).actiontime = 18 THEN player(0).actiontime = 199
   ELSEIF player(0).idletime < maxfps AND player(0).actiontime > 17 THEN
    player(0).actiontime = 17
  END IF
END IF

'---[ actiontime ]---
IF player(0).actiontime THEN player(0).actiontime = player(0).actiontime - 1
IF player(0).actiontime < 0 THEN player(0).actiontime = 0

'---[ changeaction ]---
IF player(0).changeaction THEN player(0).changeaction = player(0).changeaction - 1
IF player(0).changeaction < 0 THEN player(0).changeaction = 0

'---[ shooting ]---
IF player(0).shooting THEN
  player(0).shooting = player(0).shooting - 1
  SetShootingFrame
END IF

'---[ reload ]---
IF player(0).reload THEN player(0).reload = player(0).reload - 1

'---[ unfreeze if moving ]---
IF player(0).action = moving AND player(0).shooting = 0 THEN player(0).frozen = 0

'---[ player direction ]---
IF player(0).action = moving OR player(0).action = pogo THEN
  IF player(0).xv < 0 THEN player(0).xdir = left
  IF player(0).xv > 0 THEN player(0).xdir = right
END IF

SELECT CASE player(0).action
 CASE dying '**************** DYING ****************
  IF player(0).actiontime = 0 THEN
    IF player(0).lives > 0 THEN
      player(0).dead = 1
     ELSE
      player(0).actiontime = 1
      SetGameOver
      'gameplay = paused: gamemode = inmenu: player(0).actiontime = 1
    END IF
  END IF

 CASE teleporting '************ TELEPORT ************
  IF player(0).actiontime = 0 THEN TeleportPlayer
                 
 CASE climbing '************* CLIMBING *************
  player(0).holdingjump = 0
  player(0).stoppedjump = 0
 CASE hangclimb '*********** HANG CLIMBING ***********
  IF player(0).actiontime = 0 THEN FinishHangClimb
END SELECT

'---[ resume walking ]---
IF player(0).actiontime = 0 THEN
  IF player(0).action <> climbing AND player(0).action <> pogo AND player(0).action <> hanging AND player(0).action <> dying THEN player(0).action = moving
END IF

DoPlayerFrame

END SUB

SUB DrawPlayer

'-- draw the player --
px = INT(player(0).x - CameraOrigX - (player(0).txsize / 2))
py = INT(player(0).y - CameraOrigY - (player(0).tysize / 2))
PutSprite player(0).frame, px, py, drawpage

END SUB

SUB DyingFrames

player(0).frame = PlayerFrame&(22)
player(0).txsize = PFrameSizeX(22)
player(0).tysize = PFrameSizeY(22)

END SUB

SUB HandlePogoStick

'--- if bouncing ---
IF player(0).onground THEN
  PlaySound 11
  '--- bounce ---
  player(0).yv = player(0).yv - player(0).ymax * 2
  '--- allow to jump higher ---
  player(0).canjump = ts * player(0).jumpheight * 2
  '--- reset jump input vars ---
  'player(0).holdingjump = 0
  player(0).stoppedjump = 0
END IF

'--- stop input when starting to slow ascent ---
IF player(0).yv > -player(0).ymax AND player(0).holdingjump = 0 THEN player(0).stoppedjump = 1

END SUB

SUB HitSlope (x!, y!, l)

x = INT(x!): y = INT(y!)
h = SlopeHeight(x, y, l)

'--- correct bad values ---
IF h > ts THEN h = ts
IF h < -ts THEN h = -ts

IF h THEN
  player(0).y = INT(player(0).y) + h
  player(0).yv = 0
  player(0).onground = 1
  player(0).onslope = 1
  'player(0).holdingjump = 0
  player(0).stoppedjump = 0
END IF

END SUB

SUB HitWall (p, hx!, hy!)
          
' 3--1--4
' |     |
' 5     6
' |     |
' 7     8
' |     |
' 9--2-10

side = -1

IF p = 1 THEN
  ny! = INT((hy! - (INT(hy!) MOD ts)) + ts)
  side = UP
 ELSEIF p = 2 THEN
  ny! = INT((hy! - (INT(hy!) MOD ts)) - 1)
  side = DOWN
 ELSEIF p = 3 OR p = 5 OR p = 7 OR p = 9 THEN
  nx! = ((INT(hx!) \ ts) + 1) * ts
  side = right
 ELSEIF p = 4 OR p = 6 OR p = 8 OR p = 10 THEN
  nx! = (hx! \ ts) * ts - 1
  side = left
END IF

SELECT CASE side
 CASE UP
  player(0).yv = 0
  player(0).y = INT(ny! + (player(0).ysize / 2)) + 1
  PlaySound 8
 CASE DOWN
  player(0).yv = 0
  player(0).y = INT(ny! - (player(0).ysize / 2))
  player(0).onground = 1
 CASE left
  player(0).xv = 0
  IF p = 4 OR p = 6 OR p = 8 OR p = 10 THEN player(0).x = INT(nx! - (player(0).xsize / 2))
 CASE right
  player(0).xv = 0
  IF p = 3 OR p = 5 OR p = 7 OR p = 9 THEN player(0).x = INT(nx! + (player(0).xsize / 2))
END SELECT

UpdateClipPoints
'--- check for hitting a ledge ---
IF (side = left OR side = right) AND (p = 5 OR p = 6) THEN
  IF clippoint(p).y MOD ts < ts / 2 THEN
    mx = INT(clippoint(p).x / ts + 1)
    my = INT(clippoint(p).y / ts + 1)
    CheckForLedge side, mx, my
  END IF
END IF

END SUB

SUB IdleFrames

'player(0).actiontime
'->maxfps*5.75
'-start 1
' [maxfps] - sitting down
'-start 2                      <-+
' [maxfps*4] - reading           |
'-start 3                        |
' [maxfps/2] - turning page      |
'-end 3                       ---+
'-start 4
' [maxfps] - standing up
'->0

start1 = maxfps * 5.75: end1 = start1 - (maxfps * .75)
start2 = end1 - 1: end2 = start2 - (maxfps * 4)
start3 = end2 - 1: end3 = start3 - (maxfps / 2)
start4 = end3 - 1: end4 = 0

SELECT CASE player(0).actiontime
 CASE end1 TO start1
  player(0).frame = PlayerFrame&(45) + INT(((maxfps * .75) - (player(0).actiontime - end1)) / ((maxfps * .75) / PlayerFrame&(46)))
  player(0).txsize = PFrameSizeX(45)  '(frame&)
  player(0).tysize = PFrameSizeY(45)  '(frame&)
 CASE end2 TO start2
  player(0).frame = PlayerFrame&(47)
  player(0).txsize = PFrameSizeX(47)
  player(0).tysize = PFrameSizeY(47)
 CASE end3 TO start3
  player(0).frame = PlayerFrame&(48) + INT(((maxfps / 2) - (player(0).actiontime - end3)) / ((maxfps / 2) / PlayerFrame&(49)))
  player(0).txsize = PFrameSizeX(48)
  player(0).tysize = PFrameSizeY(48)
 CASE end4 TO start4
  player(0).frame = PlayerFrame&(50) + INT(((maxfps / 2) - (player(0).actiontime - end4)) / ((maxfps / 2) / PlayerFrame&(51)))
  player(0).txsize = PFrameSizeX(50)
  player(0).tysize = PFrameSizeY(50)
END SELECT

END SUB

SUB InitPlayer

OPEN "engine.dat" FOR INPUT AS 1
  DO: INPUT #1, Text$
  LOOP UNTIL UCASE$(Text$) = "[PLAYER.DAT]"
  INPUT #1, player(0).adelay      ' animation speed
  FOR f = 0 TO maxplayerframes
    INPUT #1, pframe(f)     ' frame's tile
    INPUT #1, fsize(f).x    ' x size
    INPUT #1, fsize(f).y    ' y size
  NEXT f
CLOSE 1
player(0).lives = 3
player(0).ammo = 5
player(0).score = 0

END SUB

SUB InitPlayerState

'-- This is used for resetting player state right
'   after loading a map with LoadMap

player(0).action = moving
player(0).actiontime = 0
player(0).idletime = 0
player(0).xv = 0: player(0).yv = 0
player(0).frozen = 0
player(0).reload = 0
player(0).holdingjump = 0
player(0).stoppedjump = 0
player(0).onlift = 0
player(0).onball = 0
player(0).changeaction = 0

END SUB

SUB KillPlayer

IF player(0).action <> dying AND player(0).invincible = 0 THEN
  gamemode = ingame
  player(0).action = dying
  player(0).actiontime = maxfps
  player(0).frozen = 1
  player(0).onground = 0
  player(0).xv = 0
  player(0).yv = -20
  PlaySound 3
END IF

END SUB

SUB MapModeClipPlayer

FOR cp = 1 TO 8
  SELECT CASE HitPoint(clippoint(cp).x, clippoint(cp).y)
   CASE 1: MapModeHitWall cp, clippoint(cp).x, clippoint(cp).y
   'CASE 2: IF cp = 2 THEN HitSlope clippoint(cp).x, clippoint(cp).y, 0
   'CASE 8: IF cp = 2 THEN HitSlope clippoint(cp).x, clippoint(cp).y, 1
   CASE 9: MapModeHitWall cp, clippoint(cp).x, clippoint(cp).y
  END SELECT
  UpdateClipPoints
NEXT cp

END SUB

SUB MapModeHitWall (p, hx!, hy!)

side = -1

IF p = 1 THEN
  ny! = INT((hy! - (INT(hy!) MOD ts)) + ts)
  side = UP
 ELSEIF p = 2 THEN
  ny! = INT((hy! - (INT(hy!) MOD ts)) - 1)
  side = DOWN
 ELSEIF p = 3 OR p = 5 OR p = 7 OR p = 9 THEN
  nx! = INT((hx! - (INT(hx!) MOD ts)) + ts)
  side = right
 ELSEIF p = 4 OR p = 6 OR p = 8 OR p = 10 THEN
  nx! = INT((hx! - (INT(hx!) MOD ts)) - 1)
  side = left
END IF

SELECT CASE side
 CASE UP
  player(0).yv = 0
  player(0).y = INT(ny! + 7!) + 1!
 CASE DOWN
  player(0).yv = 0
  player(0).y = INT(ny! - 7!)
 CASE left
  player(0).xv = 0
  IF p = 4 OR p = 6 OR p = 8 OR p = 10 THEN player(0).x = INT(nx! - 7!)
 CASE right
  player(0).xv = 0
  IF p = 3 OR p = 5 OR p = 7 OR p = 9 THEN player(0).x = INT(nx! + 7!)
END SELECT

UpdateClipPoints

END SUB

SUB MovePlayer (D)

player(0).idletime = 0

SELECT CASE D
 '-- jump up --
 CASE UP
  IF movemode = jumpmode THEN
    IF player(0).frozen = 0 THEN
      IF (player(0).yv < 0 AND player(0).onground = 0 AND player(0).onball = 0 AND player(0).onlift = 0) OR (player(0).yv = 0 AND player(0).onground) OR (player(0).action = climbing) THEN
        IF player(0).canjump AND player(0).stoppedjump = 0 THEN
          IF (player(0).action = climbing AND player(0).changeaction = 0) OR (player(0).action <> climbing) THEN
            IF player(0).onground = 0 OR player(0).holdingjump = 0 THEN  'stop repeat jumping
              IF player(0).holdingjump = 0 THEN PlaySound 9
              player(0).holdingjump = 1
              player(0).yv = -player(0).ymax
              IF player(0).action = climbing THEN   '-- jumping from a pole --
                player(0).changeaction = maxfps / 3 ' wait to grab pole again
                player(0).yv = player(0).yv / 4     ' 1/4 jump power
              END IF
              IF player(0).action <> pogo THEN player(0).action = moving
            END IF
          END IF
        END IF
      END IF
    END IF
   ELSEIF movemode = mapmode THEN
    player(0).yv = player(0).yv - 2
  END IF
 '-- move down --
 CASE DOWN
  IF movemode = jumpmode THEN
    IF player(0).action = hanging AND player(0).changeaction = 0 THEN player(0).action = moving
   ELSEIF movemode = mapmode THEN
    player(0).yv = player(0).yv + 2
  END IF
 '-- walk left --
 CASE left
  IF movemode = jumpmode THEN
    IF player(0).action = climbing THEN
      player(0).xdir = left
     ELSEIF player(0).action = hanging THEN
      IF player(0).changeaction = 0 THEN
        IF player(0).xdir = left THEN HangClimbUp ELSE player(0).action = moving
      END IF
     ELSE
      IF player(0).frozen = 0 THEN
        player(0).xdir = left
        IF player(0).onground THEN
          player(0).xv = player(0).xv - 2
         ELSEIF player(0).action = pogo THEN
          player(0).xv = player(0).xv - .3
         ELSE
          player(0).xv = player(0).xv - 1'.5
        END IF
      END IF
    END IF
   ELSEIF movemode = mapmode THEN
    player(0).xv = player(0).xv - 2
  END IF
 '-- walk right --
 CASE right
  IF movemode = jumpmode THEN
    IF player(0).action = climbing THEN
      player(0).xdir = right
     ELSEIF player(0).action = hanging THEN
      IF player(0).changeaction = 0 THEN
        IF player(0).xdir = right THEN HangClimbUp ELSE player(0).action = moving
      END IF
     ELSE
      IF player(0).frozen = 0 THEN
        player(0).xdir = right
        IF player(0).onground THEN
          player(0).xv = player(0).xv + 2
         ELSEIF player(0).action = pogo THEN
          player(0).xv = player(0).xv + .3
         ELSE
          player(0).xv = player(0).xv + 1  '.5
        END IF
      END IF
    END IF
   ELSEIF movemode = mapmode THEN
    player(0).xv = player(0).xv + 2
  END IF
END SELECT

END SUB

SUB MovingFrames

IF player(0).onground THEN         ' player is standing
  IF player(0).xdir = left THEN
    IF player(0).xv < 0 THEN       ' walk left
      framedataslot = 1
      anmframe = INT(anmcounter / player(0).adelay) MOD PlayerFrame&(2)
     ELSE
      framedataslot = 0: anmframe = 0
    END IF
   ELSEIF player(0).xdir = right THEN
    IF player(0).xv > 0 THEN       ' walk right
      framedataslot = 4
      anmframe = INT(anmcounter / player(0).adelay) MOD PlayerFrame&(5)
     ELSE
      framedataslot = 3: anmframe = 0
    END IF
  END IF
 ELSE                             ' player is jumping/falling
  IF player(0).xdir = left THEN
    IF player(0).yv < -(player(0).ymax / 4) THEN
      framedataslot = 6: anmframe = 0
     ELSEIF player(0).yv > (player(0).ymax / 4) THEN
      framedataslot = 8: anmframe = 0
     ELSEIF player(0).yv >= -(player(0).ymax / 4) AND player(0).yv <= (player(0).ymax / 4) THEN
      framedataslot = 7: anmframe = 0
    END IF
   ELSEIF player(0).xdir = right THEN
    IF player(0).yv < -(player(0).ymax / 4) THEN
      framedataslot = 9: anmframe = 0
     ELSEIF player(0).yv > (player(0).ymax / 4) THEN
      framedataslot = 11: anmframe = 0
     ELSEIF player(0).yv >= -(player(0).ymax / 4) AND player(0).yv <= (player(0).ymax / 4) THEN
      framedataslot = 10: anmframe = 0
    END IF
  END IF
END IF

'anmframe is the number of frames to add for an animated pose.
'based on anmcounter.

player(0).frame = PlayerFrame&(framedataslot) + anmframe
player(0).txsize = PFrameSizeX(framedataslot)
player(0).tysize = PFrameSizeY(framedataslot)

END SUB

FUNCTION PFrameSizeX (slot)

PFrameSizeX = fsize(slot).x

END FUNCTION

FUNCTION PFrameSizeY (slot)

PFrameSizeY = fsize(slot).y

END FUNCTION

FUNCTION PlayerFacing (x!, y!)

IF (player(0).x > x! AND player(0).xdir = left) OR (player(0).x < x! AND player(0).xdir = right) THEN PlayerFacing = 1

END FUNCTION

FUNCTION PlayerFrame& (slot)

PlayerFrame& = pframe(slot)

END FUNCTION

SUB PogoFrames

SELECT CASE player(0).xdir
 CASE left
  IF player(0).yv < -player(0).ymax / 2 THEN framedataslot = 37 ELSE framedataslot = 38
 CASE right
  IF player(0).yv < -player(0).ymax / 2 THEN framedataslot = 39 ELSE framedataslot = 40
END SELECT

player(0).frame = PlayerFrame&(framedataslot) + anmframe
player(0).txsize = PFrameSizeX(framedataslot)
player(0).tysize = PFrameSizeY(framedataslot)

END SUB

SUB SetPlayerFriction (f!)

friction! = f!

END SUB

SUB SetPlayerGravity (g!)

gravity! = g!

END SUB

SUB ShiftPlayer (x!, y!)

player(0).x = player(0).x + x!
player(0).y = player(0).y + y!
UpdateClipPoints

END SUB

FUNCTION ShotPlayer (sx1, sy1, sx2, sy2)

'--- corners of player ---
px1 = player(0).x - (player(0).txsize / 2): py1 = player(0).y - (player(0).tysize / 2)
px2 = player(0).x + (player(0).txsize / 2): py2 = player(0).y + (player(0).tysize / 2)

'--- collision test ---
IF sx1 >= px1 AND sx1 <= px2 AND sy1 >= py1 AND sy1 <= py2 THEN ShotPlayer = 1
IF sx2 >= px1 AND sx2 <= px2 AND sy1 >= py1 AND sy1 <= py2 THEN ShotPlayer = 1
IF sx1 >= px1 AND sx1 <= px2 AND sy2 >= py1 AND sy2 <= py2 THEN ShotPlayer = 1
IF sx2 >= px1 AND sx2 <= px2 AND sy2 >= py1 AND sy2 <= py2 THEN ShotPlayer = 1
IF px1 >= sx1 AND px1 <= sx2 AND py1 >= sy1 AND py1 <= sy2 THEN ShotPlayer = 1
IF px2 >= sx1 AND px2 <= sx2 AND py1 >= sy1 AND py1 <= sy2 THEN ShotPlayer = 1
IF px1 >= sx1 AND px1 <= sx2 AND py2 >= sy1 AND py2 <= sy2 THEN ShotPlayer = 1
IF px2 >= sx1 AND px2 <= sx2 AND py2 >= sy1 AND py2 <= sy2 THEN ShotPlayer = 1


END FUNCTION

SUB TogglePogo

player(0).idletime = 0

IF player(0).changeaction > 0 THEN EXIT SUB     ' actions changed recently
IF player(0).frozen THEN EXIT SUB               ' player frozen

IF player(0).action <> pogo THEN
  player(0).action = pogo
  player(0).changeaction = maxfps / 5
 ELSE
  player(0).action = moving
  player(0).actiontime = 0
  player(0).changeaction = maxfps / 5
END IF

END SUB

SUB UpdateClipPoints

' 3--1--4
' |     |
' 5     6
' |     |
' 7     8
' |     |
' 9--2-10

IF movemode = mapmode THEN
  clippoint(3).x = player(0).x - 7!
  clippoint(3).y = player(0).y - 7!
  clippoint(4).x = player(0).x + 7!
  clippoint(4).y = player(0).y - 7!
  clippoint(9).x = player(0).x - 7!
  clippoint(9).y = player(0).y + 7!
  clippoint(10).x = player(0).x + 7!
  clippoint(10).y = player(0).y + 7!
  clippoint(1).x = player(0).x
  clippoint(1).y = player(0).y - 7!
  clippoint(2).x = player(0).x
  clippoint(2).y = player(0).y + 7!
  clippoint(5).x = player(0).x - 7!
  clippoint(5).y = player(0).y - 3!
  clippoint(6).x = player(0).x + 7!
  clippoint(6).y = player(0).y - 3!
  clippoint(7).x = player(0).x - 7!
  clippoint(7).y = player(0).y + 3!
  clippoint(8).x = player(0).x + 7!
  clippoint(8).y = player(0).y + 3!
 ELSE
  clippoint(3).x = player(0).x - (player(0).xsize / 2)
  clippoint(3).y = player(0).y - (player(0).ysize / 2)
  clippoint(4).x = player(0).x + (player(0).xsize / 2)
  clippoint(4).y = player(0).y - (player(0).ysize / 2)
  clippoint(9).x = player(0).x - (player(0).xsize / 2)
  clippoint(9).y = player(0).y + (player(0).ysize / 2)
  clippoint(10).x = player(0).x + (player(0).xsize / 2)
  clippoint(10).y = player(0).y + (player(0).ysize / 2)
  clippoint(1).x = player(0).x
  clippoint(1).y = player(0).y - (player(0).ysize / 2)
  clippoint(2).x = player(0).x
  clippoint(2).y = player(0).y + (player(0).ysize / 2)
  clippoint(5).x = player(0).x - (player(0).xsize / 2)
  clippoint(5).y = player(0).y - (player(0).ysize / 4)
  clippoint(6).x = player(0).x + (player(0).xsize / 2)
  clippoint(6).y = player(0).y - (player(0).ysize / 4)
  clippoint(7).x = player(0).x - (player(0).xsize / 2)
  clippoint(7).y = player(0).y + (player(0).ysize / 4)
  clippoint(8).x = player(0).x + (player(0).xsize / 2)
  clippoint(8).y = player(0).y + (player(0).ysize / 4)
END IF

END SUB


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
SUB CheckJumpHeight

'--- rest jump allowed ---
IF player(0).onground THEN player(0).canjump = ts * player(0).jumpheight

'--- decrease jump allowed ---
IF player(0).yv < 0 THEN player(0).canjump = player(0).canjump + player(0).yv
IF player(0).canjump < 0 THEN player(0).canjump = 0

END SUB

SUB CheckOnGround

'--- previous ground values ---
oldonslope = player(0).onslope
oldonground = player(0).onground
'--- map location of player's feet ---
mapx = INT(player(0).x / ts) + 1
mapy = INT((player(0).y + (player(0).ysize / 2)) / ts) + 1

'=========================[ CHECK FOR GROUND TILE ]==========================
IF player(0).yv >= 0 THEN
  mapx = INT(player(0).x / ts) + 1: mapy = INT((player(0).y + (player(0).ysize / 2)) / ts) + 1
  IF INT((player(0).y + (player(0).ysize / 2)) MOD ts) >= ts - 1 THEN
    mapx = INT(player(0).x / ts) + 1: mapy = INT((player(0).y + (player(0).ysize / 2)) / ts) + 2
    IF TileType(Map&(mapx, mapy)) = 1 OR TileType(MapFG&(mapx, mapy)) = 9 THEN
      player(0).onground = 1
      player(0).onslope = 0
      IF INT((player(0).y + (player(0).ysize / 2)) MOD ts) < ts - 1 THEN player(0).y = INT(player(0).y) + 1: UpdateClipPoints
     ELSE
      player(0).onground = 0
      player(0).onslope = 0
    END IF
   ELSE
    player(0).onground = 0
    player(0).onslope = 0
  END IF
 ELSE
  player(0).onground = 0
  player(0).onslope = 0
END IF

'if player is jumping or not moving at all
'  (mapx,mapy)=bottom of player's coordinates in tiles
'  if tile directly under player is a wall
'    (mapx,mapy)=coordinates of tile directly under player
'    if tile under player is wall
'      player is on ground
'      align on ground if not close enough
'     else
'      player is not on ground
'    end if
'   else
'    player is not on ground
'  end if
' else
'  player is not on ground
'end if

'===========================[ CHECK FOR SLOPES ]=============================
IF TileType(Map&(mapx, mapy)) = 2 OR TileType(MapFG&(mapx, mapy)) = 2 THEN
  IF TileType(Map&(mapx, mapy)) = 2 THEN l = 0 ELSE l = 1
  x = clippoint(2).x: y = clippoint(2).y
  h1 = SlopeHeight(x, y, l)
  h2 = SlopeHeight(x, y + 1, l)
  IF h1 = 0 AND h2 < 0 THEN
    player(0).onground = 1: player(0).onslope = 1
   ELSE
    player(0).onground = 0: player(0).onslope = 0
  END IF
END IF

'========================[ KEEP PLAYER ON A SLOPE ]==========================
IF player(0).onground = 0 AND oldonground = 1 THEN
  IF player(0).yv >= 0 THEN
    mapx = INT(player(0).x / ts) + 1
    mapy = INT((player(0).y + (player(0).ysize / 2)) / ts) + 1
    IF TileType(Map&(mapx, mapy)) = 2 OR TileType(MapFG&(mapx, mapy)) = 2 THEN
      slopetag = 1
     ELSEIF TileType(Map&(mapx, mapy + 1)) = 2 OR TileType(MapFG&(mapx, mapy + 1)) = 2 THEN
      slopetag = 1: mapy = mapy + 1
      player(0).y = player(0).y + (ts - (player(0).y + (player(0).ysize / 2) + ts) MOD ts)
    END IF
    IF slopetag THEN
      IF TileType(Map&(mapx, mapy)) = 2 THEN l = 0 ELSE l = 1
      player(0).y = player(0).y + (ts - (player(0).y + (player(0).ysize / 2) + 1) MOD ts) - 1
      x = INT(player(0).x): y = INT(player(0).y + (player(0).ysize / 2) + 1)
      player(0).y = player(0).y + SlopeHeight(x, y, l)
      player(0).yv = 0
      player(0).onground = 1: player(0).onslope = 1
      UpdateClipPoints
    END IF
  END IF
END IF

'-- Allow player to jump again --
IF player(0).onground THEN
  'player(0).holdingjump = 0
  player(0).stoppedjump = 0
END IF

END SUB

SUB ClipPlayerToMap

IF player(0).action = dying THEN EXIT SUB

FOR cp = 1 TO 8
  SELECT CASE HitPoint(cp)
   CASE 1: HitWall cp, clippoint(cp).x, clippoint(cp).y
   CASE 2: IF cp = 2 THEN HitSlope clippoint(cp).x, clippoint(cp).y, 0
   CASE 3: KillPlayer
   CASE 7: IF cp = 2 THEN UnlockDoor
   CASE 8: IF cp = 2 THEN HitSlope clippoint(cp).x, clippoint(cp).y, 1
   CASE 10: NextLevel
  END SELECT
  UpdateClipPoints
NEXT cp

END SUB

SUB DoPhysics

'--- No physics if on pole ---
IF player(0).action = climbing OR player(0).action = hanging OR player(0).action = hangclimb THEN EXIT SUB

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

'--- Round player location ---
'IF player(0).xv = 0 THEN player(0).x = INT(player(0).x)
'IF player(0).yv = 0 THEN player(0).y = INT(player(0).y)

'--- Map boundaries ---
IF player(0).x - player(0).xsize / 2 < 0 THEN player(0).x = player(0).xsize / 2: player(0).xv = 0
IF player(0).y - player(0).ysize / 2 < 0 THEN player(0).y = player(0).ysize / 2: player(0).yv = 0
IF player(0).x + player(0).xsize / 2 > (mapxsize * ts) - 1 THEN player(0).x = (mapxsize * ts) - 1 - (player(0).xsize / 2)
IF player(0).y + player(0).ysize / 2 > (mapysize * ts) - 1 THEN player(0).y = (mapysize * ts) - 1 - (player(0).ysize / 2)

UpdateClipPoints
'===============================[ CLIPPING ]=================================
' 3--1--4
' |     |
' 5     6
' |     |
' 7     8
' |     |
' 9--2-10

CheckOnGround     '<- if player not on ground then start falling, stick
ClipPlayerToMap   '   to slopes if on them

UpdateClipPoints
'========================[ CHECK NEW PLAYER STATE ]==========================
CheckJumpHeight   ' has player reached the apogee of a jump?

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

SUB DoPlayerOnLift

'--- is keen on a platform? ---
player(0).onlift = 0
IF player(0).action = hangclimb THEN EXIT SUB
FOR l = 1 TO numlifts
  IF LiftTouchPlayer(l) THEN player(0).onlift = l
NEXT l

IF player(0).onlift AND player(0).yv >= 0 THEN
  l = player(0).onlift

  '--- clip player to lift ---
  ny! = lift(l).y - 1
  player(0).yv = 0
  player(0).y = ny! - (player(0).ysize / 2)
  player(0).onground = 1
  player(0).canjump = ts * player(0).jumpheight
  IF player(0).action = hanging THEN player(0).action = moving
  player(0).holdingjump = 0
  player(0).stoppedjump = 0
  UpdateClipPoints
END IF

END SUB

SUB DrawPlayer

'-- draw the player --
px = player(0).x - camera(0).vx1 - (player(0).txsize / 2)
py = player(0).y - camera(0).vy1 - (player(0).tysize / 2)
PutSprite player(0).frame, px, py, drawpage

END SUB

SUB DyingFrames

player(0).frame = pframe(22)
player(0).txsize = fsize(22).x
player(0).tysize = fsize(22).y

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

FUNCTION HitPoint (p)

'fg =Foreground Tag 1
'fg2=Foreground Tag 2
'bg =Background Tag 1

mx = INT(clippoint(p).x / ts) + 1
my = INT(clippoint(p).y / ts) + 1
fg = TileType(MapFG&(mx, my))
fg2 = TileType2(MapFG&(mx, my))
bg = TileType(Map&(mx, my))
IF fg = 2 THEN HitPoint = 8: EXIT FUNCTION    'slope in foreground
IF fg = 7 THEN HitPoint = 7: EXIT FUNCTION    'gem socket
IF fg = 9 THEN HitPoint = 1: EXIT FUNCTION    'wall in foreground
IF fg2 = 10 THEN HitPoint = 10: EXIT FUNCTION 'exit level tile
HitPoint = bg

END FUNCTION

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
  side = up
 ELSEIF p = 2 THEN
  ny! = INT((hy! - (INT(hy!) MOD ts)) - 1)
  side = down
 ELSEIF p = 3 OR p = 5 OR p = 7 OR p = 9 THEN
  nx! = INT((hx! - (INT(hx!) MOD ts)) + ts)
  side = right
 ELSEIF p = 4 OR p = 6 OR p = 8 OR p = 10 THEN
  nx! = INT((hx! - (INT(hx!) MOD ts)) - 1)
  side = left
END IF

SELECT CASE side
 CASE up
  player(0).yv = 0
  player(0).y = INT(ny! + (player(0).ysize / 2)) + 1
  PlaySound 8
 CASE down
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
  IF clippoint(p).y MOD ts < ts / 2 THEN 'AND clippoint(p).y MOD ts > ts / 4 THEN
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
  player(0).frame = pframe(45) + INT(((maxfps * .75) - (player(0).actiontime - end1)) / ((maxfps * .75) / pframe(46)))
  player(0).txsize = fsize(frame&).x
  player(0).tysize = fsize(frame&).y
 CASE end2 TO start2
  player(0).frame = pframe(47)
  player(0).txsize = fsize(47).x
  player(0).tysize = fsize(47).y
 CASE end3 TO start3
  player(0).frame = pframe(48) + INT(((maxfps / 2) - (player(0).actiontime - end3)) / ((maxfps / 2) / pframe(49)))
  player(0).txsize = fsize(48).x
  player(0).tysize = fsize(48).y
 CASE end4 TO start4
  player(0).frame = pframe(50) + INT(((maxfps / 2) - (player(0).actiontime - end4)) / ((maxfps / 2) / pframe(51)))
  player(0).txsize = fsize(50).x
  player(0).tysize = fsize(50).y
END SELECT

END SUB

SUB KillPlayer

IF player(0).action <> dying THEN
  player(0).action = dying
  player(0).actiontime = maxfps
  player(0).frozen = 1
  player(0).onground = 0
  player(0).xv = 0
  player(0).yv = -20
  PlaySound 3
END IF

END SUB

SUB MovePlayer (d)

player(0).idletime = 0

SELECT CASE d
 '-- jump up --
 CASE up
  IF player(0).frozen = 0 THEN
    IF (player(0).yv < 0) OR (player(0).yv = 0 AND player(0).onground) OR (player(0).action = climbing) THEN
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
 '-- move down --
 CASE down
  IF player(0).action = hanging AND player(0).changeaction = 0 THEN player(0).action = moving
 '-- walk left --
 CASE left
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
 '-- walk right --
 CASE right
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
        player(0).xv = player(0).xv + 1'.5
      END IF
    END IF
  END IF
END SELECT

END SUB

SUB MovingFrames

IF player(0).onground THEN         ' player is standing
  IF player(0).xdir = left THEN
    IF player(0).xv < 0 THEN       ' walk left
      framedataslot = 1
      anmframe = INT(anmcounter / player(0).adelay) MOD pframe(2)
     ELSE
      framedataslot = 0: anmframe = 0
    END IF
   ELSEIF player(0).xdir = right THEN
    IF player(0).xv > 0 THEN       ' walk right
      framedataslot = 4
      anmframe = INT(anmcounter / player(0).adelay) MOD pframe(5)
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

player(0).frame = pframe(framedataslot) + anmframe
player(0).txsize = fsize(framedataslot).x
player(0).tysize = fsize(framedataslot).y

END SUB

SUB PlayerState

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
IF player(0).shooting THEN player(0).shooting = player(0).shooting - 1

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
      SLEEP 1
      player(0).lives = player(0).lives - 1
      LoadLevel
     ELSE
      gameplay = paused: gamemode = inmenu: player(0).actiontime = 1
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
  IF player(0).action <> climbing AND player(0).action <> pogo AND player(0).action <> hanging THEN player(0).action = moving
END IF

DoPlayerFrame

END SUB

SUB PogoFrames

SELECT CASE player(0).xdir
 CASE left
  IF player(0).yv < -player(0).ymax / 2 THEN framedataslot = 37 ELSE framedataslot = 38
 CASE right
  IF player(0).yv < -player(0).ymax / 2 THEN framedataslot = 39 ELSE framedataslot = 40
END SELECT

player(0).frame = pframe(framedataslot) + anmframe
player(0).txsize = fsize(framedataslot).x
player(0).tysize = fsize(framedataslot).y

END SUB

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

END SUB


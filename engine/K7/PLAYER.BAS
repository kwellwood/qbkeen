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

IF player(0).onground THEN player(0).canjump = ts * player(0).jumpheight
IF player(0).yv < 0 THEN player(0).canjump = player(0).canjump + player(0).yv
IF player(0).canjump < 0 THEN player(0).canjump = 0

END SUB

SUB CheckOnGround

'no vertical movement
'  standing on top of a block
'    block is wall

IF player(0).yv >= 0 THEN
  mapx = INT(player(0).x / ts) + 1: mapy = INT((player(0).y + (player(0).ysize / 2)) / ts) + 1
  IF INT((player(0).y + (player(0).ysize / 2)) MOD ts) >= ts - 1 THEN   ' ts - 2 THEN
    mapx = INT(player(0).x / ts) + 1: mapy = INT((player(0).y + (player(0).ysize / 2)) / ts) + 2
    IF TileType(Map&(mapx, mapy)) = 1 OR TileType(MapFG&(mapx, mapy)) = 9 THEN
      player(0).onground = 1
      IF INT((player(0).y + (player(0).ysize / 2)) MOD ts) < ts - 1 THEN player(0).y = INT(player(0).y) + 1
     ELSE
      player(0).onground = 0
    END IF
   ELSE
    player(0).onground = 0
  END IF
 ELSE
  player(0).onground = 0
END IF

IF TileType(Map&(mapx, mapy)) = 2 OR TileType(MapFG&(mapx, mapy)) = 2 THEN
  IF TileType(Map&(mapx, mapy)) = 2 THEN l = 0 ELSE l = 1
  x = ClipPoint(2).x: y = ClipPoint(2).y
  h1 = SlopeHeight(x, y, l)
  h2 = SlopeHeight(x, y + 1, l)
  IF h1 = 0 AND h2 > 0 THEN player(0).onground = 1: player(0).onslope = 1
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

END SUB

SUB ClipPlayerToMap

IF player(0).action = dying THEN EXIT SUB

FOR cp = 1 TO 8
  SELECT CASE HitPoint(cp)  'if player clippoint(cp) is on a special tile
   CASE 1: HitWall cp, ClipPoint(cp).x, ClipPoint(cp).y
   CASE 2: IF cp = 2 THEN HitSlope ClipPoint(cp).x, ClipPoint(cp).y, 0
   CASE 3: KillPlayer
   CASE 8: IF cp = 2 THEN HitSlope ClipPoint(cp).x, ClipPoint(cp).y, 1
   CASE 9: HitWall cp, ClipPoint(cp).x, ClipPoint(cp).y
  END SELECT
NEXT cp

END SUB

SUB DoPhysics

UpdateClipPoints
IF player(0).action = climbing THEN EXIT SUB

'=======[ GRAVITY ]=======
IF player(0).onground = 0 THEN player(0).yv = player(0).yv + 1

'=======[ MAX SPEED ]=======
IF player(0).xv > player(0).xmax THEN player(0).xv = player(0).xmax
IF player(0).yv > player(0).ymax THEN player(0).yv = player(0).ymax
IF player(0).xv < -player(0).xmax THEN player(0).xv = -player(0).xmax
IF player(0).yv < -player(0).ymax THEN player(0).yv = -player(0).ymax

'=======[ MOVE PLAYER ]=======
player(0).x = player(0).x + player(0).xv
player(0).y = player(0).y + player(0).yv

'=======[ FRICTION ]=======
player(0).xv = player(0).xv * friction!
'player(0).yv = player(0).yv * friction!
IF player(0).xv < .2 AND player(0).xv > 0 THEN player(0).xv = 0
IF player(0).xv > -.2 AND player(0).xv < 0 THEN player(0).xv = 0
'IF player(0).yv < .2 AND player(0).yv > 0 THEN player(0).yv = 0
'IF player(0).yv > -.2 AND player(0).yv < 0 THEN player(0).yv = 0

'=======[ ROUND PLAYER LOCATION ]=======
IF player(0).xv = 0 THEN player(0).x = INT(player(0).x)
IF player(0).yv = 0 THEN player(0).y = INT(player(0).y)

'=======[ BOUNDARIES ]=======
IF player(0).x < 0 THEN player(0).x = 0: player(0).xv = 0
IF player(0).y < 0 THEN player(0).y = 0: player(0).yv = 0
IF player(0).x > (mapxsize * ts) - 1 THEN player(0).x = (mapxsize * ts) - 1: player(0).xv = 0
IF player(0).y > (mapysize * ts) - 1 THEN player(0).y = (mapysize * ts) - 1: player(0).yv = 0

'===============================[ CLIPPING ]=================================
' 1--5--2     3--1--4
' |     |     |     |
' 7     8     5     6
' |     |     |     |
' 9     10    7     8
' |     |     |     |
' 3--6--4     9--2-10

UpdateClipPoints
ClipPlayerToMap
UpdateClipPoints
'========================[ CHECK NEW PLAYER STATE ]==========================
CheckOnGround     ' if player not on ground then start falling
CheckJumpHeight   ' has player reached the apogee of a jump?

END SUB

SUB DoPlayerFrame

'===========================[ NEW FRAME SYSTEM ]=============================
SELECT CASE player(0).action
 CASE moving
  MovingFrames
 CASE shooting
  ShootingFrames
 CASE switching
  SwitchingFrames
 CASE dying
  DyingFrames
 CASE teleporting
  TeleportingFrames
 CASE climbing
  ClimbingFrames
END SELECT

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

SUB DyingFrames

player(0).frame = pframe(22)
player(0).txsize = fsize(22).x
player(0).tysize = fsize(22).y

END SUB

FUNCTION HitPoint (p)

'fg=Foreground Tag 1
'bg=Background Tag 1

mx = INT(ClipPoint(p).x / ts) + 1
my = INT(ClipPoint(p).y / ts) + 1
fg = TileType(MapFG&(mx, my))
bg = TileType(Map&(mx, my))
IF fg = 2 THEN HitPoint = 8: EXIT FUNCTION   'slope in foreground
IF fg = 9 THEN HitPoint = fg: EXIT FUNCTION  'wall in foreground
HitPoint = bg

END FUNCTION

SUB HitSlope (x!, y!, l)

x = x!: y = y!
h = SlopeHeight(x, y, l)
IF h > 20 OR h < 0 THEN
  DebugLog "SlopeHeight Error, h:" + STR$(h)
  ErrorHandlerSub 9999
END IF
IF h THEN
  player(0).y = INT(player(0).y) - h
  player(0).yv = 0
  player(0).onground = 1
  player(0).onslope = 1
  UpdateClipPoints
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
  ny! = INT((hy! - (hy! MOD ts)) + ts)
  side = up
 ELSEIF p = 2 THEN
  ny! = INT((hy! - (hy! MOD ts)) - 1)
  side = down
 ELSEIF p = 3 OR p = 5 OR p = 7 OR p = 9 THEN
  nx! = INT((hx! - (hx! MOD ts)) + ts)
  side = right
 ELSEIF p = 4 OR p = 6 OR p = 8 OR p = 10 THEN
  nx! = INT((hx! - (hx! MOD ts)) - 1)
  side = left
END IF

SELECT CASE side
 CASE up
  player(0).yv = 0
  player(0).y = ny! + (player(0).ysize / 2) + 1
 CASE down
  player(0).yv = 0
  player(0).y = ny! - (player(0).ysize / 2)
  player(0).onground = 1
 CASE left
  player(0).xv = 0
  IF p = 4 OR p = 6 OR p = 8 OR p = 10 THEN player(0).x = nx! - (player(0).xsize / 2)
 CASE right
  player(0).xv = 0
  IF p = 3 OR p = 5 OR p = 7 OR p = 9 THEN player(0).x = nx! + (player(0).xsize / 2)
END SELECT
UpdateClipPoints

END SUB

SUB KillPlayer

IF player(0).action <> dying THEN
  player(0).action = dying
  player(0).actiontime = maxfps
  player(0).frozen = 1
  player(0).onground = 0
  player(0).xv = 0
  maxfps = maxfps / 3
END IF

END SUB

SUB MovePlayer (d)

SELECT CASE d
 CASE up
  IF player(0).frozen = 0 THEN
    'IF player(0).action = climbing THEN player(0).action = moving
    IF (player(0).yv < 0) OR (player(0).yv = 0 AND player(0).onground) OR (player(0).action = climbing) THEN
      IF player(0).canjump THEN
        player(0).yv = player(0).yv - 2
        player(0).action = moving     ' stop actions like climbing
      END IF
    END IF
  END IF
 CASE down: player(0).yv = player(0).yv + 2
 CASE left
  IF player(0).action = climbing THEN
    player(0).xdir = left
   ELSE
    IF player(0).frozen = 0 THEN player(0).xv = player(0).xv - 2: player(0).xdir = left
  END IF
 CASE right
  IF player(0).action = climbing THEN
    player(0).xdir = right
   ELSE
    IF player(0).frozen = 0 THEN player(0).xv = player(0).xv + 2: player(0).xdir = right
  END IF
END SELECT

 'CASE lookup: camera(0).y = camera(0).y - 2: player(0).looking = -1
 'CASE lookdown
 ' camera(0).y = camera(0).y + 2
 ' IF player(0).looking <= 0 THEN player(0).looking = 1

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

' if a special action is happening, decrease time remaining
IF player(0).actiontime THEN player(0).actiontime = player(0).actiontime - 1
  
' if player finished dying, quit the game
IF player(0).action = dying AND player(0).actiontime = 0 THEN gameplay = paused: gamemode = inmenu: player(0).actiontime = 1

' if player finished teleporting, move him
IF player(0).action = teleporting AND player(0).actiontime = 0 THEN TeleportPlayer

' resume walking when finished an action
IF player(0).actiontime = 0 AND player(0).action <> climbing THEN player(0).action = moving

' if player is moving, then he's never frozen. unfreeze.
IF player(0).action = moving THEN player(0).frozen = 0

' update the player's frame
DoPlayerFrame

'========[ WEAPONS PLUGIN ]========
' decrease reload wait time
IF player(0).reload THEN player(0).reload = player(0).reload - 1

END SUB

SUB UpdateClipPoints


' 1--5--2     3--1--4
' |     |     |     |
' 7     8     5     6
' |     |     |     |
' 9     10    7     8
' |     |     |     |
' 3--6--4     9--2-10

'ClipPoint(1).x = player(0).x - (player(0).xsize / 2)
'ClipPoint(1).y = player(0).y - (player(0).ysize / 2)
'
'ClipPoint(2).x = player(0).x + (player(0).xsize / 2)
'ClipPoint(2).y = player(0).y - (player(0).ysize / 2)
'
'ClipPoint(3).x = player(0).x - (player(0).xsize / 2)
'ClipPoint(3).y = player(0).y + (player(0).ysize / 2)
'
'ClipPoint(4).x = player(0).x + (player(0).xsize / 2)
'ClipPoint(4).y = player(0).y + (player(0).ysize / 2)
'
'ClipPoint(5).x = player(0).x
'ClipPoint(5).y = player(0).y - (player(0).ysize / 2)
'
'ClipPoint(6).x = player(0).x
'ClipPoint(6).y = player(0).y + (player(0).ysize / 2)
'
'ClipPoint(7).x = player(0).x - (player(0).xsize / 2)
'ClipPoint(7).y = player(0).y - (player(0).ysize / 4)
'
'ClipPoint(8).x = player(0).x + (player(0).xsize / 2)
'ClipPoint(8).y = player(0).y - (player(0).ysize / 4)
'
'ClipPoint(9).x = player(0).x - (player(0).xsize / 2)
'ClipPoint(9).y = player(0).y + (player(0).ysize / 4)
'
'ClipPoint(10).x = player(0).x + (player(0).xsize / 2)
'ClipPoint(10).y = player(0).y + (player(0).ysize / 4)

ClipPoint(3).x = player(0).x - (player(0).xsize / 2)
ClipPoint(3).y = player(0).y - (player(0).ysize / 2)

ClipPoint(4).x = player(0).x + (player(0).xsize / 2)
ClipPoint(4).y = player(0).y - (player(0).ysize / 2)

ClipPoint(9).x = player(0).x - (player(0).xsize / 2)
ClipPoint(9).y = player(0).y + (player(0).ysize / 2)

ClipPoint(10).x = player(0).x + (player(0).xsize / 2)
ClipPoint(10).y = player(0).y + (player(0).ysize / 2)

ClipPoint(1).x = player(0).x
ClipPoint(1).y = player(0).y - (player(0).ysize / 2)

ClipPoint(2).x = player(0).x
ClipPoint(2).y = player(0).y + (player(0).ysize / 2)

ClipPoint(5).x = player(0).x - (player(0).xsize / 2)
ClipPoint(5).y = player(0).y - (player(0).ysize / 4)

ClipPoint(6).x = player(0).x + (player(0).xsize / 2)
ClipPoint(6).y = player(0).y - (player(0).ysize / 4)

ClipPoint(7).x = player(0).x - (player(0).xsize / 2)
ClipPoint(7).y = player(0).y + (player(0).ysize / 4)

ClipPoint(8).x = player(0).x + (player(0).xsize / 2)
ClipPoint(8).y = player(0).y + (player(0).ysize / 4)

END SUB

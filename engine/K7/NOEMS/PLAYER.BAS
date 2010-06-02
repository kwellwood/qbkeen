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

oldonslope = player(0).onslope
oldonground = player(0).onground
mapx = INT(player(0).x / ts) + 1
mapy = INT((player(0).y + (player(0).ysize / 2)) / ts) + 1

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

IF TileType(Map&(mapx, mapy)) = 2 OR TileType(MapFG&(mapx, mapy)) = 2 THEN
  IF TileType(Map&(mapx, mapy)) = 2 THEN l = 0 ELSE l = 1
  x = ClipPoint(2).x: y = ClipPoint(2).y
  h1 = SlopeHeight(x, y, l)
  h2 = SlopeHeight(x, y + 1, l)
  IF h1 = 0 AND h2 < 0 THEN
    player(0).onground = 1: player(0).onslope = 1
   ELSE
    player(0).onground = 0: player(0).onslope = 0
  END IF
END IF

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
  player(0).holdingjump = 0
  player(0).stoppedjump = 0
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
   CASE 10: PlaySound 2: NextLevel
  END SELECT
NEXT cp

END SUB

SUB DoPhysics

IF player(0).action = climbing THEN EXIT SUB

UpdateClipPoints
'=======[ POGO STICK ]=======
IF player(0).action = pogo THEN HandlePogoStick

'=======[ GRAVITY ]=======
IF player(0).onground = 0 THEN player(0).yv = player(0).yv + gravity!

'=======[ MAX SPEED ]=======
IF player(0).xv > player(0).xmax THEN player(0).xv = player(0).xmax
'IF player(0).action = pogo THEN
'  IF player(0).yv > player(0).ymax * 1.5 THEN player(0).yv = player(0).ymax * 1.5
' ELSEIF player(0).yv > player(0).ymax THEN player(0).yv = player(0).ymax
'END IF
IF player(0).yv > player(0).ymax THEN player(0).yv = player(0).ymax
IF player(0).xv < -player(0).xmax THEN player(0).xv = -player(0).xmax
'IF player(0).action = pogo THEN
'  IF player(0).yv < -player(0).ymax * 1.5 THEN player(0).yv = -player(0).ymax * 1.5
' ELSEIF player(0).yv < -player(0).ymax THEN player(0).yv = -player(0).ymax
'END IF
IF player(0).yv < -player(0).ymax THEN player(0).yv = -player(0).ymax
'=======[ MOVE PLAYER ]=======
player(0).x = player(0).x + player(0).xv
player(0).y = player(0).y + player(0).yv

'=======[ FRICTION ]=======
IF player(0).action <> pogo THEN player(0).xv = player(0).xv * friction!
IF player(0).xv < .2 AND player(0).xv > 0 THEN player(0).xv = 0
IF player(0).xv > -.2 AND player(0).xv < 0 THEN player(0).xv = 0

'=======[ ROUND PLAYER LOCATION ]=======
IF player(0).xv = 0 THEN player(0).x = INT(player(0).x)
IF player(0).yv = 0 THEN player(0).y = INT(player(0).y)

'=======[ BOUNDARIES ]=======
UpdateClipPoints
'IF player(0).x < 0 THEN player(0).x = 0: player(0).xv = 0
'IF player(0).y < 0 THEN player(0).y = 0: player(0).yv = 0
'IF player(0).x > (mapxsize * ts) - 1 THEN player(0).x = (mapxsize * ts) - 1: player(0).xv = 0
'IF player(0).y > (mapysize * ts) - 1 THEN player(0).y = (mapysize * ts) - 1: player(0).yv = 0
IF player(0).x - player(0).xsize / 2 < 0 THEN player(0).x = player(0).xsize / 2: player(0).xv = 0
IF player(0).y - player(0).ysize / 2 < 0 THEN player(0).y = player(0).ysize / 2: player(0).yv = 0
IF player(0).x + player(0).xsize / 2 > (mapxsize * ts) - 1 THEN player(0).x = (mapxsize * ts) - 1 - (player(0).xsize / 2)
IF player(0).y + player(0).ysize / 2 > (mapysize * ts) - 1 THEN player(0).y = (mapysize * ts) - 1 - (player(0).ysize / 2)

'===============================[ CLIPPING ]=================================
' 3--1--4
' |     |
' 5     6
' |     |
' 7     8
' |     |
' 9--2-10

UpdateClipPoints
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

SUB DyingFrames

player(0).frame = pframe(22)
player(0).txsize = fsize(22).x
player(0).tysize = fsize(22).y

END SUB

SUB HandlePogoStick

IF player(0).onground THEN
  PlaySound 11
  player(0).yv = player(0).yv - player(0).ymax * 2
  player(0).canjump = ts * player(0).jumpheight * 2
  player(0).holdingjump = 0
  player(0).stoppedjump = 0
END IF

IF player(0).yv > -player(0).ymax AND player(0).holdingjump = 0 THEN player(0).stoppedjump = 1

END SUB

FUNCTION HitPoint (p)

'fg =Foreground Tag 1
'fg2=Foreground Tag 2
'bg =Background Tag 1

mx = INT(ClipPoint(p).x / ts) + 1
my = INT(ClipPoint(p).y / ts) + 1
fg = TileType(MapFG&(mx, my))
fg2 = TileType2(MapFG&(mx, my))
bg = TileType(Map&(mx, my))
IF fg = 2 THEN HitPoint = 8: EXIT FUNCTION    'slope in foreground
IF fg = 9 THEN HitPoint = 1: EXIT FUNCTION    'wall in foreground
IF fg2 = 10 THEN HitPoint = 10: EXIT FUNCTION 'exit level tile
HitPoint = bg

END FUNCTION

SUB HitSlope (x!, y!, l)

x = INT(x!): y = INT(y!)
h = SlopeHeight(x, y, l)

IF h > ts THEN h = ts
IF h < -ts THEN h = -ts

IF h THEN
  player(0).y = INT(player(0).y) + h
  player(0).yv = 0
  player(0).onground = 1
  player(0).onslope = 1
  player(0).holdingjump = 0
  player(0).stoppedjump = 0
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

END SUB

SUB KillPlayer

IF player(0).action <> dying THEN
  player(0).action = dying
  player(0).actiontime = maxfps
  player(0).frozen = 1
  player(0).onground = 0
  player(0).xv = 0
  player(0).yv = -20
  'maxfps = maxfps / 3
  PlaySound 3
END IF

END SUB

SUB MovePlayer (d)

SELECT CASE d
 CASE up
  IF player(0).frozen = 0 THEN
    'IF player(0).action = climbing THEN player(0).action = moving
    IF (player(0).yv < 0) OR (player(0).yv = 0 AND player(0).onground) OR (player(0).action = climbing) THEN
      IF player(0).canjump AND player(0).stoppedjump = 0 THEN 'AND player(0).changeaction = 0 THEN
        IF player(0).holdingjump = 0 THEN PlaySound 9
        player(0).holdingjump = 1
        player(0).yv = -player(0).ymax   'player(0).yv - 2
        IF player(0).action = climbing THEN
          player(0).changeaction = maxfps / 3
          player(0).yv = player(0).yv / 4  ' 1/4 jump power from a pole
        END IF
        IF player(0).action <> pogo THEN player(0).action = moving
      END IF
    END IF
  END IF
 CASE down: player(0).yv = player(0).yv + 2
 CASE left
  IF player(0).action = climbing THEN
    player(0).xdir = left
   ELSE
    IF player(0).frozen = 0 THEN
      player(0).xdir = left
      'player(0).xv = player(0).xv - 2
      IF player(0).onground THEN
        player(0).xv = player(0).xv - 2
       ELSEIF player(0).action = pogo THEN
        player(0).xv = player(0).xv - .3
       ELSE
        player(0).xv = player(0).xv - 1'.5
      END IF
    END IF
  END IF
 CASE right
  IF player(0).action = climbing THEN
    player(0).xdir = right
   ELSE
    IF player(0).frozen = 0 THEN
      player(0).xdir = right
      'player(0).xv = player(0).xv + 2
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
IF player(0).actiontime < 0 THEN player(0).actiontime = 0

' if player has changed actions recently, decrease time left to change again
IF player(0).changeaction THEN player(0).changeaction = player(0).changeaction - 1
IF player(0).changeaction < 0 THEN player(0).changeaction = 0

' if player is shooting decrease time for frame shown
IF player(0).shooting THEN player(0).shooting = player(0).shooting - 1

' if player finished dying, quit the game
IF player(0).action = dying AND player(0).actiontime = 0 THEN
  IF player(0).lives > 0 THEN
    SLEEP 1
    player(0).lives = player(0).lives - 1
    LoadLevel
   ELSE
    gameplay = paused: gamemode = inmenu: player(0).actiontime = 1
  END IF
END IF

' if player finished teleporting, move him
IF player(0).action = teleporting AND player(0).actiontime = 0 THEN TeleportPlayer

' resume walking when finished an action
IF player(0).actiontime = 0 THEN
  IF player(0).action <> climbing AND player(0).action <> pogo THEN player(0).action = moving
END IF

' if player is moving, then he's never frozen. unfreeze.
IF player(0).action = moving AND player(0).shooting = 0 THEN player(0).frozen = 0

' if player is on a pole then kill the stoppedjump flag
IF player(0).action = climbing THEN
  player(0).holdingjump = 0
  player(0).stoppedjump = 0
END IF

' only let the player face the direction he's actually going
IF player(0).action = moving OR player(0).action = pogo THEN
  IF player(0).xv < 0 THEN player(0).xdir = left
  IF player(0).xv > 0 THEN player(0).xdir = right
END IF

' update the player's frame
DoPlayerFrame

'========[ WEAPONS PLUGIN ]========
' decrease reload wait time
IF player(0).reload THEN player(0).reload = player(0).reload - 1

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

IF player(0).changeaction > 0 THEN EXIT SUB
IF player(0).frozen THEN EXIT SUB

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


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
  IF INT((player(0).y + (player(0).ysize / 2)) MOD ts) >= ts - 2 THEN
    mapx = INT(player(0).x / ts) + 1: mapy = INT((player(0).y + (player(0).ysize / 2)) / ts) + 2
    IF TileType(Map&(mapx, mapy)) = 1 THEN
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

END SUB

SUB DoPhysics

UpdateClipPoints

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
player(0).yv = player(0).yv * friction!
IF player(0).xv < .2 AND player(0).xv > 0 THEN player(0).xv = 0
IF player(0).xv > -.2 AND player(0).xv < 0 THEN player(0).xv = 0
IF player(0).yv < .2 AND player(0).yv > 0 THEN player(0).yv = 0
IF player(0).yv > -.2 AND player(0).yv < 0 THEN player(0).yv = 0

'=======[ ROUND PLAYER LOCATION ]=======
IF player(0).xv = 0 THEN player(0).x = INT(player(0).x)
IF player(0).yv = 0 THEN player(0).y = INT(player(0).y)

'=======[ BOUNDARIES ]=======
IF player(0).x < 0 THEN player(0).x = 0: player(0).xv = 0
IF player(0).y < 0 THEN player(0).y = 0: player(0).yv = 0
IF player(0).x > (mapxsize * ts) - 1 THEN player(0).x = (mapxsize * ts) - 1: player(0).xv = 0
IF player(0).y > (mapysize * ts) - 1 THEN player(0).y = (mapysize * ts) - 1: player(0).yv = 0

'===============================[ CLIPPING ]=================================
UpdateClipPoints

' 1--5--2
' |     |
' 7     8
' |     |
' 9     10
' |     |
' 3--6--4

IF HitPoint(5) THEN HitWall 5, ClipPoint(5).x, ClipPoint(5).y
IF HitPoint(6) THEN HitWall 6, ClipPoint(6).x, ClipPoint(6).y

IF HitPoint(1) THEN HitWall 1, ClipPoint(1).x, ClipPoint(1).y
IF HitPoint(2) THEN HitWall 2, ClipPoint(2).x, ClipPoint(2).y

IF HitPoint(7) THEN HitWall 7, ClipPoint(7).x, ClipPoint(7).y
IF HitPoint(8) THEN HitWall 8, ClipPoint(8).x, ClipPoint(8).y

IF HitPoint(9) THEN HitWall 9, ClipPoint(9).x, ClipPoint(9).y
IF HitPoint(10) THEN HitWall 10, ClipPoint(10).x, ClipPoint(10).y

IF HitPoint(3) THEN HitWall 3, ClipPoint(3).x, ClipPoint(3).y
IF HitPoint(4) THEN HitWall 4, ClipPoint(4).x, ClipPoint(4).y

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
END SELECT

'===========================[ NEW FRAME SYSTEM ]=============================
'IF player(0).shooting THEN
'  SELECT CASE player(0).shootingframe
'   CASE groundleft: framedataslot = 14
'   CASE groundright: framedataslot = 15
'   CASE groundup: framedataslot = 16
'   CASE airleft: framedataslot = 17
'   CASE airright: framedataslot = 18
'   CASE airup: framedataslot = 19
'   CASE airdown: framedataslot = 20
'  END SELECT
'
'  player(0).frame = pframe(framedataslot)
'  player(0).txsize = fsize(framedataslot).x
'  player(0).tysize = fsize(framedataslot).y
' ELSE
'
'SELECT CASE player(0).xdir
' CASE left
'    IF player(0).yv = 0 AND player(0).onground THEN
'      IF player(0).xv < 0 THEN       ' walk left
'        player(0).frame = pframe(1) + (INT(anmcounter / player(0).adelay) MOD pframe(2))
'        player(0).txsize = fsize(1).x
'        player(0).tysize = fsize(1).y
'       ELSE
'        player(0).frame = pframe(0)  ' stand left
'        player(0).txsize = fsize(0).x
'        player(0).tysize = fsize(0).y
'      END IF
'     ELSE
'      IF player(0).yv < -(player(0).ymax / 4) THEN
'        player(0).frame = pframe(6)  ' fast jump left
'        player(0).txsize = fsize(6).x
'        player(0).tysize = fsize(6).y
'       ELSEIF player(0).yv > (player(0).ymax / 4) THEN
'        player(0).frame = pframe(8)  ' fast fall left
'        player(0).txsize = fsize(8).x
'        player(0).tysize = fsize(8).y
'       ELSEIF player(0).yv >= -(player(0).ymax / 4) AND player(0).yv <= (player(0).ymax / 4) THEN
'        player(0).frame = pframe(7)  ' slow jump/fall left
'        player(0).txsize = fsize(7).x
'        player(0).tysize = fsize(7).y
'      END IF
'    END IF
'
' CASE right
'    IF player(0).yv = 0 AND player(0).onground THEN
'      IF player(0).xv > 0 THEN       ' walk right
'        player(0).frame = pframe(4) + (INT(anmcounter / player(0).adelay) MOD pframe(5))
'        player(0).txsize = fsize(4).x
'        player(0).tysize = fsize(4).y
'       ELSE
'        player(0).frame = pframe(3)  ' stand left
'        player(0).txsize = fsize(3).x
'        player(0).tysize = fsize(3).y
'      END IF
'     ELSE
'      IF player(0).yv < -(player(0).ymax / 4) THEN
'        player(0).frame = pframe(9)   ' fast jump left
'        player(0).txsize = fsize(9).x
'        player(0).tysize = fsize(9).y
'       ELSEIF player(0).yv > (player(0).ymax / 4) THEN
'        player(0).frame = pframe(11)  ' fast fall left
'        player(0).txsize = fsize(11).x
'        player(0).tysize = fsize(11).y
'       ELSEIF player(0).yv >= -(player(0).ymax / 4) AND player(0).yv <= (player(0).ymax / 4) THEN
'        player(0).frame = pframe(10)  ' slow jump/fall left
'        player(0).txsize = fsize(10).x
'        player(0).tysize = fsize(10).y
'      END IF
'    END IF
'
'END SELECT
'END IF

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

FUNCTION HitPoint (p)

mx = INT(ClipPoint(p).x / ts) + 1
my = INT(ClipPoint(p).y / ts) + 1
IF TileType(Map&(mx, my)) = 1 THEN HitPoint = 1 ELSE HitPoint = 0

END FUNCTION

SUB HitWall (p, hx!, hy!)
            
side = -1

IF p = 5 THEN
  ny! = INT((hy! - (hy! MOD ts)) + ts)
  side = up
 ELSEIF p = 6 THEN
  ny! = INT((hy! - (hy! MOD ts)) - 1)
  side = down
 ELSEIF p = 1 OR p = 7 OR p = 3 THEN
  nx! = INT((hx! - (hx! MOD ts)) + ts)
  side = right
 ELSEIF p = 2 OR p = 8 OR p = 4 THEN
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
  IF p = 2 OR p = 8 OR p = 4 THEN player(0).x = nx! - (player(0).xsize / 2)
 CASE right
  player(0).xv = 0
  IF p = 1 OR p = 7 OR p = 3 THEN player(0).x = nx! + (player(0).xsize / 2)
END SELECT
UpdateClipPoints

END SUB

SUB MovePlayer (D)

SELECT CASE D
 CASE up
  IF (player(0).yv < 0) OR (player(0).yv = 0 AND player(0).onground) THEN
    IF player(0).canjump THEN player(0).yv = player(0).yv - 2
  END IF
 CASE down: player(0).yv = player(0).yv + 2
 'CASE left: IF player(0).shooting = 0 OR player(0).shootingframe <> groundup THEN player(0).xv = player(0).xv - 2: player(0).xdir = left
 CASE left: IF player(0).frozen = 0 THEN player(0).xv = player(0).xv - 2: player(0).xdir = left
 'CASE right: IF player(0).shooting = 0 OR player(0).shootingframe <> groundup THEN player(0).xv = player(0).xv + 2: player(0).xdir = right
 CASE right: IF player(0).frozen = 0 THEN player(0).xv = player(0).xv + 2: player(0).xdir = right
 'CASE lookup: camera(0).y = camera(0).y - 2: player(0).looking = -1
 'CASE lookdown
 ' camera(0).y = camera(0).y + 2
 ' IF player(0).looking <= 0 THEN player(0).looking = 1
END SELECT

END SUB

SUB MovingFrames

IF player(0).onground THEN         ' player is standing
  IF player(0).xdir = left THEN
    IF player(0).xv < 0 THEN       ' walk left
      framedataslot = 1
      anmframe = INT(anmcounter / player(0).adelay) MOD pframe(2)
      'player(0).frame = pframe(1) + (INT(anmcounter / player(0).adelay) MOD pframe(2))
      'player(0).txsize = fsize(1).x
      'player(0).tysize = fsize(1).y
     ELSE
      framedataslot = 0: anmframe = 0
      'player(0).frame = pframe(0)  ' stand left
      'player(0).txsize = fsize(0).x
      'player(0).tysize = fsize(0).y
    END IF
   ELSEIF player(0).xdir = right THEN
    IF player(0).xv > 0 THEN       ' walk right
      framedataslot = 4
      anmframe = INT(anmcounter / player(0).adelay) MOD pframe(5)
      'player(0).frame = pframe(4) + (INT(anmcounter / player(0).adelay) MOD pframe(5))
      'player(0).txsize = fsize(4).x
      'player(0).tysize = fsize(4).y
     ELSE
      framedataslot = 3: anmframe = 0
      'player(0).frame = pframe(3)  ' stand right
      'player(0).txsize = fsize(3).x
      'player(0).tysize = fsize(3).y
    END IF
  END IF
 ELSE                             ' player is jumping/falling
  IF player(0).xdir = left THEN
    IF player(0).yv < -(player(0).ymax / 4) THEN
      framedataslot = 6: anmframe = 0
      'player(0).frame = pframe(6)  ' fast jump left
      'player(0).txsize = fsize(6).x
      'player(0).tysize = fsize(6).y
     ELSEIF player(0).yv > (player(0).ymax / 4) THEN
      framedataslot = 8: anmframe = 0
      'player(0).frame = pframe(8)  ' fast fall left
      'player(0).txsize = fsize(8).x
      'player(0).tysize = fsize(8).y
     ELSEIF player(0).yv >= -(player(0).ymax / 4) AND player(0).yv <= (player(0).ymax / 4) THEN
      framedataslot = 7: anmframe = 0
      'player(0).frame = pframe(7)  ' slow jump/fall left (apogee of jump)
      'player(0).txsize = fsize(7).x
      'player(0).tysize = fsize(7).y
    END IF
   ELSEIF player(0).xdir = right THEN
    IF player(0).yv < -(player(0).ymax / 4) THEN
      framedataslot = 9: anmframe = 0
      'player(0).frame = pframe(9)   ' fast jump right
      'player(0).txsize = fsize(9).x
      'player(0).tysize = fsize(9).y
     ELSEIF player(0).yv > (player(0).ymax / 4) THEN
      framedataslot = 11: anmframe = 0
      'player(0).frame = pframe(11)  ' fast fall right
      'player(0).txsize = fsize(11).x
      'player(0).tysize = fsize(11).y
     ELSEIF player(0).yv >= -(player(0).ymax / 4) AND player(0).yv <= (player(0).ymax / 4) THEN
      framedataslot = 10: anmframe = 0
      'player(0).frame = pframe(10)  ' slow jump/fall right (apogee of jump)
      'player(0).txsize = fsize(10).x
      'player(0).tysize = fsize(10).y
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
IF player(0).actiontime THEN
  player(0).actiontime = player(0).actiontime - 1
  IF player(0).actiontime = 0 THEN player(0).action = moving
END IF

' if player is moving, then he's never frozen. unfreeze.
IF player(0).action = moving THEN player(0).frozen = 0

' update the player's frame
DoPlayerFrame

'========[ WEAPONS PLUGIN ]========
IF player(0).reload THEN player(0).reload = player(0).reload - 1

END SUB

SUB UpdateClipPoints

ClipPoint(1).x = player(0).x - (player(0).xsize / 2)
ClipPoint(1).y = player(0).y - (player(0).ysize / 2)

ClipPoint(2).x = player(0).x + (player(0).xsize / 2)
ClipPoint(2).y = player(0).y - (player(0).ysize / 2)

ClipPoint(3).x = player(0).x - (player(0).xsize / 2)
ClipPoint(3).y = player(0).y + (player(0).ysize / 2)

ClipPoint(4).x = player(0).x + (player(0).xsize / 2)
ClipPoint(4).y = player(0).y + (player(0).ysize / 2)

ClipPoint(5).x = player(0).x
ClipPoint(5).y = player(0).y - (player(0).ysize / 2)

ClipPoint(6).x = player(0).x
ClipPoint(6).y = player(0).y + (player(0).ysize / 2)

ClipPoint(7).x = player(0).x - (player(0).xsize / 2)
ClipPoint(7).y = player(0).y - (player(0).ysize / 4)

ClipPoint(8).x = player(0).x + (player(0).xsize / 2)
ClipPoint(8).y = player(0).y - (player(0).ysize / 4)

ClipPoint(9).x = player(0).x - (player(0).xsize / 2)
ClipPoint(9).y = player(0).y + (player(0).ysize / 4)

ClipPoint(10).x = player(0).x + (player(0).xsize / 2)
ClipPoint(10).y = player(0).y + (player(0).ysize / 4)

END SUB


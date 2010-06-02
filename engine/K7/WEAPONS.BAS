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
SUB DoShots

FOR s = 1 TO 5
  IF shot(s).active THEN
    '--- move shot ---
    shot(s).x = shot(s).x + shot(s).xv
    shot(s).y = shot(s).y + shot(s).yv
   
    '--- map boundaries ---
    IF shot(s).x < 0 OR shot(s).x > mapxsize * ts THEN shot(s).active = 0
    IF shot(s).y < 0 OR shot(s).y > mapysize * ts THEN shot(s).active = 0

    '--- hit a wall ---
    IF ShotCollide(s) THEN KillShot s
 
    '--- hit an enemy ---
    e = ShotEnemy(s)
    IF e THEN
      KillEnemy e
      KillShot s
    END IF
 
    '--- in range of player ---
    IF ShotInRange(s, 400) = 0 THEN shot(s).active = 0
 END IF
NEXT s

END SUB

SUB DrawShots

FOR s = 1 TO 5
  IF shot(s).active THEN
    frame& = shot(s).sframe + (INT(anmcounter / shot(s).delay) MOD (shot(s).eframe - shot(s).frame))
    PutSprite frame&, shot(s).x - camera(0).vx1 - (shotxsize / 2), shot(s).y - camera(0).vy1 - (shotysize / 2), drawpage
  END IF
NEXT s

END SUB

SUB InitWeapons

'OPEN "weapons.dat" FOR INPUT AS 1
OPEN "engine.dat" FOR INPUT AS 1
  DO: INPUT #1, text$
  LOOP UNTIL UCASE$(text$) = "[WEAPONS.DAT]"
  INPUT #1, shotvelocity
  INPUT #1, shotsframe&
  INPUT #1, shoteframe&
  INPUT #1, shotframedelay
  INPUT #1, shotxsize
  INPUT #1, shotysize
  INPUT #1, shotexpsframe&
  INPUT #1, shotexpeframe&
  INPUT #1, shotexpframedelay
  INPUT #1, shotexpxsize
  INPUT #1, shotexpysize
CLOSE 1

END SUB

SUB KillShot (s)

'--- shot slot no longer active ---
shot(s).active = 0

'--- add explosion to sprite stack ---
x = shot(s).x: y = shot(s).y
AddSprite x, y, shotexpsframe&, shotexpeframe&, shotexpframedelay, shotexpxsize, shotexpysize, 0, 0

'--- play sound if in hearing range ---
IF ShotInRange(s, 240) THEN PlaySound 6

END SUB

SUB SetShootingFrame

'======[ SET ANIMATION FRAME TO USE ]======
'the shooting direction is set in shootingframe. if the engine
'detects that player is shooting (shooting>0) then it uses the direction
'found in shootingframe to select the tile to display.

IF player(0).action = climbing THEN
  SELECT CASE player(0).aim
   CASE -1
    IF player(0).xdir = left THEN player(0).shootingframe = poleleft
    IF player(0).xdir = right THEN player(0).shootingframe = poleright
   CASE up
    IF player(0).xdir = left THEN player(0).shootingframe = poleleftup
    IF player(0).xdir = right THEN player(0).shootingframe = polerightup
   CASE down
    IF player(0).xdir = left THEN player(0).shootingframe = poleleftdown
    IF player(0).xdir = right THEN player(0).shootingframe = polerightdown
  END SELECT
  EXIT SUB
END IF

IF player(0).onground THEN
  IF player(0).aim = -1 THEN    ' player not aiming up or down; on ground
    IF player(0).xdir = left THEN player(0).shootingframe = groundleft: player(0).xv = 0
    IF player(0).xdir = right THEN player(0).shootingframe = groundright: player(0).xv = 0
   ELSE
    player(0).shootingframe = groundup: player(0).xv = 0: player(0).frozen = 1 'stop walking
  END IF
 ELSE
  IF player(0).aim = -1 THEN    ' player not aiming up or down; in air
    IF player(0).xdir = left THEN player(0).shootingframe = airleft
    IF player(0).xdir = right THEN player(0).shootingframe = airright
   ELSEIF player(0).aim = up THEN player(0).shootingframe = airup
   ELSEIF player(0).aim = down THEN player(0).shootingframe = airdown
  END IF
END IF

END SUB

SUB ShootingFrames

SELECT CASE player(0).shootingframe
 CASE groundleft: framedataslot = 14
 CASE groundright: framedataslot = 15
 CASE groundup: framedataslot = 16
 CASE airleft: framedataslot = 17
 CASE airright: framedataslot = 18
 CASE airup: framedataslot = 19
 CASE airdown: framedataslot = 20
 CASE poleleft: framedataslot = 31
 CASE poleleftup: framedataslot = 32
 CASE poleleftdown: framedataslot = 33
 CASE poleright: framedataslot = 34
 CASE polerightup: framedataslot = 35
 CASE polerightdown: framedataslot = 36
END SELECT

player(0).frame = pframe(framedataslot)
player(0).txsize = fsize(framedataslot).x
player(0).tysize = fsize(framedataslot).y

END SUB

FUNCTION ShotCollide (s)

sx = INT(shot(s).x / ts) + 1
sy = INT(shot(s).y / ts) + 1
sx2 = shot(s).x
sy2 = shot(s).y

'hit a wall
'hit a wall in the foreground (not over a pole)
'check for slope hit
'check for slope hit in foreground

IF TileType(Map&(sx, sy)) = 1 THEN ShotCollide = 1: EXIT FUNCTION
IF TileType(MapFG&(sx, sy)) = 9 AND TileType(Map&(sx, sy)) <> 5 THEN ShotCollide = 1: EXIT FUNCTION
IF TileType(Map&(sx, sy)) = 2 THEN ShotCollide = SlopeHeight(sx2, sy2, 0): EXIT FUNCTION
IF TileType(MapFG&(sx, sy)) = 2 THEN ShotCollide = SlopeHeight(sx2, sy2, 1): EXIT FUNCTION

END FUNCTION

FUNCTION ShotEnemy (s)

FOR k = 1 TO LEN(activefoestack(0))
  IF k > LEN(activefoestack(0)) THEN EXIT FOR
  e = ASC(MID$(activefoestack(0), k, 1))
  IF enemy(e).status <> dead THEN
    sx1 = shot(s).x - (shotxsize / 2): sy1 = shot(s).y - (shotysize / 2)
    sx2 = shot(s).x + (shotxsize / 2): sy2 = shot(s).y + (shotysize / 2)
    ex1 = enemy(e).x - (enemy(e).txsize / 2): ey1 = enemy(e).y - (enemy(e).tysize / 2)
    ex2 = enemy(e).x + (enemy(e).txsize / 2): ey2 = enemy(e).y + (enemy(e).tysize / 2)
   
    '--- is shot touching this enemy ---
    IF sx1 >= ex1 AND sx1 <= ex2 AND sy1 >= ey1 AND sy1 <= ey2 THEN touchenemy = 1
    IF sx2 >= ex1 AND sx2 <= ex2 AND sy1 >= ey1 AND sy1 <= ey2 THEN touchenemy = 1
    IF sx1 >= ex1 AND sx1 <= ex2 AND sy2 >= ey1 AND sy2 <= ey2 THEN touchenemy = 1
    IF sx2 >= ex1 AND sx2 <= ex2 AND sy2 >= ey1 AND sy2 <= ey2 THEN touchenemy = 1

    IF touchenemy THEN ShotEnemy = e: EXIT FOR
  END IF
NEXT k

END FUNCTION

FUNCTION ShotInRange (s, range)

IF ABS(player(0).x - shot(s).x) <= range AND ABS(player(0).y - shot(s).y) <= range THEN ShotInRange = 1

END FUNCTION

SUB SpawnPlayerShot

player(0).idletime = 0                 'player pressed shoot key
IF player(0).frozen THEN EXIT SUB      'player not allowed to shoot
IF player(0).reload <> 0 THEN EXIT SUB 'if already shot recently (wait reload)

FOR s = 1 TO 5
  IF shot(s).active = 0 THEN
    IF player(0).aim = -1 THEN
      IF player(0).xdir = left THEN shot(s).x = player(0).x - (player(0).txsize / 2): shot(s).xv = -shotvelocity
      IF player(0).xdir = right THEN shot(s).x = player(0).x + (player(0).txsize / 2): shot(s).xv = shotvelocity
      shot(s).y = player(0).y: shot(s).yv = 0
     ELSE
      IF player(0).aim = up THEN shot(s).y = player(0).y - (player(0).tysize / 2): shot(s).yv = -shotvelocity
      IF player(0).aim = down THEN shot(s).y = player(0).y + (player(0).tysize / 2): shot(s).yv = shotvelocity
      shot(s).x = player(0).x: shot(s).xv = 0
    END IF

    IF player(0).ammo THEN
      PlaySound 4
      shot(s).sframe = shotsframe&
      shot(s).eframe = shoteframe&
      shot(s).delay = shotframedelay
      shot(s).frame = shot(s).sframe
      shot(s).active = 1
     ELSE PlaySound 5
    END IF
   
    SetShootingFrame  ' player(0).shootingframe=??
    IF player(0).ammo THEN player(0).ammo = player(0).ammo - 1
    player(0).reload = maxfps / 4
    player(0).shooting = maxfps / 5
    IF player(0).action = pogo THEN player(0).action = moving
    IF player(0).onground AND player(0).action <> climbing THEN player(0).frozen = 1
    EXIT FOR
  END IF
NEXT s

END SUB


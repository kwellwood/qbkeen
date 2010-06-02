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

OPEN "weapons.dat" FOR INPUT AS 1
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

shot(s).active = 0

'--- add explosion to sprite stack ---
IF LEN(unusedspritestack(0)) THEN
  sp = ASC(LEFT$(unusedspritestack(0), 1))
  unusedspritestack(0) = RIGHT$(unusedspritestack(0), LEN(unusedspritestack(0)) - 1)
  activespritestack(0) = activespritestack(0) + CHR$(sp)
  sprite(sp).x = shot(s).x: sprite(sp).y = shot(s).y
  sprite(sp).frame = shotexpsframe&
  sprite(sp).eframe = shotexpeframe&
  sprite(sp).delay = shotexpframedelay
  sprite(sp).ticks = sprite(sp).delay    ' count down to zero at rate of
  sprite(sp).xsize = shotexpxsize        '  'delay' for next frame
  sprite(sp).ysize = shotexpysize
END IF

END SUB

SUB SetShootingFrame

'======[ SET ANIMATION FRAME TO USE ]======
'the shooting direction is set in shootingframe. if the engine
'detects that player is shooting (shooting>0) then it uses the direction
'found in shootingframe to select the tile to display.

IF player(0).onground THEN
  IF player(0).aim = -1 THEN    ' player not aiming up or down; on ground
    IF player(0).xdir = left THEN player(0).shootingframe = groundleft: player(0).xv = 0
    IF player(0).xdir = right THEN player(0).shootingframe = groundright: player(0).xv = 0
   ELSE player(0).shootingframe = groundup: player(0).xv = 0: player(0).frozen = 1 'stop walking
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
END SELECT

player(0).frame = pframe(framedataslot)
player(0).txsize = fsize(framedataslot).x
player(0).tysize = fsize(framedataslot).y

END SUB

FUNCTION ShotCollide (s)

sx = INT(shot(s).x / ts) + 1
sy = INT(shot(s).y / ts) + 1
IF TileType(Map&(sx, sy)) = 1 THEN ShotCollide = 1

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
    IF ex1 >= sx1 AND ex1 <= sx2 AND ey1 >= sy1 AND ey1 <= sy2 THEN touchenemy = 1
    IF ex2 >= sx1 AND ex2 <= sx2 AND ey1 >= sy1 AND ey1 <= sy2 THEN touchenemy = 1
    IF ex1 >= sx1 AND ex1 <= sx2 AND ey2 >= sy1 AND ey2 <= sy2 THEN touchenemy = 1
    IF ex2 >= sx1 AND ex2 <= sx2 AND ey2 >= sy1 AND ey2 <= sy2 THEN touchenemy = 1
    IF touchenemy THEN ShotEnemy = e: EXIT FOR
  END IF
NEXT k

END FUNCTION

SUB SpawnPlayerShot

IF player(0).frozen THEN EXIT SUB      'player not allowed to move
IF player(0).reload <> 0 THEN EXIT SUB 'if already shot recently (wait reload)
IF player(0).ammo = 0 THEN EXIT SUB       'no ammo?!

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

    SetShootingFrame  ' player(0).shootingframe=??
    shot(s).sframe = shotsframe&
    shot(s).eframe = shoteframe&
    shot(s).delay = shotframedelay
    shot(s).frame = shot(s).sframe
    shot(s).active = 1
    player(0).ammo = player(0).ammo - 1
    player(0).reload = maxfps / 4
    player(0).action = shooting
    player(0).actiontime = maxfps / 5
    EXIT FOR
  END IF
NEXT s

END SUB


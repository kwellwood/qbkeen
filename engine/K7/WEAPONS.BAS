DEFINT A-Z
'$INCLUDE: 'engine.bi'
'$INCLUDE: 'tiles.bi'
'$INCLUDE: 'map.bi'
'$INCLUDE: 'items.bi'
'$INCLUDE: 'render.bi'
'$INCLUDE: 'player.bi'
'$INCLUDE: 'enemies.bi'
'$INCLUDE: 'sound.bi'
'$INCLUDE: 'weapons.bi'
'$STATIC

DECLARE SUB KillShot (s)
DECLARE FUNCTION ShotCollide (s)
DECLARE FUNCTION ShotInRange (s, range)

TYPE shotobject
 x AS SINGLE
 y AS SINGLE
 xv AS SINGLE
 yv AS SINGLE
 frame AS LONG
 sframe AS LONG
 eframe AS LONG
 delay AS INTEGER
 active AS INTEGER
 id AS INTEGER         ' type of shot
END TYPE

TYPE shottypeobject
  velocity AS SINGLE
  sframe AS LONG
  eframe AS LONG
  framedelay AS INTEGER
  xsize AS INTEGER
  ysize AS INTEGER
  expsframe AS LONG
  expeframe AS LONG
  expframedelay AS INTEGER
  expxsize AS INTEGER
  expysize AS INTEGER
END TYPE

CONST shottypes = 5
CONST keenshot = 1, arrowup = 2, arrowdown = 3, arrowleft = 4, arrowright = 5

ON ERROR GOTO ErrorHandler

DIM SHARED shotsframe&, shoteframe&, shotframedelay, shotxsize, shotysize
DIM SHARED shotexpsframe&, shotexpeframe&, shotexpframedelay, shotexpxsize
DIM SHARED shotexpysize, shotvelocity
DIM SHARED shot(1 TO 32) AS shotobject, shottype(shottypes) AS shottypeobject
'============================================================================
ErrorHandler:
e = ERR
ErrorHandlerSub e
RESUME NEXT

FUNCTION ActiveShots

FOR s = 1 TO 32: totalshots = totalshots + shot(s).active: NEXT s
ActiveShots = totalshots

END FUNCTION

SUB ClearShots

FOR s = 1 TO 32: shot(s).active = 0: NEXT s

END SUB

SUB DoShots

FOR s = 1 TO 32
  IF shot(s).active THEN
    '--- move shot ---
    shot(s).x = shot(s).x + shot(s).xv
    shot(s).y = shot(s).y + shot(s).yv
   
    '--- map boundaries ---
    IF shot(s).x < 0 OR shot(s).x > MapWidth * ts THEN shot(s).active = 0
    IF shot(s).y < 0 OR shot(s).y > MapHeight * ts THEN shot(s).active = 0

    '--- hit a wall ---
    IF ShotCollide(s) THEN KillShot s
 
    '--- hit an enemy or keen ---
    sx1 = shot(s).x - (shotxsize / 2): sy1 = shot(s).y - (shotysize / 2)
    sx2 = shot(s).x + (shotxsize / 2): sy2 = shot(s).y + (shotysize / 2)
    IF shot(s).id = keenshot THEN
      '- hit an enemy -
      e = ShotEnemy(sx1, sy1, sx2, sy2)
      IF e THEN
        KillEnemy e
        KillShot s
      END IF
     ELSE
      '- hit keen -
      IF ShotPlayer(sx1, sy1, sx2, sy2) THEN
        KillPlayer
        KillShot s
      END IF
    END IF

    '--- in range of player ---
    IF ShotInRange(s, 400) = 0 THEN shot(s).active = 0
 END IF
NEXT s

END SUB

SUB DrawShots

FOR s = 1 TO 32
  IF shot(s).active THEN
   
    x1 = shot(s).x - (shotxsize / 2)
    x2 = shot(s).x + (shotxsize / 2)
    y1 = shot(s).y - (shotysize / 2)
    y2 = shot(s).y + (shotysize / 2)
    IF OnCamera(x1, y1, x2, y2) THEN
     
      frame& = shot(s).sframe + (INT(anmcounter / shot(s).delay) MOD (shot(s).eframe - shot(s).frame))
      PutSprite frame&, shot(s).x - CameraOrigX - (shottype(shot(s).id).xsize / 2), shot(s).y - CameraOrigY - (shottype(shot(s).id).ysize / 2), drawpage
    END IF
  END IF
NEXT s

END SUB

SUB InitWeapons

OPEN "engine.dat" FOR INPUT AS 1
  DO: INPUT #1, Text$
  LOOP UNTIL UCASE$(Text$) = "[WEAPONS.DAT]"
  FOR t = 1 TO shottypes
    INPUT #1, shottype(t).velocity
    INPUT #1, shottype(t).sframe
    INPUT #1, shottype(t).eframe
    INPUT #1, shottype(t).framedelay
    INPUT #1, shottype(t).xsize
    INPUT #1, shottype(t).ysize
    INPUT #1, shottype(t).expsframe
    INPUT #1, shottype(t).expeframe
    INPUT #1, shottype(t).expframedelay
    INPUT #1, shottype(t).expxsize
    INPUT #1, shottype(t).expysize
  NEXT t
CLOSE 1

END SUB

SUB KillShot (s)

'--- shot slot no longer active ---
shot(s).active = 0

IF shot(s).id = keenshot THEN
  '--- add explosion to sprite stack ---
  x = shot(s).x: y = shot(s).y
  a = AddSprite(x, y, shottype(keenshot).expsframe, shottype(keenshot).expeframe, shottype(keenshot).expframedelay, shottype(keenshot).expxsize, shottype(keenshot).expysize, 0, 0)

  '--- play sound if in hearing range ---
  IF ShotInRange(s, 240) THEN PlaySound 6
END IF

END SUB

SUB LoadShotsFromFile (f)

ClearShots
GET #f, , numshots
FOR s = 1 TO numshots
  GET #f, , shot(s)
NEXT s

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
    IF player(0).xdir = left THEN player(0).shootingframe = groundleft
    IF player(0).xdir = right THEN player(0).shootingframe = groundright
     player(0).xv = 0: player(0).frozen = 1
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

player(0).frame = PlayerFrame&(framedataslot)
player(0).txsize = PFrameSizeX(framedataslot)
player(0).tysize = PFrameSizeY(framedataslot)

END SUB

FUNCTION ShotActive (s)

ShotActive = shot(s).active

END FUNCTION

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
IF (TileType(Map&(sx, sy)) = 6 OR TileType(MapFG&(sx, sy)) = 6) AND TileType(Map&(sx, sy)) <> 5 THEN ShotCollide = 1: EXIT FUNCTION
IF TileType(Map&(sx, sy)) = 2 THEN ShotCollide = SlopeHeight(sx2, sy2, 0): EXIT FUNCTION
IF TileType(MapFG&(sx, sy)) = 2 THEN ShotCollide = SlopeHeight(sx2, sy2, 1): EXIT FUNCTION

END FUNCTION

FUNCTION ShotInRange (s, range)

IF ABS(player(0).x - shot(s).x) <= range AND ABS(player(0).y - shot(s).y) <= range THEN ShotInRange = 1

END FUNCTION

SUB SpawnEnemyShot (e, d, st)       ' x, y, dir, shot type (, snd)

FOR s = 1 TO 32
  IF shot(s).active = 0 THEN
    SELECT CASE d
     CASE up
      shot(s).y = enemy(e).y - (enemy(e).tysize / 2) - (shottype(st).ysize / 2)
      shot(s).yv = -shottype(st).velocity
      shot(s).x = enemy(e).x: shot(s).xv = 0
     CASE down
      shot(s).y = enemy(e).y + (enemy(e).tysize / 2) + (shottype(st).ysize / 2)
      shot(s).yv = shottype(st).velocity
      shot(s).x = enemy(e).x: shot(s).xv = 0
     CASE left
      shot(s).x = enemy(e).x - (enemy(e).txsize / 2) - (shottype(st).xsize / 2)
      shot(s).xv = -shottype(st).velocity
      shot(s).y = enemy(e).y: shot(s).yv = 0
     CASE right
      shot(s).x = enemy(e).x + (enemy(e).txsize / 2) + (shottype(st).xsize / 2)
      shot(s).xv = shottype(st).velocity
      shot(s).y = enemy(e).y: shot(s).yv = 0
    END SELECT

    'PlaySound snd
    shot(s).id = st
    shot(s).sframe = shottype(st).sframe
    shot(s).eframe = shottype(st).eframe
    shot(s).delay = shottype(st).framedelay
    shot(s).frame = shot(s).sframe
    shot(s).active = 1

    EXIT FOR
  END IF
NEXT s

END SUB

SUB SpawnPlayerShot

player(0).idletime = 0                 'player pressed shoot key
IF player(0).frozen THEN EXIT SUB      'player not allowed to shoot
IF player(0).reload <> 0 THEN EXIT SUB 'if already shot recently (wait reload)

FOR s = 1 TO 32
  IF shot(s).active = 0 THEN
    IF player(0).aim = -1 THEN
      IF player(0).xdir = left THEN shot(s).x = player(0).x - (player(0).txsize / 2): shot(s).xv = -shottype(keenshot).velocity
      IF player(0).xdir = right THEN shot(s).x = player(0).x + (player(0).txsize / 2): shot(s).xv = shottype(keenshot).velocity
      shot(s).y = player(0).y: shot(s).yv = 0
     ELSE
      IF player(0).aim = up THEN shot(s).y = player(0).y - (player(0).tysize / 2): shot(s).yv = -shottype(keenshot).velocity
      IF player(0).aim = down THEN shot(s).y = player(0).y + (player(0).tysize / 2): shot(s).yv = shottype(keenshot).velocity
      shot(s).x = player(0).x: shot(s).xv = 0
    END IF

    IF player(0).ammo THEN
      PlaySound 4
      shot(s).id = keenshot
      shot(s).sframe = shottype(keenshot).sframe
      shot(s).eframe = shottype(keenshot).eframe
      shot(s).delay = shottype(keenshot).framedelay
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

SUB WriteShotsToFile (f)

FOR s = 1 TO 32: totalactiveshots = totalactiveshots + shot(s).active: NEXT s

PUT #f, , totalactiveshots
FOR s = 1 TO 32
  IF shot(s).active THEN PUT #f, , shot(s)
NEXT s

END SUB


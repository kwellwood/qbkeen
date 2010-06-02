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

TYPE shottype
 x AS SINGLE
 y AS SINGLE
 xv AS SINGLE
 yv AS SINGLE
 frame AS LONG
 sframe AS LONG
 eframe AS LONG
 delay AS INTEGER
 active AS INTEGER
END TYPE

ON ERROR GOTO ErrorHandler

DIM SHARED shotsframe&, shoteframe&, shotframedelay, shotxsize, shotysize
DIM SHARED shotexpsframe&, shotexpeframe&, shotexpframedelay, shotexpxsize
DIM SHARED shotexpysize, shotvelocity
DIM SHARED shot(1 TO 5) AS shottype
'============================================================================
ErrorHandler:
e = ERR
ErrorHandlerSub e
RESUME NEXT

SUB ClearShots

FOR s = 1 TO 5: shot(s).active = 0: NEXT s

END SUB

SUB DoShots

FOR s = 1 TO 5
  IF shot(s).active THEN
    '--- move shot ---
    shot(s).x = shot(s).x + shot(s).xv
    shot(s).y = shot(s).y + shot(s).yv
   
    '--- map boundaries ---
    IF shot(s).x < 0 OR shot(s).x > MapWidth * ts THEN shot(s).active = 0
    IF shot(s).y < 0 OR shot(s).y > MapHeight * ts THEN shot(s).active = 0

    '--- hit a wall ---
    IF ShotCollide(s) THEN KillShot s
 
    '--- hit an enemy ---
    sx1 = shot(s).x - (shotxsize / 2): sy1 = shot(s).y - (shotysize / 2)
    sx2 = shot(s).x + (shotxsize / 2): sy2 = shot(s).y + (shotysize / 2)
    e = ShotEnemy(sx1, sy1, sx2, sy2)
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
   
    x1 = shot(s).x - (shotxsize / 2)
    x2 = shot(s).x + (shotxsize / 2)
    y1 = shot(s).y - (shotysize / 2)
    y2 = shot(s).y + (shotysize / 2)
    IF OnCamera(x1, y1, x2, y2) THEN
     
      frame& = shot(s).sframe + (INT(anmcounter / shot(s).delay) MOD (shot(s).eframe - shot(s).frame))
      PutSprite frame&, shot(s).x - CameraOrigX - (shotxsize / 2), shot(s).y - CameraOrigY - (shotysize / 2), drawpage
    END IF
  END IF
NEXT s

END SUB

SUB InitWeapons

OPEN "engine.dat" FOR INPUT AS 1
  DO: INPUT #1, Text$
  LOOP UNTIL UCASE$(Text$) = "[WEAPONS.DAT]"
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
a = AddSprite(x, y, shotexpsframe&, shotexpeframe&, shotexpframedelay, shotexpxsize, shotexpysize, 0, 0)

'--- play sound if in hearing range ---
IF ShotInRange(s, 240) THEN PlaySound 6

END SUB

SUB LoadShotsFromFile (f)

FOR s = 1 TO 5: GET #f, , shot(s): NEXT s

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
IF TileType(Map&(sx, sy)) = 2 THEN ShotCollide = SlopeHeight(sx2, sy2, 0): EXIT FUNCTION
IF TileType(MapFG&(sx, sy)) = 2 THEN ShotCollide = SlopeHeight(sx2, sy2, 1): EXIT FUNCTION

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

SUB WriteShotsToFile (f)

FOR s = 1 TO 5: PUT #f, , shot(s): NEXT s

END SUB


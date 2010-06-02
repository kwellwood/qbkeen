DEFINT A-Z
'$INCLUDE: 'engine.bi'
'$INCLUDE: 'directqb.bi'
'$INCLUDE: 'enemies.bi'
'$INCLUDE: 'enemies1.bi'
'$INCLUDE: 'enemies2.bi'

'--- MISC ROUTINES ---
DECLARE FUNCTION AddSprite (x, y, frame&, eframe&, delay, xsize, ysize, deadly, repeat)
DECLARE SUB MoveSprite (s, x, y)
DECLARE FUNCTION CameraOrigX ()
DECLARE FUNCTION CameraOrigY ()
DECLARE FUNCTION OnCamera (x1, y1, x2, y2)
DECLARE FUNCTION HitPoint (x!, y!)
DECLARE SUB PutSprite (t&, x, y, p)
DECLARE FUNCTION SlopeHeight (x, y, l)
DECLARE SUB EntityOnGround (onground, onslope, onobject, x!, y!, yv!, ysize)
DECLARE FUNCTION MapHeight ()
DECLARE FUNCTION MapWidth ()
DECLARE SUB ShiftPlayer (x!, y!)
DECLARE FUNCTION Map& (x, y)
DECLARE FUNCTION MapFG& (x, y)
DECLARE FUNCTION TileType (t&)
'$STATIC

'--- PRIVATE ROUTINES ---
DECLARE SUB DoEnemyFrame (e)
DECLARE SUB EnemyAI (e)
DECLARE SUB EnemyClipPoints (e)
DECLARE SUB EnemyHitSlope (e, x!, y!, l)
DECLARE SUB EnemyHitWall (e, p, hx!, hy!) 'point hit, clippoint hit (x, y)
DECLARE SUB EnemyPhysics (e)
DECLARE SUB SpawnEnemy (e)
DECLARE FUNCTION EnemyHitPoint (x!, y!)
'============================================================================
CONST slug = 1, bounder = 2, mushroom = 3, lick = 4      ' enemy id constants
CONST arachnut = 5, worm = 6, snake = 7, ancient = 8     '
CONST spearup = 9, speardown = 10, spearleft = 11        '
CONST spearright = 12, shooterup = 13, shooterdown = 14  '
CONST shooterleft = 15, shooterright = 16                '

CONST dead = 10                                          ' global constants
CONST bouncelo = 1, bouncehi = 2                         ' mushroom constants
CONST crawling = 0                                       ' slug constants
CONST slugcrawl1 = 0, slugcrawl2 = 1, slugpooping = 2    '
CONST bounceup = 0, bouncefollow = 1                     ' bounder constants
CONST sitonground = 0, attacking = 2 ', bouncefollow = 1 ' lick constants
CONST firesmall = 1, firemed = 2, firebig = 3            '
CONST stunned = 1, waking = 2                            ' arachnut constants
CONST wormcrawl1 = 0, wormcrawl2 = 1                     ' worm constants
CONST snakemove = 0, snakepeek = 1, snakeattack = 2      ' snake constants
CONST walking = 0, brooding = 1                          ' ancient constants
CONST ancientwalk1 = 0, ancientwalk2 = 1                 '
CONST ancientbrood = 2                                   '
CONST spearsit = 0, spearattack = 1                      ' spear constants
CONST shooterwait = 0                                    ' shooter constants

ON ERROR GOTO ErrorHandler

DIM SHARED starsStart&, starsEnd&    ' for tracking stars with enemy movement
DIM SHARED friction!, gravity!       ' physics values
'============================================================================
ErrorHandler:
e = ERR
ErrorHandlerSub e
RESUME NEXT

FUNCTION ActiveEnemies

ActiveEnemies = LEN(activefoestack)

END FUNCTION

SUB DoEnemyFrame (e)

'--- Update direction if moving ---
IF enemy(e).xv < 0 THEN
  enemy(e).xdir = left
 ELSEIF enemy(e).xv > 0 THEN
  enemy(e).xdir = right
END IF

'--- Select enemy type ---
SELECT CASE enemy(e).id
 CASE slug: SlugFrames e
 CASE bounder: BounderFrames e
 CASE mushroom: MushroomFrames e
 CASE lick: LickFrames e
 CASE arachnut: ArachnutFrames e
 CASE worm: WormFrames e
 CASE snake: SnakeFrames e
 CASE ancient: AncientFrames e
 CASE spearup TO spearright: SpearFrames e
 CASE shooterup TO shooterright: ShooterFrames e
END SELECT

END SUB

SUB DrawEnemies

FOR k = 1 TO LEN(activefoestack)
  e = ASC(MID$(activefoestack, k, 1))

  x1 = enemy(e).x - (enemy(e).txsize / 2)
  y1 = enemy(e).y - (enemy(e).tysize / 2)
  x2 = enemy(e).x + (enemy(e).txsize / 2)
  y2 = enemy(e).y + (enemy(e).tysize / 2)
  IF OnCamera(x1, y1, x2, y2) THEN
     
    x = enemy(e).x - CameraOrigX - (enemy(e).txsize / 2)
    y = enemy(e).y - CameraOrigY - (enemy(e).tysize / 2)
   
    frame& = enemy(e).frame
    PutSprite frame&, x, y, drawpage
  END IF
NEXT k

END SUB

SUB EnemyAI (e)

'--- select type of enemy ai ---
SELECT CASE enemy(e).id
 CASE slug: SlugAI e
 CASE bounder: BounderAI e
 CASE mushroom: MushroomAI e
 CASE lick: LickAI e
 CASE arachnut: ArachnutAI e
 CASE worm: WormAI e
 CASE snake: SnakeAI e
 CASE ancient: AncientAI e
 CASE spearup TO spearright: SpearAI e
 CASE shooterup TO shooterright: ShooterAI e
END SELECT

END SUB

SUB EnemyClipPoints (e)

'--- Update clippoints for an enemy ---
EClipPoint(1).x = enemy(e).x: EClipPoint(1).y = enemy(e).y - enemy(e).ysize / 2
EClipPoint(2).x = enemy(e).x: EClipPoint(2).y = enemy(e).y + enemy(e).ysize / 2
EClipPoint(3).x = enemy(e).x - enemy(e).xsize / 2: EClipPoint(3).y = enemy(e).y
EClipPoint(4).x = enemy(e).x + enemy(e).xsize / 2: EClipPoint(4).y = enemy(e).y

END SUB

SUB EnemyHitSlope (e, x!, y!, l)

x = x!: y = y!
h = SlopeHeight(x, y, l)
IF h > ts THEN h = ts
IF h < -ts THEN h = -ts

IF h THEN
  enemy(e).y = enemy(e).y + h
  enemy(e).yv = 0
  enemy(e).onground = 1
  enemy(e).onslope = 1
  EnemyClipPoints e
END IF

END SUB

SUB EnemyHitWall (e, p, hx!, hy!)

'+--1--+
'|     |
'|     |
'3     4
'|     |
'|     |
'+--2--+

side = -1

IF p = 1 THEN
  ny! = INT((hy! - (hy! MOD ts)) + ts)
  side = up
 ELSEIF p = 2 THEN
  ny! = INT((hy! - (hy! MOD ts)) - 1)
  side = down
 ELSEIF p = 3 THEN
  nx! = INT((hx! - (hx! MOD ts)) + ts)
  side = right
 ELSEIF p = 4 THEN
  nx! = INT((hx! - (hx! MOD ts)) - 1)
  side = left
END IF

SELECT CASE side
 CASE up
  enemy(e).yv = 0
  enemy(e).y = ny! + (enemy(e).ysize / 2) + 1
 CASE down
  enemy(e).yv = 0
  enemy(e).y = ny! - (enemy(e).ysize / 2)
  enemy(e).onground = 1
 CASE left
  enemy(e).xv = 0
  IF p = 4 THEN enemy(e).x = nx! - (enemy(e).xsize / 2)
 CASE right
  enemy(e).xv = 0
  IF p = 3 THEN enemy(e).x = nx! + (enemy(e).xsize / 2)
END SELECT

EnemyClipPoints e

END SUB

FUNCTION EnemyInRange (e, range)

IF ABS(player(0).x - enemy(e).x) <= range AND ABS(player(0).y - enemy(e).y) <= range THEN EnemyInRange = 1

END FUNCTION

SUB EnemyPhysics (e)

'-- these enemies are stationary --
IF enemy(e).id >= spearup AND enemy(e).id <= spearright THEN EXIT SUB
IF enemy(e).id >= shooterup AND enemy(e).id <= shooterright THEN EXIT SUB

'-- used to track for star sprite movement --
eoldx! = enemy(e).x: eoldy! = enemy(e).y

EnemyClipPoints e   ' update clippoints for this enemy

'=======[ GRAVITY ]=======
IF enemy(e).onground = 0 THEN
  IF enemy(e).id = mushroom OR enemy(e).id = bounder THEN
    enemy(e).yv = enemy(e).yv + .5      ' light gravity
   ELSE enemy(e).yv = enemy(e).yv + 1   ' regular gravity
  END IF
END IF

'=======[ MAX SPEED ]=======
IF enemy(e).xv > enemy(e).xmax THEN enemy(e).xv = enemy(e).xmax
IF enemy(e).yv > enemy(e).ymax THEN enemy(e).yv = enemy(e).ymax
IF enemy(e).xv < -enemy(e).xmax THEN enemy(e).xv = -enemy(e).xmax
IF enemy(e).yv < -enemy(e).ymax THEN enemy(e).yv = -enemy(e).ymax

'=======[ MOVE ENEMY ]=======
enemy(e).x = enemy(e).x + enemy(e).xv
enemy(e).y = enemy(e).y + enemy(e).yv

'=======[ FRICTION ]=======
enemy(e).xv = enemy(e).xv * (friction! / 2)

'=======[ ZERO HORIZONTAL VELOCITY ]=======
IF enemy(e).xv < .2 AND enemy(e).xv > 0 THEN enemy(e).xv = 0
IF enemy(e).xv > -.2 AND enemy(e).xv < 0 THEN enemy(e).xv = 0

'=======[ MAP BOUNDARIES ]=======
IF enemy(e).x < 0 THEN enemy(e).x = 0: enemy(e).xv = 0
IF enemy(e).y < 0 THEN enemy(e).y = 0: enemy(e).yv = 0
IF enemy(e).x > (MapWidth * ts) - 1 THEN enemy(e).x = (MapWidth * ts) - 1: enemy(e).xv = 0
IF enemy(e).y > (MapHeight * ts) - 1 THEN enemy(e).y = (MapHeight * ts) - 1: enemy(e).yv = 0

'===============================[ CLIPPING ]=================================
' +--1--+
' |     |
' 3     4
' |     |
' +--2--+

'-- if enemy isnt on the ground, start falling --
EntityOnGround enemy(e).onground, enemy(e).onslope, 0, enemy(e).x, enemy(e).y, enemy(e).yv, enemy(e).ysize
  enemy(e).onground = global(0).onground
  enemy(e).onslope = global(0).onslope
  enemy(e).y = global(0).y: enemy(e).yv = global(0).yv

'-- clip to walls and slopes --
FOR cp = 1 TO 4
  EnemyClipPoints e
  SELECT CASE HitPoint(EClipPoint(cp).x, EClipPoint(cp).y)
   CASE 1: EnemyHitWall e, cp, EClipPoint(cp).x, EClipPoint(cp).y
   CASE 2: IF cp = 2 THEN EnemyHitSlope e, EClipPoint(cp).x, EClipPoint(cp).y, 0
   CASE 3: EnemyHitWall e, cp, EClipPoint(cp).x, EClipPoint(cp).y
   CASE 6: IF cp = 2 AND enemy(e).yv >= 0 THEN EnemyHitWall e, cp, EClipPoint(cp).x, EClipPoint(cp).y
   CASE 8: IF cp = 2 THEN EnemyHitSlope e, EClipPoint(cp).x, EClipPoint(cp).y, 1
   CASE 9: EnemyHitWall e, cp, EClipPoint(cp).x, EClipPoint(cp).y
  END SELECT
NEXT cp

'-- move stars with enemy body --
IF enemy(e).status = dead THEN
  MoveSprite enemy(e).starsprite, (enemy(e).x - eoldx!), (enemy(e).y - eoldy!)
END IF

'-- if player standing on this enemy --
IF player(0).onball = e THEN ShiftPlayer (enemy(e).x - eoldx!), (enemy(e).y - eoldy!)

END SUB

FUNCTION EnemyShootable (id)

SELECT CASE id
 CASE worm: EnemyShootable = 0
 CASE ancient: EnemyShootable = 0
 CASE snake: IF enemy(e).status <> snakeattack THEN EnemyShootable = 0 ELSE EnemyShootable = 1
 CASE spearup TO spearright: EnemyShootable = 0
 CASE shooterup TO shooterright: EnemyShootable = 0
 CASE ELSE: EnemyShootable = 1
END SELECT

END FUNCTION

FUNCTION EnemyTouchPlayer (e)

px1 = clippoint(5).x: py1 = clippoint(1).y
px2 = clippoint(6).x: py2 = clippoint(2).y
ex1 = enemy(e).x - (enemy(e).xsize / 2): ey1 = enemy(e).y - (enemy(e).ysize / 2)
ex2 = enemy(e).x + (enemy(e).xsize / 2): ey2 = enemy(e).y + (enemy(e).ysize / 2)
IF (px1 >= ex1 AND px1 <= ex2) OR (px2 >= ex1 AND px2 <= ex2) THEN touch = 1
IF (py1 >= ey1 AND py1 <= ey2) OR (py2 >= ey1 AND py2 <= ey2) THEN touch = touch + 1
IF touch = 2 THEN EnemyTouchPlayer = 1 ELSE EnemyTouchPlayer = 0

END FUNCTION

SUB HandleEnemies

FOR k = 1 TO LEN(activefoestack)
  e = ASC(MID$(activefoestack, k, 1))
 
  IF EnemyInRange(e, 320) OR (enemy(e).id >= spearup AND enemy(e).id <= spearright) THEN
                                 '  if in range /\ (or a spear or shooter)
    EnemyPhysics e               '  keep moving enemy, clipping
    EnemyAI e                    '  check status, change direction or action
  END IF
  DoEnemyFrame e                 'update current frame
NEXT k

END SUB

SUB InitEnemies

OPEN "engine.dat" FOR INPUT AS 1
  DO: INPUT #1, Text$
  LOOP UNTIL UCASE$(Text$) = "[ENEMIES.DAT]"
  INPUT #1, starsStart&    ' first frame of stars
  INPUT #1, starsEnd&      ' last frame of stars
  FOR f = 0 TO 57
    INPUT #1, eframe(f)
    INPUT #1, efsize(f).x
    INPUT #1, efsize(f).y
  NEXT f
CLOSE 1

END SUB

SUB KillEnemy (e)

'--- cant kill these enemies ---
SELECT CASE enemy(e).id
 CASE mushroom: EXIT SUB
 CASE arachnut:
  enemy(e).status = stunned
  enemy(e).actiontime = maxfps * 5
  enemy(e).xv = 0
  EXIT SUB
END SELECT

enemy(e).status = dead: enemy(e).action = dead
enemy(e).actiontime = 0
enemy(e).yv = enemy(e).yv - 6
enemy(e).xv = enemy(e).xv * 4

'--- add stars to sprite stack ---
x = enemy(e).x: y = enemy(e).y - enemy(e).ysize / 2
enemy(e).starsprite = AddSprite(x, y, starsStart&, starsEnd&, 6, 22, 15, 0, 1)

END SUB

SUB LoadEnemies (f)

'--- clear enemy stack ---
activefoestack = ""

GET #f, , numenemies
IF numenemies > 100 THEN debuglog "WARNING: Enemies in map:" + STR$(numenemies): numenemies = 100

'--- load enemies ---
FOR e = 1 TO numenemies
  GET #f, , enemy(e).x
  GET #f, , enemy(e).y
  GET #f, , enemy(e).id
  enemy(e).xv = 0: enemy(e).yv = 0
  enemy(e).xdir = left
  enemy(e).onground = 0
  enemy(e).onslope = 0
  enemy(e).action = 0: enemy(e).actiontime = 0
  enemy(e).status = 0: enemy(e).statustime = 0
  enemy(e).xmax = 1: enemy(e).ymax = 1
  activefoestack = activefoestack + CHR$(e)
  SpawnEnemy e
NEXT e

END SUB

SUB LoadEnemiesFromFile (f)

activefoestack = "": GET #f, , e
FOR k = 1 TO e
  GET #f, , enemy(k)
  activefoestack = activefoestack + CHR$(k)
NEXT k

END SUB

SUB ReverseOnHole (e, mx, my)

fg = TileType(Map&(mx, my))
bg = TileType(MapFG&(mx, my))
IF (bg = 0 AND fg = 0) OR (bg = 3 OR fg = 3) THEN
  IF enemy(e).xdir = left THEN enemy(e).xdir = right ELSE enemy(e).xdir = left
END IF

END SUB

SUB SetEnemyFriction (f!)

friction! = f!

END SUB

SUB SetEnemyGravity (g!)

gravity! = g!

END SUB

FUNCTION ShotEnemy (sx1, sy1, sx2, sy2)

FOR k = 1 TO LEN(activefoestack)
  IF k > LEN(activefoestack) THEN EXIT FOR
  e = ASC(MID$(activefoestack, k, 1))
  IF enemy(e).status <> dead THEN
    IF EnemyShootable(enemy(e).id) THEN
      ex1 = enemy(e).x - (enemy(e).txsize / 2): ey1 = enemy(e).y - (enemy(e).tysize / 2)
      ex2 = enemy(e).x + (enemy(e).txsize / 2): ey2 = enemy(e).y + (enemy(e).tysize / 2)

      '--- is shot touching this enemy ---
      IF sx1 >= ex1 AND sx1 <= ex2 AND sy1 >= ey1 AND sy1 <= ey2 THEN touchenemy = 1
      IF sx2 >= ex1 AND sx2 <= ex2 AND sy1 >= ey1 AND sy1 <= ey2 THEN touchenemy = 1
      IF sx1 >= ex1 AND sx1 <= ex2 AND sy2 >= ey1 AND sy2 <= ey2 THEN touchenemy = 1
      IF sx2 >= ex1 AND sx2 <= ex2 AND sy2 >= ey1 AND sy2 <= ey2 THEN touchenemy = 1

      IF touchenemy THEN ShotEnemy = e: EXIT FOR
    END IF
  END IF
NEXT k

END FUNCTION

SUB SpawnEnemy (e)

'-----------------------
'Used when a new map is loaded to give
' a default frame and status to each enemy.
'-----------------------

SELECT CASE enemy(e).id
 CASE slug
  enemy(e).xdir = left
  enemy(e).action = slugcrawl1
  enemy(e).actiontime = 2
  enemy(e).status = crawling
  enemy(e).onground = 1
  enemy(e).frame = eframe(0)
  enemy(e).txsize = efsize(0).x
  enemy(e).tysize = efsize(0).y
  enemy(e).xmax = 16: enemy(e).ymax = 16
  enemy(e).xsize = 16: enemy(e).ysize = 24
 CASE bounder
  enemy(e).xdir = up
  enemy(e).status = bounceup
  enemy(e).frame = eframe(10)
  enemy(e).txsize = efsize(10).x
  enemy(e).tysize = efsize(10).y
  enemy(e).xmax = 4: enemy(e).ymax = 6
  enemy(e).xsize = 24: enemy(e).ysize = 24
 CASE mushroom
  enemy(e).xdir = left
  enemy(e).status = bouncehi
  enemy(e).action = 0
  enemy(e).actiontime = 0
  enemy(e).onground = 1
  enemy(e).xmax = 0: enemy(e).ymax = 5
  enemy(e).frame = eframe(17)
  enemy(e).txsize = efsize(17).x
  enemy(e).tysize = efsize(17).y
  enemy(e).xsize = 32: enemy(e).ysize = 32
 CASE lick
  enemy(e).xdir = left
  enemy(e).status = sitonground
  enemy(e).frame = eframe(21)
  enemy(e).txsize = efsize(21).x
  enemy(e).tysize = efsize(21).y
  enemy(e).xmax = 4: enemy(e).ymax = 6
  enemy(e).xsize = 22: enemy(e).ysize = 16
 CASE arachnut
  enemy(e).xdir = right
  enemy(e).status = crawling
  enemy(e).frame = eframe(30)
  enemy(e).txsize = efsize(30).x
  enemy(e).tysize = efsize(30).y
  enemy(e).xmax = 4: enemy(e).ymax = 6
  enemy(e).xsize = 40: enemy(e).ysize = 40
 CASE worm
  enemy(e).xdir = left
  enemy(e).status = wormcrawl1
  enemy(e).actiontime = 0
  enemy(e).onground = 1
  enemy(e).frame = eframe(32)
  enemy(e).txsize = efsize(32).x
  enemy(e).tysize = efsize(32).y
  enemy(e).xmax = 6! + RND: enemy(e).ymax = 4
  enemy(e).xsize = 24: enemy(e).ysize = 16
 CASE snake
  enemy(e).xdir = left
  enemy(e).status = snakemove
  enemy(e).actiontime = 0
  enemy(e).onground = 1
  enemy(e).frame = eframe(34)
  enemy(e).txsize = efsize(34).x
  enemy(e).tysize = efsize(34).y
  enemy(e).xmax = 3: enemy(e).ymax = 3
  enemy(e).xsize = 16: enemy(e).ysize = 24  '62, 22
 CASE ancient
  enemy(e).xdir = left
  enemy(e).action = ancientwalk1
  enemy(e).actiontime = 2
  enemy(e).status = walking
  enemy(e).onground = 1
  enemy(e).frame = eframe(42)
  enemy(e).txsize = efsize(42).x
  enemy(e).tysize = efsize(42).y
  enemy(e).xmax = 16: enemy(e).ymax = 16
  enemy(e).xsize = 16: enemy(e).ysize = 38
 CASE spearup TO spearright
  enemy(e).action = 0
  enemy(e).actiontime = maxfps * 2
  enemy(e).status = spearsit
  enemy(e).frame = eframe(46 + (enemy(e).id - spearup) * 2)
  enemy(e).txsize = efsize(46 + (enemy(e).id - spearup) * 2).x
  enemy(e).tysize = efsize(46 + (enemy(e).id - spearup) * 2).y
  enemy(e).xsize = 16: enemy(e).ysize = 16
  IF enemy(e).id = spearup OR enemy(e).id = speardown THEN enemy(e).xsize = 12
  IF enemy(e).id = spearleft OR enemy(e).id = spearright THEN enemy(e).ysize = 12
 CASE shooterup TO shooterright
  enemy(e).action = 0
  enemy(e).actiontime = 0
  enemy(e).status = shooterwait
  enemy(e).frame = eframe(54 + (enemy(e).id - shooterup))
  enemy(e).txsize = efsize(54 + (enemy(e).id - shooterup)).x
  enemy(e).tysize = efsize(54 + (enemy(e).id - shooterup)).y
  enemy(e).xsize = 16: enemy(e).ysize = 16
  IF enemy(e).id = shooterup THEN enemy(e).ysize = 32
  IF enemy(e).id = shooterright THEN enemy(e).xsize = 32
 CASE ELSE: ErrorHandlerSub 170
END SELECT

END SUB

SUB WriteEnemiesToFile (f)

e = LEN(activefoestack): PUT #f, , e
FOR e = 1 TO LEN(activefoestack)
  k = ASC(MID$(activefoestack, e, 1))
  PUT #f, , enemy(k)
NEXT e

END SUB


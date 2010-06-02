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
SUB AssignEnemyFrame (e)

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
END SELECT

END SUB

SUB BounderAI (e)

'--- dont handle if dead ---
IF enemy(e).status = dead THEN EXIT SUB

'--- direction to chase player ---
IF player(0).x > enemy(e).x THEN edir = right ELSE edir = left

'--- decrease timer ---
IF enemy(e).actiontime THEN enemy(e).actiontime = enemy(e).actiontime - 1

'--- movement ---
IF enemy(e).actiontime THEN enemy(e).yv = enemy(e).yv - 2
IF enemy(e).onground = 0 THEN
  SELECT CASE enemy(e).xdir
   CASE up: enemy(e).xv = 0
   CASE left: enemy(e).xv = enemy(e).xv - 2
   CASE right: enemy(e).xv = enemy(e).xv + 2
  END SELECT
END IF

'--- bounce on the ground ---
IF enemy(e).onground AND enemy(e).actiontime = 0 THEN
  enemy(e).actiontime = 5
  enemy(e).action = enemy(e).action - 1
  IF enemy(e).action <= 0 THEN
    IF enemy(e).status = bounceup THEN
      enemy(e).status = bouncefollow
      enemy(e).action = INT(RND * 2)
      SELECT CASE INT(RND * 5)
       CASE 0: IF edir = left THEN enemy(e).xdir = right ELSE enemy(e).xdir = left
       CASE ELSE: enemy(e).xdir = edir
      END SELECT
     ELSE
      enemy(e).status = bounceup
      enemy(e).action = INT(RND * 3) + 1
      enemy(e).xdir = up
      enemy(e).xv = 0
    END IF
  END IF
END IF

END SUB

SUB BounderFrames (e)

'--- Set animated frame with direction ---
SELECT CASE enemy(e).xdir                       '\/ animation delay
 CASE left: framedataslot = 10 + INT(anmcounter / 2) MOD 2
 CASE right: framedataslot = 12 + INT(anmcounter / 2) MOD 2
 CASE up: framedataslot = 14 + INT(anmcounter / 2) MOD 2
END SELECT

IF enemy(e).status = dead THEN framedataslot = 16

enemy(e).frame = eframe(framedataslot)
enemy(e).txsize = efsize(framedataslot).x
enemy(e).tysize = efsize(framedataslot).y

END SUB

SUB DoEnemyFrame (e)

'--- Update direction if moving ---
IF enemy(e).xv < 0 THEN
  enemy(e).xdir = left
 ELSEIF enemy(e).xv > 0 THEN
  enemy(e).xdir = right
END IF

'--- Select enemy type ---
SELECT CASE enemy(e).id
 CASE slug
  SlugFrames e
 CASE bounder
  BounderFrames e
 CASE mushroom
  MushroomFrames e
END SELECT

END SUB

SUB DrawEnemies

FOR k = 1 TO LEN(activefoestack(0))
  e = ASC(MID$(activefoestack(0), k, 1))

  IF enemy(e).x + (enemy(e).txsize / 2) >= camera(0).vx1 AND enemy(e).x - (enemy(e).txsize / 2) <= camera(0).vx2 THEN
    IF enemy(e).y + (enemy(e).tysize / 2) >= camera(0).vy1 AND enemy(e).y - (enemy(e).tysize / 2) <= camera(0).vy2 THEN
   
      x = enemy(e).x - camera(0).vx1 - (enemy(e).txsize / 2)
      y = enemy(e).y - camera(0).vy1 - (enemy(e).tysize / 2)

      frame& = enemy(e).frame
      PutSprite frame&, x, y, drawpage
    END IF
  END IF
NEXT k

END SUB

SUB EnemyAI (e)

'--- select type of enemy ai ---
SELECT CASE enemy(e).id
 CASE slug
  SlugAI e
 CASE bounder
  BounderAI e
 CASE mushroom
  MushroomAI e
END SELECT

END SUB

SUB EnemyClippoints (e)

'--- Update clippoints for an enemy ---
Eclippoint(1).x = enemy(e).x: Eclippoint(1).y = enemy(e).y - enemy(e).ysize / 2
Eclippoint(2).x = enemy(e).x: Eclippoint(2).y = enemy(e).y + enemy(e).ysize / 2
Eclippoint(3).x = enemy(e).x - enemy(e).xsize / 2: Eclippoint(3).y = enemy(e).y
Eclippoint(4).x = enemy(e).x + enemy(e).xsize / 2: Eclippoint(4).y = enemy(e).y

END SUB

FUNCTION EnemyHitPoint (x!, y!)

'--- get tile coordinates ---
mx = INT(x! / ts) + 1
my = INT(y! / ts) + 1

fg = TileType(MapFG&(mx, my))
bg = TileType(Map&(mx, my))
IF fg = 2 THEN EnemyHitPoint = 8: EXIT FUNCTION    'slope in foreground
IF fg = 9 THEN EnemyHitPoint = fg: EXIT FUNCTION   'wall in foreground
EnemyHitPoint = bg

END FUNCTION

SUB EnemyHitSlope (e, x!, y!, l)

x = x!: y = y!
h = SlopeHeight(x, y, l)
IF h > ts THEN h = ts
IF h < -ts THEN h = -ts

IF h THEN
  enemy(e).y = INT(enemy(e).y) + h
  enemy(e).yv = 0
  enemy(e).onground = 1
  enemy(e).onslope = 1
  EnemyClippoints e
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

EnemyClippoints e

END SUB

FUNCTION EnemyInRange (e, range)

IF ABS(player(0).x - enemy(e).x) <= range AND ABS(player(0).y - enemy(e).y) <= range THEN EnemyInRange = 1

END FUNCTION

SUB EnemyOnGround (e)

IF enemy(e).yv >= 0 THEN
  mapx = INT(enemy(e).x / ts) + 1: mapy = INT((enemy(e).y + (enemy(e).ysize / 2)) / ts) + 1
  IF INT((enemy(e).y + (enemy(e).ysize / 2)) MOD ts) >= ts - 1 THEN  '-2
    mapx = INT(enemy(e).x / ts) + 1: mapy = INT((enemy(e).y + (enemy(e).ysize / 2)) / ts) + 2
    IF TileType(Map&(mapx, mapy)) = 1 THEN
      enemy(e).onground = 1
      IF INT((enemy(e).y + (enemy(e).ysize / 2)) MOD ts) < ts - 1 THEN enemy(e).y = INT(enemy(e).y) + 1
     ELSE
      enemy(e).onground = 0
    END IF
   ELSE
    enemy(e).onground = 0
  END IF
 ELSE
  enemy(e).onground = 0
END IF

'mapx = INT(enemy(e).x / ts) + 1
'mapy = INT((enemy(e).y + (enemy(e).ysize / 2)) / ts) + 2

IF TileType(Map&(mapx, mapy)) = 2 OR TileType(MapFG&(mapx, mapy)) = 2 THEN
  IF TileType(Map&(mapx, mapy)) = 2 THEN l = 0 ELSE l = 1
  x = Eclippoint(2).x: y = Eclippoint(2).y
  h1 = SlopeHeight(x, y, l)
  h2 = SlopeHeight(x, y + 1, l)
  IF h1 = 0 AND h2 < 0 THEN
    enemy(e).onground = 1: enemy(e).onslope = 1
   ELSE
    enemy(e).onground = 0: enemy(e).onslope = 0
  END IF
END IF


'if enemy not falling
'  if bottom of enemy on top of a tile
'    if enemy of top of wall tile
'      enemy is onground
'      if enemy is into the ground then move up
'     else not onground
'   else not onground
' else not onground
'end if

END SUB

SUB EnemyPhysics (e)

'-- used to track for star sprite movement
eoldx = enemy(e).x: eoldy = enemy(e).y

EnemyClippoints e   ' update clippoints for this enemy
EnemyOnGround e     ' if enemy isnt on the ground, start falling

'=======[ GRAVITY ]=======
IF enemy(e).onground = 0 THEN
  IF enemy(e).id = mushroom OR enemy(e).id = bounder THEN
    enemy(e).yv = enemy(e).yv + .5      ' light gravity for mushroom
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

'=======[ ROUND ENEMY LOCATION ]=======
IF enemy(e).xv = 0 THEN enemy(e).x = INT(enemy(e).x)
IF enemy(e).yv = 0 THEN enemy(e).y = INT(enemy(e).y)

'=======[ MAP BOUNDARIES ]=======
IF enemy(e).x < 0 THEN enemy(e).x = 0: enemy(e).xv = 0
IF enemy(e).y < 0 THEN enemy(e).y = 0: enemy(e).yv = 0
IF enemy(e).x > (mapxsize * ts) - 1 THEN enemy(e).x = (mapxsize * ts) - 1: enemy(e).xv = 0
IF enemy(e).y > (mapysize * ts) - 1 THEN enemy(e).y = (mapysize * ts) - 1: enemy(e).yv = 0

'===============================[ CLIPPING ]=================================
' +--1--+
' |     |
' 3     4
' |     |
' +--2--+

FOR cp = 1 TO 4
  EnemyClippoints e
  SELECT CASE EnemyHitPoint(Eclippoint(cp).x, Eclippoint(cp).y)
   CASE 1: EnemyHitWall e, cp, Eclippoint(cp).x, Eclippoint(cp).y
   CASE 2: IF cp = 2 THEN EnemyHitSlope e, Eclippoint(cp).x, Eclippoint(cp).y, 0
   CASE 3: EnemyHitWall e, cp, Eclippoint(cp).x, Eclippoint(cp).y
   CASE 8: IF cp = 2 THEN EnemyHitSlope e, Eclippoint(cp).x, Eclippoint(cp).y, 1
   CASE 9: EnemyHitWall e, cp, Eclippoint(cp).x, Eclippoint(cp).y
  END SELECT
NEXT cp

IF enemy(e).status = dead THEN
  MoveSprite enemy(e).starsprite, (enemy(e).x - eoldx), (enemy(e).y - eoldy)
END IF

END SUB

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

FOR k = 1 TO LEN(activefoestack(0))
  e = ASC(MID$(activefoestack(0), k, 1))
 
  IF EnemyInRange(e, 450) THEN   'if in range
    EnemyPhysics e               '  keep moving enemy, clipping
    EnemyAI e                    '  check status, change direction or action
  END IF
  DoEnemyFrame e                 'update current frame
NEXT k

END SUB

SUB InitEnemies

'OPEN "enemy.dat" FOR INPUT AS 1
OPEN "engine.dat" FOR INPUT AS 1
  DO: INPUT #1, text$
  LOOP UNTIL UCASE$(text$) = "[ENEMY.DAT]"
  FOR f = 0 TO 20
    INPUT #1, eframe(f)
    INPUT #1, efsize(f).x
    INPUT #1, efsize(f).y
  NEXT f
CLOSE 1

END SUB

SUB KillEnemy (e)

'--- cant kill this enemy ---
IF enemy(e).id = mushroom THEN EXIT SUB

enemy(e).status = dead: enemy(e).action = dead
enemy(e).yv = enemy(e).yv - 6
       
'--- add stars to sprite stack ---
x = enemy(e).x: y = enemy(e).y - enemy(e).ysize / 2
AddSprite x, y, 508, 510, 6, 22, 15, 0, 1
enemy(e).starsprite = biti(0)

END SUB

SUB LoadEnemies (f)

'--- clear enemy stack ---
activefoestack(0) = ""

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
  activefoestack(0) = activefoestack(0) + CHR$(e)
  AssignEnemyFrame e
NEXT e

END SUB

SUB MushroomAI (e)

'--- Update direction ---
IF player(0).x > enemy(e).x THEN enemy(e).xdir = right
IF player(0).x <= enemy(e).x THEN enemy(e).xdir = left

'--- decrease timer ---
IF enemy(e).actiontime THEN enemy(e).actiontime = enemy(e).actiontime - 1

'--- jump up if in action ---
IF enemy(e).actiontime THEN enemy(e).yv = enemy(e).yv - 2

'--- bounce on the ground ---
IF enemy(e).onground AND enemy(e).actiontime = 0 THEN
  IF enemy(e).status = bouncehi THEN
    '--- switch to low bounce ---
    IF EnemyInRange(e, 300) THEN PlaySound 20
    enemy(e).status = bouncelo
    enemy(e).action = 1
    enemy(e).actiontime = 4   ' ticks to jump
   ELSEIF enemy(e).status = bouncelo THEN
    IF EnemyInRange(e, 300) THEN PlaySound 20
    enemy(e).action = enemy(e).action + 1
    IF enemy(e).action > 2 THEN
      '--- switch to high bounce
      enemy(e).status = bouncehi
      enemy(e).action = 0
      enemy(e).actiontime = 12
     ELSE
      '--- continue low bounce ---
      enemy(e).actiontime = 4
    END IF
  END IF
END IF

'--- Do collision detection with player ---
IF EnemyTouchPlayer(e) THEN KillPlayer

END SUB

SUB MushroomFrames (e)

'--- Set animated frame with direction ---
SELECT CASE enemy(e).xdir                       '\/ mushroom animation delay
 CASE left: framedataslot = 17 + INT(anmcounter / 2) MOD 2
 CASE right: framedataslot = 19 + INT(anmcounter / 2) MOD 2
END SELECT

enemy(e).frame = eframe(framedataslot)
enemy(e).txsize = efsize(framedataslot).x
enemy(e).tysize = efsize(framedataslot).y

END SUB

SUB SlugAI (e)

'====[ Handle action timer ]====
enemy(e).actiontime = enemy(e).actiontime - 1
'--- reset to crawling ---
IF enemy(e).status = slugpooping AND enemy(e).actiontime <= 0 THEN
  enemy(e).status = crawling: enemy(e).action = slugcrawl1
END IF

'====[ Handle status ]====
SELECT CASE enemy(e).status
 CASE crawling
  '--- Continue crawling ---
  IF enemy(e).actiontime <= 0 THEN
    IF enemy(e).action = slugcrawl1 THEN
      IF enemy(e).xdir = left THEN enemy(e).xv = -6 ELSE enemy(e).xv = 6
      enemy(e).action = slugcrawl2: enemy(e).actiontime = maxfps / 5
     ELSEIF enemy(e).action = slugcrawl2 THEN
      enemy(e).action = slugcrawl1: enemy(e).actiontime = maxfps / 5
    END IF
  END IF
  
  '--- Change direction ---
  IF enemy(e).xdir = left THEN mx = INT(((enemy(e).x - enemy(e).xsize / 2) - 6) / ts) + 1
  IF enemy(e).xdir = right THEN mx = INT(((enemy(e).x + enemy(e).xsize / 2) + 6) / ts) + 1
  '-- random change --
  IF INT(RND * 400) = 1 THEN
    IF enemy(e).xdir = left THEN enemy(e).xdir = right ELSE enemy(e).xdir = left
  END IF
  '-- wall or map edge --
  my = INT(enemy(e).y / ts) + 1
  IF TileType(Map&(mx, my)) = 1 OR mx > mapxsize * ts OR mx < 0 THEN
    IF enemy(e).xdir = left THEN enemy(e).xdir = right ELSE enemy(e).xdir = left
  END IF
  '-- big hole --
  my = INT(enemy(e).y / ts) + 2
  IF TileType(Map&(mx, my)) = 0 AND TileType(MapFG&(mx, my)) = 0 THEN
    IF enemy(e).xdir = left THEN enemy(e).xdir = right ELSE enemy(e).xdir = left
  END IF

  '--- Possibility of pooping ---
  p = INT(RND * 350)
  IF p = 1 THEN
    IF EnemyInRange(e, 240) THEN PlaySound 18
    '--- set new status ---
    enemy(e).status = slugpooping
    enemy(e).action = slugpooping
    enemy(e).actiontime = maxfps
    '--- create poop ---
    x = enemy(e).x: y = enemy(e).y + (enemy(e).ysize / 2)
    AddSprite x, y, eframe(8), eframe(9), maxfps * 2, efsize(8).x, efsize(8).y, 1, 0
  END IF
END SELECT

'--- Do collision detection with player ---
IF enemy(e).status <> dead THEN
  IF EnemyTouchPlayer(e) THEN KillPlayer
END IF

END SUB

SUB SlugFrames (e)

IF enemy(e).status = dead THEN
  framedataslot = 7
 ELSE
  SELECT CASE enemy(e).action
    CASE slugcrawl1
     IF enemy(e).xdir = left THEN framedataslot = 0 ELSE framedataslot = 3
    CASE slugcrawl2
     IF enemy(e).xdir = left THEN framedataslot = 1 ELSE framedataslot = 4
    CASE slugpooping
     IF enemy(e).xdir = left THEN framedataslot = 2 ELSE framedataslot = 5
  END SELECT
END IF

enemy(e).frame = eframe(framedataslot)
enemy(e).txsize = efsize(framedataslot).x
enemy(e).tysize = efsize(framedataslot).y

END SUB


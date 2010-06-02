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
 CASE ball
  enemy(e).xdir = left
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

SUB DoEnemyFrame (e)

'=====[ UPDATE DIRECTION IF MOVIN ]=====
IF enemy(e).xv < 0 THEN
  enemy(e).xdir = left
 ELSEIF enemy(e).xv > 0 THEN
  enemy(e).xdir = right
END IF

SELECT CASE enemy(e).id
 CASE slug
  SlugFrames e
 CASE ball
  'BallFrames
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

SELECT CASE enemy(e).id
 CASE slug
  SlugAI e
 CASE ball
  'BallAI
 CASE mushroom
  MushroomAI e
END SELECT

END SUB

FUNCTION EnemyHitPoint (x!, y!)

mx = INT(x! / ts) + 1
my = INT(y! / ts) + 1
'IF TileType(MapFG&(mx, my)) = 2 THEN EnemyHitPoint = 8 ELSE EnemyHitPoint = TileType(Map&(mx, my))

fg = TileType(MapFG&(mx, my))
bg = TileType(Map&(mx, my))
IF fg = 2 THEN EnemyHitPoint = 8: EXIT FUNCTION   'slope in foreground
IF fg = 9 THEN EnemyHitPoint = fg: EXIT FUNCTION  'wall in foreground
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

  'EClipPoint(1).x = enemy(e).x: EClipPoint(1).y = enemy(e).y - enemy(e).ysize / 2
  'EClipPoint(2).x = enemy(e).x: EClipPoint(1).y = enemy(e).y + enemy(e).ysize / 2
  'EClipPoint(3).x = enemy(e).x - enemy(e).xsize / 2: EClipPoint(3).y = enemy(e).y
  'EClipPoint(4).x = enemy(e).x + enemy(e).xsize / 2: EClipPoint(4).y = enemy(e).y
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

'EClipPoint(1).x = enemy(e).x: EClipPoint(1).y = enemy(e).y - enemy(e).ysize / 2
'EClipPoint(2).x = enemy(e).x: EClipPoint(1).y = enemy(e).y + enemy(e).ysize / 2
'EClipPoint(3).x = enemy(e).x - enemy(e).xsize / 2: EClipPoint(3).y = enemy(e).y
'EClipPoint(4).x = enemy(e).x + enemy(e).xsize / 2: EClipPoint(4).y = enemy(e).y

END SUB

SUB EnemyOnGround (e)

IF enemy(e).yv >= 0 THEN
  IF INT((enemy(e).y + (enemy(e).ysize / 2)) MOD ts) >= ts - 2 THEN
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

END SUB

SUB EnemyPhysics (e)

EnemyOnGround e     ' if enemy isnt on the ground, start falling

'=======[ GRAVITY ]=======
IF enemy(e).onground = 0 THEN
  IF enemy(e).id = mushroom THEN enemy(e).yv = enemy(e).yv + .5 ELSE enemy(e).yv = enemy(e).yv + 1
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
'enemy(e).yv = enemy(e).yv * friction!

'=======[ ZERO VELOCITY ]=======
IF enemy(e).xv < .2 AND enemy(e).xv > 0 THEN enemy(e).xv = 0
IF enemy(e).xv > -.2 AND enemy(e).xv < 0 THEN enemy(e).xv = 0
'IF enemy(e).yv < .2 AND enemy(e).yv > 0 THEN enemy(e).yv = 0
'IF enemy(e).yv > -.2 AND enemy(e).yv < 0 THEN enemy(e).yv = 0

'=======[ ROUND ENEMY LOCATION ]=======
IF enemy(e).xv = 0 THEN enemy(e).x = INT(enemy(e).x)
IF enemy(e).yv = 0 THEN enemy(e).y = INT(enemy(e).y)

'=======[ BOUNDARIES ]=======
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

EClipPoint(1).x = enemy(e).x: EClipPoint(1).y = enemy(e).y - enemy(e).ysize / 2
EClipPoint(2).x = enemy(e).x: EClipPoint(2).y = enemy(e).y + enemy(e).ysize / 2
EClipPoint(3).x = enemy(e).x - enemy(e).xsize / 2: EClipPoint(3).y = enemy(e).y
EClipPoint(4).x = enemy(e).x + enemy(e).xsize / 2: EClipPoint(4).y = enemy(e).y

FOR cp = 1 TO 4
  SELECT CASE EnemyHitPoint(EClipPoint(cp).x, EClipPoint(cp).y)
   CASE 1: EnemyHitWall e, cp, EClipPoint(cp).x, EClipPoint(cp).y
   CASE 2: IF cp = 2 THEN EnemyHitSlope e, EClipPoint(cp).x, EClipPoint(cp).y, 0
   CASE 3: EnemyHitWall e, cp, EClipPoint(cp).x, EClipPoint(cp).y
   CASE 8: IF cp = 2 THEN EnemyHitSlope e, ClipPoint(cp).x, ClipPoint(cp).y, 1
   CASE 9: EnemyHitWall e, cp, EClipPoint(cp).x, EClipPoint(cp).y
  END SELECT
NEXT cp

END SUB

SUB HandleEnemies

FOR k = 1 TO LEN(activefoestack(0))
  e = ASC(MID$(activefoestack(0), k, 1))
 
  EnemyPhysics e  ' keep moving enemy, clipping
  EnemyAI e       ' check status, change direction or action
  DoEnemyFrame e  ' update current frame
NEXT k

END SUB

SUB InitEnemies

OPEN "enemy.dat" FOR INPUT AS 1
  FOR f = 0 TO 20
    INPUT #1, eframe(f)
    INPUT #1, efsize(f).x
    INPUT #1, efsize(f).y
  NEXT f
CLOSE 1

END SUB

SUB KillEnemy (e)

IF enemy(e).id = mushroom THEN EXIT SUB

enemy(e).status = dead: enemy(e).action = dead
enemy(e).yv = enemy(e).yv - 6
        
'--- add stars to sprite stack ---
IF LEN(unusedspritestack(0)) THEN
  sp = ASC(LEFT$(unusedspritestack(0), 1))
  unusedspritestack(0) = RIGHT$(unusedspritestack(0), LEN(unusedspritestack(0)) - 1)
  activespritestack(0) = activespritestack(0) + CHR$(sp)
  sprite(sp).x = enemy(e).x: sprite(sp).y = enemy(e).y - enemy(e).ysize / 2
  sprite(sp).sframe = 508
  sprite(sp).frame = sprite(sp).sframe
  sprite(sp).eframe = 510
  sprite(sp).delay = 6
  sprite(sp).ticks = sprite(sp).delay
  sprite(sp).xsize = 22
  sprite(sp).ysize = 15
  sprite(sp).repeat = 1
END IF

END SUB

SUB MushroomAI (e)

IF player(0).x > enemy(e).x THEN enemy(e).xdir = right
IF player(0).x <= enemy(e).x THEN enemy(e).xdir = left

IF enemy(e).actiontime THEN enemy(e).actiontime = enemy(e).actiontime - 1
IF enemy(e).actiontime THEN enemy(e).yv = enemy(e).yv - 2

IF enemy(e).onground AND enemy(e).actiontime = 0 THEN
  IF enemy(e).status = bouncehi THEN
    enemy(e).status = bouncelo
    enemy(e).action = 1
    enemy(e).actiontime = 4   ' ticks to jump
   ELSEIF enemy(e).status = bouncelo THEN
    enemy(e).action = enemy(e).action + 1
    IF enemy(e).action > 2 THEN
      enemy(e).status = bouncehi
      enemy(e).action = 0
      enemy(e).actiontime = 12
     ELSE
      enemy(e).actiontime = 4
    END IF
  END IF
END IF

'======[ KILL PLAYER IF TOUCHING ]======
px1 = player(0).x - (player(0).txsize / 4): py1 = player(0).y - (player(0).tysize / 2)
px2 = player(0).x + (player(0).txsize / 4): py2 = player(0).y + (player(0).tysize / 2)
ex1 = enemy(e).x - (enemy(e).xsize / 2): ey1 = enemy(e).y - (enemy(e).ysize / 2)
ex2 = enemy(e).x + (enemy(e).xsize / 2): ey2 = enemy(e).y + (enemy(e).ysize / 2)
'--- is player touching this mushroom ---
IF px1 >= ex1 AND px1 <= ex2 AND py1 >= ey1 AND py1 <= ey2 THEN touchmush = 1
IF px2 >= ex1 AND px2 <= ex2 AND py1 >= ey1 AND py1 <= ey2 THEN touchmush = 1
IF px1 >= ex1 AND px1 <= ex2 AND py2 >= ey1 AND py2 <= ey2 THEN touchmush = 1
IF px2 >= ex1 AND px2 <= ex2 AND py2 >= ey1 AND py2 <= ey2 THEN touchmush = 1
IF touchmush THEN KillPlayer

END SUB

SUB MushroomFrames (e)

SELECT CASE enemy(e).xdir                       '\/ mushroom animation delay
 CASE left: framedataslot = 17 + INT(anmcounter / 2) MOD 2
 CASE right: framedataslot = 19 + INT(anmcounter / 2) MOD 2
END SELECT

enemy(e).frame = eframe(framedataslot)
enemy(e).txsize = efsize(framedataslot).x
enemy(e).tysize = efsize(framedataslot).y

END SUB

SUB SlugAI (e)

enemy(e).actiontime = enemy(e).actiontime - 1
IF enemy(e).status = slugpooping AND enemy(e).actiontime <= 0 THEN
  enemy(e).status = crawling: enemy(e).action = slugcrawl1
END IF

SELECT CASE enemy(e).status
 CASE crawling
  IF enemy(e).actiontime <= 0 THEN
    IF enemy(e).action = slugcrawl1 THEN
      IF enemy(e).xdir = left THEN enemy(e).xv = -6 ELSE enemy(e).xv = 6
      enemy(e).action = slugcrawl2: enemy(e).actiontime = maxfps / 5
     ELSEIF enemy(e).action = slugcrawl2 THEN
      enemy(e).action = slugcrawl1: enemy(e).actiontime = maxfps / 5
    END IF
  END IF
  
  '====[ CLIPPOINTS FOR TURNING ]====
  IF enemy(e).xdir = left THEN mx = INT(((enemy(e).x - enemy(e).xsize / 2) - 6) / ts) + 1
  IF enemy(e).xdir = right THEN mx = INT(((enemy(e).x + enemy(e).xsize / 2) + 6) / ts) + 1
  '----[ TURN AROUND FOR WALL OR MAP EDGE ]----
  my = INT(enemy(e).y / ts) + 1
  IF TileType(Map&(mx, my)) = 1 OR mx > mapxsize * ts OR mx < 0 THEN
    IF enemy(e).xdir = left THEN enemy(e).xdir = right ELSE enemy(e).xdir = left
  END IF
  '----[ TURN AROUND FOR DROP-OFF ]----
  my = INT(enemy(e).y / ts) + 2
  IF TileType(Map&(mx, my)) = 0 THEN
    IF enemy(e).xdir = left THEN enemy(e).xdir = right ELSE enemy(e).xdir = left
  END IF

  '====[ POSSIBILITY OF POOPING ]====
  p = INT(RND * 350)
  IF p = 1 THEN
    enemy(e).status = slugpooping
    enemy(e).action = slugpooping
    enemy(e).actiontime = maxfps
    '--- add poop to sprite stack ---
    IF LEN(unusedspritestack(0)) THEN
      s = ASC(LEFT$(unusedspritestack(0), 1))
      unusedspritestack(0) = RIGHT$(unusedspritestack(0), LEN(unusedspritestack(0)) - 1)
      activespritestack(0) = activespritestack(0) + CHR$(s)
      sprite(s).x = enemy(e).x: sprite(s).y = enemy(e).y + (enemy(e).ysize / 2)
      sprite(s).frame = eframe(8)
      sprite(s).eframe = eframe(9)
      sprite(s).delay = maxfps * 2        ' put back into ticks when ticks=0
      sprite(s).ticks = sprite(s).delay   ' times to wait
      sprite(s).xsize = efsize(8).x
      sprite(s).ysize = efsize(8).y
      sprite(s).deadly = 1
    END IF
  END IF
END SELECT

IF enemy(e).status <> dead THEN
  '======[ KILL PLAYER IF TOUCHING ]======
  px1 = player(0).x - (player(0).txsize / 4): py1 = player(0).y - (player(0).tysize / 2)
  px2 = player(0).x + (player(0).txsize / 4): py2 = player(0).y + (player(0).tysize / 2)
  ex1 = enemy(e).x - (enemy(e).xsize / 2): ey1 = enemy(e).y - (enemy(e).ysize / 2)
  ex2 = enemy(e).x + (enemy(e).xsize / 2): ey2 = enemy(e).y + (enemy(e).ysize / 2)
  '--- is player touching this slug ---
  IF ex1 >= px1 AND ex1 <= px2 AND ey1 >= py1 AND ey1 <= py2 THEN touchslug = 1
  IF ex2 >= px1 AND ex2 <= px2 AND ey1 >= py1 AND ey1 <= py2 THEN touchslug = 1
  IF ex1 >= px1 AND ex1 <= px2 AND ey2 >= py1 AND ey2 <= py2 THEN touchslug = 1
  IF ex2 >= px1 AND ex2 <= px2 AND ey2 >= py1 AND ey2 <= py2 THEN touchslug = 1
  IF touchslug THEN KillPlayer
END IF

END SUB

SUB SlugFrames (e)

SELECT CASE enemy(e).action
  CASE slugcrawl1
   IF enemy(e).xdir = left THEN framedataslot = 0 ELSE framedataslot = 3
  CASE slugcrawl2
   IF enemy(e).xdir = left THEN framedataslot = 1 ELSE framedataslot = 4
  CASE slugpooping
   IF enemy(e).xdir = left THEN framedataslot = 2 ELSE framedataslot = 5
  CASE dead
   framedataslot = 7
END SELECT

'debuglog "enemy:" + STR$(e) + " frame:" + STR$(enemy(e).frame) + " slot:" + STR$(framedataslot)
enemy(e).frame = eframe(framedataslot)
enemy(e).txsize = efsize(framedataslot).x
enemy(e).tysize = efsize(framedataslot).y

END SUB


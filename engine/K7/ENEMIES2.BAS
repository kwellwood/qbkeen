DEFINT A-Z
'$INCLUDE: 'engine.bi'
'$INCLUDE: 'enemies.bi'
'$INCLUDE: 'enemies2.bi'
DECLARE SUB DoAncientRescued ()
DECLARE SUB KillPlayer ()
DECLARE SUB SpawnEnemyShot (e, d, st)
DECLARE FUNCTION AddSprite (x, y, frame&, eframe&, delay, xsize, ysize, deadly, repeat, lifespan)
DECLARE FUNCTION Map& (x, y)
DECLARE FUNCTION MapFG& (x, y)
DECLARE FUNCTION MapWidth ()
DECLARE FUNCTION PlayerFacing (x!, y!)
DECLARE FUNCTION TileType (t&)
'$STATIC
'============================================================================
CONST worm = 6, snake = 7, ancient = 8                   ' enemy id constants
CONST spearup = 9, speardown = 10, spearleft = 11        '
CONST spearright = 12, shooterup = 13, shooterdown = 14  '
CONST shooterleft = 15, shooterright = 16, mimrock = 17  '
CONST cloud = 18                                         '

CONST dead = 10                                    ' enemy global constants
CONST dying = 3                                    ' player constants
CONST wormcrawl1 = 0, wormcrawl2 = 1                     ' worm constants
CONST snakemove = 0, snakepeek = 1, snakeattack = 2      ' snake constants
CONST walking = 0, brooding = 1                          ' ancient constants
CONST ancientwalk1 = 0, ancientwalk2 = 1                 '
CONST ancientbrood = 2                                   '
CONST spearsit = 0, spearattack = 1                      ' spear constants
CONST shooterwait = 0                                    ' shooter constants
CONST mimrocksit = 0, mimrocksneak = 1, mimrockjump = 2  ' mimrock constants
CONST mimrockonhead = 3                                  '
CONST cloudsit = 0, cloudroam = 1, cloudstrike = 2       ' cloud constants

CONST arrowup = 2, arrowdown = 3, arrowleft = 4          ' shottype constants
CONST arrowright = 5                                     '

ON ERROR GOTO ErrorHandler
'============================================================================
ErrorHandler:
e = ERR
ErrorHandlerSub e
RESUME NEXT

SUB AncientAI (e)

'====[ Handle action timer ]====
IF enemy(e).actiontime THEN enemy(e).actiontime = enemy(e).actiontime - 1
'--- reset to crawling ---
IF enemy(e).status = brooding AND enemy(e).actiontime <= 0 THEN
  enemy(e).status = walking: enemy(e).action = ancientwalk1
END IF

'====[ Handle status ]====
IF enemy(e).status = walking THEN
  '--- Continue walking ---
  IF enemy(e).actiontime <= 0 THEN
    IF enemy(e).action = ancientwalk1 THEN
      IF enemy(e).xdir = left THEN enemy(e).xv = -6 ELSE enemy(e).xv = 6
      enemy(e).action = ancientwalk2: enemy(e).actiontime = maxfps / 5
     ELSEIF enemy(e).action = ancientwalk2 THEN
      enemy(e).action = ancientwalk1: enemy(e).actiontime = maxfps / 5
    END IF
  END IF

  '--- Change direction ---
  IF enemy(e).xdir = left THEN mx = INT(((enemy(e).x - enemy(e).xsize / 2) - 6) / ts) + 1
  IF enemy(e).xdir = right THEN mx = INT(((enemy(e).x + enemy(e).xsize / 2) + 6) / ts) + 1
  '-- random change --
  IF INT(RND * 200) = 1 THEN
    IF enemy(e).xdir = left THEN enemy(e).xdir = right ELSE enemy(e).xdir = left
  END IF
  '-- wall or map edge --
  my = INT(enemy(e).y / ts) + 1
  IF TileType(Map&(mx, my)) = 1 OR mx > MapWidth * ts OR mx < 0 THEN
    IF enemy(e).xdir = left THEN enemy(e).xdir = right ELSE enemy(e).xdir = left
  END IF
  '-- big hole --
  my = INT((enemy(e).y + enemy(e).ysize / 2) / ts) + 2
  ReverseOnHole e, mx, my

  '--- Possibility of brooding ---
  IF INT(RND * 200) = 1 THEN
    '--- set new status ---
    enemy(e).status = brooding
    enemy(e).action = ancientbrooding
    enemy(e).actiontime = maxfps
  END IF
END IF

'--- Do collision detection with player ---
IF EnemyTouchPlayer(e) THEN DoAncientRescued

END SUB

SUB AncientFrames (e)

SELECT CASE enemy(e).status
 CASE walking
  addframe = enemy(e).action
  IF enemy(e).xdir = left THEN framedataslot = 42 ELSE framedataslot = 44
 CASE brooding
  addframe = 0
  IF enemy(e).xdir = left THEN framedataslot = 43 ELSE framedataslot = 45
END SELECT

enemy(e).frame = eframe(framedataslot) + addframe
enemy(e).txsize = efsize(framedataslot).x
enemy(e).tysize = efsize(framedataslot).y

END SUB

SUB CloudAI (e)

'--- dont handle if dead ---
IF enemy(e).status = dead THEN EXIT SUB

'--- direction to chase player ---
IF player(0).x > enemy(e).x THEN edir = right ELSE edir = left

'--- decrease timer ---
IF enemy(e).actiontime THEN enemy(e).actiontime = enemy(e).actiontime - 1

SELECT CASE enemy(e).status
 CASE cloudsit     '-----------------------------------------------
  IF EnemyTouchPlayer(e) THEN
    enemy(e).status = cloudroam
    enemy(e).xdir = edir
  END IF
 CASE cloudroam    '-----------------------------------------------
  '-- move cloud --
  IF enemy(e).xdir = left THEN
    enemy(e).xv = -enemy(e).xmax
   ELSE
    enemy(e).xv = enemy(e).xmax
  END IF
  '-- stay on map --
  changedir = 0
  IF enemy(e).x + 4 > MapWidth * ts THEN enemy(e).xdir = left: enemy(e).xv = 0
  IF enemy(e).x - 4 < 0 THEN enemy(e).xdir = right: enemy(e).xv = 0
  '-- randomly change direction --
  IF INT(RND * 150) = 1 THEN
    IF enemy(e).xdir = left THEN enemy(e).xdir = right ELSE enemy(e).xdir = left
    enemy(e).xv = 0
   ELSEIF EnemyInRangeOfX(e, 280, 400) THEN
    enemy(e).xdir = edir
    enemy(e).xv = 0
  END IF
  '-- strike if in range --
  IF EnemyInRange(e, 100) AND enemy(e).y <= player(0).y AND EnemyInRangeOfX(e, 0, 32) AND enemy(e).actiontime = 0 THEN
    enemy(e).status = cloudstrike
    enemy(e).actiontime = maxfps * 1.2
  END IF
 CASE cloudstrike  '-----------------------------------------------
  IF enemy(e).actiontime = INT(maxfps * .75) THEN
    x = INT(enemy(e).x): y = INT(enemy(e).y + enemy(e).ysize \ 2 + efsize(68).y \ 2)
    frameStart& = eframe(68): frameEnd& = eframe(68) + 1
    xsize = efsize(68).x: ysize = efsize(68).y
    a = AddSprite(x, y, frameStart&, frameEnd&, maxfps / 10, xsize, ysize, 1, 1, maxfps \ 2)
  END IF
  IF enemy(e).actiontime = 0 THEN
    enemy(e).status = cloudroam: enemy(e).xdir = edir
    enemy(e).actiontime = maxfps \ 2
  END IF
END SELECT

END SUB

SUB CloudFrames (e)

SELECT CASE enemy(e).status
 CASE cloudsit: framedataslot = 66: anmframe = 0
 CASE cloudroam: framedataslot = 67: anmframe = 0
 CASE cloudstrike: framedataslot = 67: anmframe = (anmcounter \ 1) MOD 2
END SELECT

enemy(e).frame = eframe(framedataslot) + anmframe
enemy(e).txsize = efsize(framedataslot).x
enemy(e).tysize = efsize(framedataslot).y

END SUB

SUB MimrockAI (e)

'--- dont handle if dead ---
IF enemy(e).status = dead THEN EXIT SUB

'--- direction to chase player ---
IF player(0).x > enemy(e).x THEN edir = right ELSE edir = left

'--- decrease timer ---
IF enemy(e).actiontime THEN enemy(e).actiontime = enemy(e).actiontime - 1

SELECT CASE enemy(e).status
 CASE mimrocksit    '-----------------------------------------------
  IF enemy(e).actiontime = 0 AND PlayerFacing(enemy(e).x, enemy(e).y) = 0 AND EnemyInRangeY(e, 100) THEN
    enemy(e).xdir = edir
    IF EnemyInRange(e, 80) AND EnemyInRangeOfX(e, 50, 80) THEN
      enemy(e).status = mimrockjump
      enemy(e).actiontime = 4
     ELSEIF EnemyInRangeOfX(e, 45, 270) THEN
      enemy(e).status = mimrocksneak: enemy(e).actiontime = maxfps / 3
    END IF
  END IF
 CASE mimrocksneak  '-----------------------------------------------
  enemy(e).xdir = edir
  IF enemy(e).actiontime = 0 OR PlayerFacing(enemy(e).x, enemy(e).y) THEN
    enemy(e).status = mimrocksit
    enemy(e).actiontime = maxfps
   ELSE
    IF EnemyInRange(e, 80) AND EnemyInRangeOfX(e, 50, 80) THEN
      enemy(e).status = mimrockjump
      enemy(e).actiontime = 4
     ELSE
      IF enemy(e).xdir = left THEN enemy(e).xv = enemy(e).xv - 1
      IF enemy(e).xdir = right THEN enemy(e).xv = enemy(e).xv + 1
      IF enemy(e).xv > enemy(e).xmax / 2 THEN enemy(e).xv = enemy(e).xmax / 2
      IF enemy(e).xv < -enemy(e).xmax / 2 THEN enemy(e).xv = -enemy(e).xmax / 2
    END IF
  END IF
 CASE mimrockjump   '-----------------------------------------------
  IF enemy(e).onground = 0 OR enemy(e).actiontime THEN
    IF enemy(e).actiontime THEN enemy(e).yv = enemy(e).yv - 2
    IF enemy(e).xdir = left THEN enemy(e).xv = enemy(e).xv - 2
    IF enemy(e).xdir = right THEN enemy(e).xv = enemy(e).xv + 2
   ELSE
    enemy(e).status = mimrockonhead
    enemy(e).actiontime = 2
  END IF
 CASE mimrockonhead '-----------------------------------------------
  IF enemy(e).onground = 0 OR enemy(e).actiontime THEN
    IF enemy(e).actiontime THEN enemy(e).yv = enemy(e).yv - 2
    IF enemy(e).xdir = left THEN enemy(e).xv = enemy(e).xv - 2
    IF enemy(e).xdir = right THEN enemy(e).xv = enemy(e).xv + 2
   ELSEIF enemy(e).onground THEN
    enemy(e).status = mimrocksit
    enemy(e).actiontime = maxfps
  END IF
END SELECT

'--- Do collision detection with player ---
IF EnemyTouchPlayer(e) AND enemy(e).status <> mimrocksit THEN KillPlayer

END SUB

SUB MimrockFrames (e)

'58 - sitting                  62 - jump right
'59 - sneak left (4 frames)    63 - onhead left (2 frames)
'60 - sneak right (4 frames)   64 - onhead right (2 frames)
'61 - jump left                65 - dead

SELECT CASE enemy(e).status
 CASE mimrocksit: framedataslot = 58: anmframe = 0
 CASE mimrocksneak
  IF enemy(e).xdir = left THEN framedataslot = 59 ELSE framedataslot = 60
  anmframe = (anmcounter \ 1) MOD 4
 CASE mimrockjump
  IF enemy(e).xdir = left THEN framedataslot = 61 ELSE framedataslot = 62
  anmframe = 0
 CASE mimrockonhead
  IF enemy(e).xdir = left THEN framedataslot = 63 ELSE framedataslot = 64
  anmframe = (anmcounter \ 4) MOD 2
 CASE dead: framedataslot = 65: anmframe = 0
END SELECT

enemy(e).frame = eframe(framedataslot) + anmframe
enemy(e).txsize = efsize(framedataslot).x
enemy(e).tysize = efsize(framedataslot).y

END SUB

SUB ShooterAI (e)

'====[ Handle action timer ]====
IF enemy(e).actiontime THEN enemy(e).actiontime = enemy(e).actiontime - 1

'====[ Handle status ]====
IF enemy(e).actiontime = 0 THEN
  enemy(e).actiontime = maxfps * 2
  SELECT CASE enemy(e).id
   CASE shooterup: SpawnEnemyShot e, up, arrowup
   CASE shooterdown: SpawnEnemyShot e, down, arrowdown
   CASE shooterleft: SpawnEnemyShot e, left, arrowleft
   CASE shooterright: SpawnEnemyShot e, right, arrowright
  END SELECT
END IF

'--- Do collision detection with player ---
IF EnemyTouchPlayer(e) THEN KillPlayer

END SUB

SUB ShooterFrames (e)

framedataslot = 54 + (enemy(e).id - shooterup)

enemy(e).frame = eframe(framedataslot)
enemy(e).txsize = efsize(framedataslot).x
enemy(e).tysize = efsize(framedataslot).y

END SUB

SUB SnakeAI (e)

'--- Don't handle if dead ---
IF enemy(e).status = dead THEN EXIT SUB

'--- Handle action timer ---
IF enemy(e).actiontime THEN enemy(e).actiontime = enemy(e).actiontime - 1

'====[ Handle status ]====
SELECT CASE enemy(e).status
 CASE snakemove
  IF enemy(e).xdir = left THEN
    enemy(e).xv = enemy(e).xv - (enemy(e).xmax / 2)
   ELSE
    enemy(e).xv = enemy(e).xv + (enemy(e).xmax / 2)
  END IF

  '--- Walls And Holes ---
  changedir = 0
  IF enemy(e).xdir = left THEN mx = INT(((enemy(e).x - enemy(e).xsize / 2) - 8) / ts) + 1
  IF enemy(e).xdir = right THEN mx = INT(((enemy(e).x + enemy(e).xsize / 2) + 8) / ts) + 1
  '- wall or map edge -
  my = INT(enemy(e).y / ts) + 1
  IF TileType(Map&(mx, my)) = 1 OR mx > MapWidth * ts OR mx < 1 THEN changedir = 1
  '- big hole -
  my = INT((enemy(e).y + (enemy(e).ysize / 2)) / ts) + 2
  IF TileType(Map&(mx, my)) = 0 AND TileType(MapFG&(mx, my)) = 0 THEN changedir = 1
  '- reverse direction -
  IF changedir THEN
    IF enemy(e).xdir = left THEN
      enemy(e).xdir = right
      enemy(e).xv = (enemy(e).xmax / 4)
     ELSE
      enemy(e).xdir = left
      enemy(e).xv = -(enemy(e).xmax / 4)
    END IF
  END IF
  
  '--- Randomly Peek For Player ---
  IF INT(RND * 150) = 1 THEN                         'snake looks up to find
    enemy(e).status = snakepeek                      ' player
    enemy(e).action = enemy(e).xdir
    enemy(e).actiontime = maxfps
  END IF

  '--- Attack Player ---
  IF ABS(player(0).x - enemy(e).x) < 36 AND enemy(e).y - player(0).y < 12 THEN
    IF (enemy(e).xdir = left AND player(0).x < enemy(e).x) OR (enemy(e).xdir = right AND player(0).x > enemy(e).x) THEN
      IF player(0).action <> dying THEN
        enemy(e).status = snakeattack
        enemy(e).action = 0
        enemy(e).actiontime = maxfps / 10
      END IF
    END IF
  END IF
 CASE snakepeek
  IF enemy(e).actiontime = 0 THEN
    IF enemy(e).xdir = enemy(e).action THEN         ' -- first peek --
      IF enemy(e).xdir = left THEN
        IF player(0).x < enemy(e).x THEN
          enemy(e).status = snakemove               ' found player to left
          enemy(e).action = 0
         ELSE                                       ' not left, look right
          enemy(e).xdir = right
          enemy(e).actiontime = maxfps
        END IF
       ELSE
        IF player(0).x > enemy(e).x THEN            ' found player to right
          enemy(e).status = snakemove
          enemy(e).action = 0
         ELSE                                       ' not right, look left
          enemy(e).xdir = left
          enemy(e).actiontime = maxfps
        END IF
      END IF
     ELSE                                           ' -- second peek --
      enemy(e).status = snakemove
      enemy(e).action = 0
    END IF
  END IF
 CASE snakeattack
  IF enemy(e).actiontime = 0 THEN
    SELECT CASE enemy(e).action
     CASE 0
      enemy(e).action = 1
      enemy(e).actiontime = maxfps / 8
     CASE 1
      enemy(e).action = 2
      enemy(e).actiontime = maxfps / 3
      enemy(e).xsize = efsize(38).x
     CASE 2
      enemy(e).action = 3
      enemy(e).actiontime = maxfps / 8
      enemy(e).xsize = 16
     CASE 3
      enemy(e).status = snakemove: enemy(e).action = 0
    END SELECT
  END IF
END SELECT

'--- Kill Player ---
IF EnemyTouchPlayer(e) THEN
  IF enemy(e).status = snakeattack AND enemy(e).action = 2 THEN
    IF (enemy(e).xdir = left AND player(0).x < enemy(e).x) OR (enemy(e).xdir = right AND player(0).x > enemy(e).x) THEN KillPlayer
  END IF
END IF

END SUB

SUB SnakeFrames (e)

SELECT CASE enemy(e).status
 CASE snakemove
  framedataslot = 34
 CASE snakepeek
  IF enemy(e).xdir = left THEN framedataslot = 35 ELSE framedataslot = 36
  IF enemy(e).actiontime < (maxfps * 2) / 3 AND enemy(e).actiontime > maxfps / 3 THEN addframe = 1
 CASE snakeattack
  IF enemy(e).action = 2 THEN
    IF enemy(e).xdir = left THEN framedataslot = 38 ELSE framedataslot = 40
   ELSEIF enemy(e).action = 3 THEN
    IF enemy(e).xdir = left THEN framedataslot = 37 ELSE framedataslot = 39
    addframe = 1
   ELSE
    IF enemy(e).xdir = left THEN framedataslot = 37 ELSE framedataslot = 39
    addframe = enemy(e).action
  END IF
 CASE dead
  framedataslot = 41
END SELECT

enemy(e).frame = eframe(framedataslot) + addframe
enemy(e).txsize = efsize(framedataslot).x
enemy(e).tysize = efsize(framedataslot).y

END SUB

SUB SpearAI (e)

'====[ Handle action timer ]====
IF enemy(e).actiontime THEN enemy(e).actiontime = enemy(e).actiontime - 1

'====[ Handle status ]====
IF enemy(e).actiontime = 0 THEN
  IF enemy(e).status = spearsit THEN
    enemy(e).status = spearattack
    enemy(e).action = 0
    enemy(e).actiontime = maxfps / 8
   ELSEIF enemy(e).status = spearattack THEN
    enemy(e).action = enemy(e).action + 1
    enemy(e).actiontime = maxfps / 8
    SELECT CASE enemy(e).action
     CASE 0 ' no changes
     CASE 1
      SELECT CASE enemy(e).id
       CASE spearup TO speardown: enemy(e).ysize = 48
       CASE spearleft TO spearright: enemy(e).xsize = 48
      END SELECT
     CASE 2
      SELECT CASE enemy(e).id
       CASE spearup TO speardown: enemy(e).ysize = 16
       CASE spearleft TO spearright: enemy(e).xsize = 16
      END SELECT
     CASE 3
      enemy(e).status = spearsit
      enemy(e).action = 0
      enemy(e).actiontime = maxfps * 2
    END SELECT
  END IF
END IF

'--- Do collision detection with player ---
IF EnemyTouchPlayer(e) AND enemy(e).status = spearattack THEN KillPlayer

END SUB

SUB SpearFrames (e)

framedataslot = 46 + ((enemy(e).id - spearup) * 2) + enemy(e).status
IF enemy(e).action = 2 THEN addframe = 0 ELSE addframe = enemy(e).action

enemy(e).frame = eframe(framedataslot) + addframe
enemy(e).txsize = efsize(framedataslot).x
enemy(e).tysize = efsize(framedataslot).y

END SUB

SUB WormAI (e)

'--- Direction to chase player ---
IF player(0).x > enemy(e).x THEN enemy(e).xdir = right ELSE enemy(e).xdir = left

'--- Handle action timer ---
IF enemy(e).actiontime THEN enemy(e).actiontime = enemy(e).actiontime - 1

 '--- Change direction ---
IF enemy(e).xdir = left THEN mx = INT(((enemy(e).x - enemy(e).xsize / 2) - 4) / ts) + 1
IF enemy(e).xdir = right THEN mx = INT(((enemy(e).x + enemy(e).xsize / 2) + 4) / ts) + 1
'-- wall or map edge --
my = INT(enemy(e).y / ts) + 1
IF TileType(Map&(mx, my)) = 1 OR mx > MapWidth * ts OR mx < 0 THEN
  IF enemy(e).xdir = left THEN enemy(e).xdir = right ELSE enemy(e).xdir = left
END IF
'-- big hole --
my = INT(enemy(e).y / ts) + 2
ReverseOnHole e, mx, my

'--- Crawling ---
IF enemy(e).actiontime <= 0 THEN
  IF enemy(e).status = wormcrawl1 THEN
    IF enemy(e).xdir = left THEN enemy(e).xv = -enemy(e).xmax ELSE enemy(e).xv = enemy(e).xmax
    enemy(e).status = wormcrawl2: enemy(e).actiontime = maxfps / 2
   ELSEIF enemy(e).status = wormcrawl2 THEN
    enemy(e).status = wormcrawl1: enemy(e).actiontime = maxfps / 2
  END IF
END IF

END SUB

SUB WormFrames (e)

IF enemy(e).xdir = left THEN
  framedataslot = 32
 ELSE framedataslot = 33
END IF
IF enemy(e).status = wormcrawl1 THEN addframe = 0 ELSE addframe = 1

enemy(e).frame = eframe(framedataslot) + addframe
enemy(e).txsize = efsize(framedataslot).x
enemy(e).tysize = efsize(framedataslot).y

END SUB


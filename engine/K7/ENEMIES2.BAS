DEFINT A-Z
'$INCLUDE: 'engine.bi'
'$INCLUDE: 'enemies.bi'
'$INCLUDE: 'enemies2.bi'
DECLARE SUB KillPlayer ()
DECLARE SUB SpawnEnemyShot (e, d, st)
DECLARE FUNCTION Map& (x, y)
DECLARE FUNCTION MapFG& (x, y)
DECLARE FUNCTION MapWidth ()
DECLARE FUNCTION TileType (t&)
'$STATIC
'============================================================================
CONST slug = 1, bounder = 2, mushroom = 3, lick = 4      ' enemy id constants
CONST arachnut = 5, worm = 6, snake = 7, ancient = 8     '
CONST spearup = 9, speardown = 10, spearleft = 11        '
CONST spearright = 12, shooterup = 13, shooterdown = 14  '
CONST shooterleft = 15, shooterright = 16                '

CONST dead = 10                                    ' enemy global constants
CONST dying = 3                                    ' player constants
CONST wormcrawl1 = 0, wormcrawl2 = 1                     ' worm constants
CONST snakemove = 0, snakepeek = 1, snakeattack = 2      ' snake constants
CONST walking = 0, brooding = 1                          ' ancient constants
CONST ancientwalk1 = 0, ancientwalk2 = 1                 '
CONST ancientbrood = 2                                   '
CONST spearsit = 0, spearattack = 1                      ' spear constants
CONST shooterwait = 0                                    ' shooter constants

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
IF EnemyTouchPlayer(e) THEN
  player(0).ancientsrescued = player(0).ancientsrescued + 1
  SetLevelComplete
END IF

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
  IF TileType(Map&(mx, my)) = 1 OR mx > MapWidth * ts OR mx < 0 THEN changedir = 1
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
      enemy(e).actiontime = maxfps / 10
     CASE 1
      enemy(e).action = 2
      enemy(e).actiontime = maxfps / 3
      enemy(e).xsize = efsize(38).x
     CASE 2
      enemy(e).action = 3
      enemy(e).actiontime = maxfps / 10
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


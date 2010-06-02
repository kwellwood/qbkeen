DEFINT A-Z
'$INCLUDE: 'engine.bi'
'$INCLUDE: 'enemies.bi'
'$INCLUDE: 'enemies1.bi'
DECLARE SUB KillPlayer ()
DECLARE SUB PlaySound (slot)
DECLARE FUNCTION AddSprite (x, y, frame&, eframe&, delay, xsize, ysize, deadly, repeat)
DECLARE FUNCTION Map& (x, y)
DECLARE FUNCTION MapFG& (x, y)
DECLARE FUNCTION MapWidth ()
DECLARE FUNCTION TileType (t&)
'$STATIC
'============================================================================
'--------[ Player(0).action values ]--------
CONST lookup = 4, lookdown = 5
CONST moving = 0, shooting = 1, switching = 2, dying = 3, teleporting = 4
CONST climbing = 5, pogo = 6, hanging = 7, hangclimb = 8
CONST idle = 9
'-------------------------------------------

CONST slug = 1, bounder = 2, mushroom = 3, lick = 4      ' enemy id constants
CONST arachnut = 5, worm = 6, snake = 7, ancient = 8     '
CONST spearup = 9, speardown = 10, spearleft = 11        '
CONST spearright = 12                                    '

CONST dead = 10                                          ' global constants
CONST bouncelo = 1, bouncehi = 2                         ' mushroom constants
CONST crawling = 0                                       ' slug constants
CONST slugcrawl1 = 0, slugcrawl2 = 1, slugpooping = 2    '
CONST bounceup = 0, bouncefollow = 1                     ' bounder constants
CONST sitonground = 0, attacking = 2 'bouncefollow = 1   ' lick constants
CONST firesmall = 1, firemed = 2, firebig = 3            '
CONST stunned = 1, waking = 2                            ' arachnut constants

ON ERROR GOTO ErrorHandler
'============================================================================
ErrorHandler:
e = ERR
ErrorHandlerSub e
RESUME NEXT

SUB ArachnutAI (e)

'--- Don't handle if dead ---
IF enemy(e).status = dead THEN EXIT SUB

'--- decrease timer ---
IF enemy(e).actiontime THEN enemy(e).actiontime = enemy(e).actiontime - 1

'====[ Handle status ]====
SELECT CASE enemy(e).status
 CASE crawling
  IF enemy(e).xdir = left THEN
    enemy(e).xv = enemy(e).xv - (enemy(e).xmax / 2)
   ELSE
    enemy(e).xv = enemy(e).xv + (enemy(e).xmax / 2)
  END IF

  '--- Change direction ---
  changedir = 0
  IF enemy(e).xdir = left THEN mx = INT(((enemy(e).x - enemy(e).xsize / 2) - 8) / ts) + 1
  IF enemy(e).xdir = right THEN mx = INT(((enemy(e).x + enemy(e).xsize / 2) + 8) / ts) + 1
  '-- random change --
  IF INT(RND * 150) = 1 THEN changedir = 1
  '-- wall or map edge --
  my = INT(enemy(e).y / ts) + 1
  IF TileType(Map&(mx, my)) = 1 OR mx > MapWidth * ts OR mx < 0 THEN changedir = 1
  '-- big hole --
  my = INT((enemy(e).y + (enemy(e).ysize / 2)) / ts) + 2
  IF TileType(Map&(mx, my)) = 0 AND TileType(MapFG&(mx, my)) = 0 THEN changedir = 1
  '-- actually change it --
  IF changedir THEN
    IF enemy(e).xdir = left THEN
      enemy(e).xdir = right
      enemy(e).xv = (enemy(e).xmax / 4)
     ELSE
      enemy(e).xdir = left
      enemy(e).xv = -(enemy(e).xmax / 4)
    END IF
  END IF
 CASE stunned
  IF enemy(e).actiontime = 0 THEN                    '4 is the animation
    enemy(e).actiontime = INT((maxfps * 2) / 4) * 4  '  delay so set this
    enemy(e).status = waking                         '  as a multiple of 4
  END IF
 CASE waking
  IF enemy(e).actiontime = 0 THEN
    enemy(e).status = crawling
  END IF
END SELECT

'--- Do collision detection with player ---
IF enemy(e).status = crawling AND EnemyTouchPlayer(e) THEN KillPlayer

END SUB

SUB ArachnutFrames (e)

SELECT CASE enemy(e).status
 CASE crawling
  IF enemy(e).xdir = left THEN
    framedataslot = 30
    addframe = 3 - anmcounter MOD 4
   ELSE
    framedataslot = 30
    addframe = anmcounter MOD 4
  END IF
 CASE waking
  framedataslot = 30 + INT(enemy(e).actiontime / 8) MOD 2
  addframe = 0
 CASE stunned
  framedataslot = 31: addframe = 0
END SELECT

enemy(e).frame = eframe(framedataslot) + addframe
enemy(e).txsize = efsize(framedataslot).x
enemy(e).tysize = efsize(framedataslot).y

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

FUNCTION BounderTouchPlayer

px1! = player(0).x: py1! = player(0).y + (player(0).ysize / 2)

FOR k = 1 TO LEN(activefoestack)
  e = ASC(MID$(activefoestack, k, 1))
  IF enemy(e).id = bounder THEN
    ex1! = enemy(e).x - (enemy(e).txsize / 2): ey1! = enemy(e).y - (enemy(e).tysize / 2)
    ex2! = enemy(e).x + (enemy(e).txsize / 2): ey2! = enemy(e).y - 1
    IF px1! >= ex1! AND px1! <= ex2! AND py1! >= ey1! AND py1! <= ey2! THEN BounderTouchPlayer = e: EXIT FUNCTION
  END IF
NEXT k

BounderTouchPlayer = 0

END FUNCTION

SUB LickAI (e)

'if sitonground
'  if actiontime = 0 then choose new action
'    if decided to attack, status = attack
'    if decided to bounce
'      status = bounce
'      move player up
'
'if bouncefollow
'  if in the air then move
'  if on the ground reset to sitonground
'
'if attacking

'--- dont handle if dead ---
IF enemy(e).status = dead THEN EXIT SUB

'--- direction to chase player ---
IF player(0).x > enemy(e).x THEN edir = right ELSE edir = left

'--- decrease timer ---
IF enemy(e).actiontime THEN enemy(e).actiontime = enemy(e).actiontime - 1

'--- movement ---
SELECT CASE enemy(e).status
 CASE sitonground
  IF enemy(e).action = 0 THEN
    IF EnemyInRange(e, 24) AND player(0).action <> dying THEN
      IF enemy(e).x < player(0).x THEN enemy(e).xdir = right ELSE enemy(e).xdir = left
      enemy(e).status = attacking
      enemy(e).action = firesmall
      enemy(e).actiontime = 6
      enemy(e).xsize = 26
     ELSE
      IF enemy(e).x < player(0).x THEN enemy(e).xdir = right ELSE enemy(e).xdir = left
      enemy(e).status = bouncefollow
      IF EnemyInRange(e, 36) THEN
        enemy(e).actiontime = 3
       ELSE enemy(e).actiontime = 5
      END IF
    END IF
   ELSE
    enemy(e).action = enemy(e).action - 1  ' decrement ticks to sit
  END IF
 CASE bouncefollow
  IF enemy(e).actiontime THEN enemy(e).yv = enemy(e).yv - 2
  IF enemy(e).onground = 0 THEN
    SELECT CASE enemy(e).xdir
     CASE left: enemy(e).xv = enemy(e).xv - 2
     CASE right: enemy(e).xv = enemy(e).xv + 2
    END SELECT
   ELSEIF enemy(e).onground AND enemy(e).actiontime = 0 THEN
    enemy(e).status = sitonground
    enemy(e).action = 3   ' sit on the ground 3 ticks
    enemy(e).xv = 0       ' dont slide on ground
  END IF
 CASE attacking
  SELECT CASE enemy(e).action
   CASE firesmall
    IF enemy(e).actiontime THEN
      IF EnemyTouchPlayer(e) THEN KillPlayer
     ELSE
      enemy(e).action = firemed
      enemy(e).actiontime = 6
      enemy(e).xsize = 38
    END IF
   CASE firemed
    IF enemy(e).actiontime THEN
      IF EnemyTouchPlayer(e) THEN KillPlayer
     ELSE
      enemy(e).action = firebig
      enemy(e).actiontime = 6
      enemy(e).xsize = 40
    END IF
   CASE firebig
    IF enemy(e).actiontime THEN
      IF EnemyTouchPlayer(e) THEN KillPlayer
     ELSE
      enemy(e).status = sitonground
      enemy(e).action = 3
      enemy(e).xsize = 22
      IF enemy(e).xdir = left THEN    ' kick back from the flames,
        enemy(e).x = enemy(e).x + 9   '   hope this doesnt get him
       ELSE                           '   stuck in a wall
        enemy(e).x = enemy(e).x - 9   '
      END IF                          '
    END IF
  END SELECT
END SELECT

END SUB

SUB LickFrames (e)

SELECT CASE enemy(e).status
 CASE attacking
  IF enemy(e).xdir = left THEN
    framedataslot = 24 + (enemy(e).action - 1)
   ELSE
    framedataslot = 27 + (enemy(e).action - 1)
  END IF
  addframe = 0
 CASE dead
  framedataslot = 23: addframe = 0
 CASE ELSE
  IF enemy(e).onground THEN
    IF enemy(e).xdir = left THEN framedataslot = 21 ELSE framedataslot = 22
    IF enemy(e).action THEN addframe = 3 ELSE addframe = 0
   ELSE
    IF enemy(e).xdir = left THEN framedataslot = 21 ELSE framedataslot = 22
    IF enemy(e).yv <= 0 THEN addframe = 1 ELSE addframe = 2
  END IF
END SELECT

enemy(e).frame = eframe(framedataslot) + addframe
enemy(e).txsize = efsize(framedataslot).x
enemy(e).tysize = efsize(framedataslot).y

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

'--- Don't handle if dead ---
IF enemy(e).status = dead THEN EXIT SUB

'====[ Handle action timer ]====
IF enemy(e).actiontime THEN enemy(e).actiontime = enemy(e).actiontime - 1
'--- reset to crawling ---
IF enemy(e).status = slugpooping AND enemy(e).actiontime <= 0 THEN
  enemy(e).status = crawling: enemy(e).action = slugcrawl1
END IF

'====[ Handle status ]====
IF enemy(e).status = crawling THEN
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
  IF INT(RND * 150) = 1 THEN
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
    a = AddSprite(x, y, eframe(8), eframe(9), maxfps * 2, efsize(8).x, efsize(8).y, 1, 0)
  END IF
END IF

'--- Do collision detection with player ---
IF EnemyTouchPlayer(e) THEN KillPlayer

END SUB

SUB SlugFrames (e)

SELECT CASE enemy(e).action
 CASE slugcrawl1
  IF enemy(e).xdir = left THEN framedataslot = 0 ELSE framedataslot = 3
 CASE slugcrawl2
  IF enemy(e).xdir = left THEN framedataslot = 1 ELSE framedataslot = 4
 CASE slugpooping
  IF enemy(e).xdir = left THEN framedataslot = 2 ELSE framedataslot = 5
END SELECT

IF enemy(e).status = dead THEN framedataslot = 7

enemy(e).frame = eframe(framedataslot)
enemy(e).txsize = efsize(framedataslot).x
enemy(e).tysize = efsize(framedataslot).y

END SUB


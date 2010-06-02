DEFINT A-Z
'$INCLUDE: 'engine.bi'
'$INCLUDE: 'enemies.bi'
'$INCLUDE: 'enemies2.bi'
DECLARE FUNCTION Map& (x, y)
DECLARE FUNCTION MapFG& (x, y)
DECLARE FUNCTION MapWidth ()
DECLARE FUNCTION TileType (t&)
'$STATIC
'============================================================================
CONST dead = 10                                          ' global constants
CONST wormcrawl1 = 0, wormcrawl2 = 1                     ' worm constants

ON ERROR GOTO ErrorHandler
'============================================================================
ErrorHandler:
e = ERR
ErrorHandlerSub e
RESUME NEXT

SUB WormAI (e)

'--- Direction to chase player ---
IF player(0).x > enemy(e).x THEN enemy(e).xdir = right ELSE enemy(e).xdir = left

'--- Handle action timer ---
IF enemy(e).actiontime THEN enemy(e).actiontime = enemy(e).actiontime - 1

 '--- Change direction ---
IF enemy(e).xdir = left THEN mx = INT(((enemy(e).x - enemy(e).xsize / 2) - 6) / ts) + 1
IF enemy(e).xdir = right THEN mx = INT(((enemy(e).x + enemy(e).xsize / 2) + 6) / ts) + 1
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
'--- Direction to chase player ---
IF player(0).x > enemy(e).x THEN enemy(e).xdir = right ELSE enemy(e).xdir = left

'--- Handle action timer ---
IF enemy(e).actiontime THEN enemy(e).actiontime = enemy(e).actiontime - 1

 '--- Change direction ---
IF enemy(e).xdir = left THEN mx = INT(((enemy(e).x - enemy(e).xsize / 2) - 6) / ts) + 1
IF enemy(e).xdir = right THEN mx = INT(((enemy(e).x + enemy(e).xsize / 2) + 6) / ts) + 1
'-- wall or map edge --
my = INT(enemy(e).y / ts) + 1
IF TileType(Map&(mx, my)) = 1 OR mx > MapWidth * ts OR mx < 0 THEN
  IF enemy(e).xdir = left THEN enemy(e).xdir = right ELSE enemy(e).xdir = left
END IF
'-- big hole --
my = INT(enemy(e).y / ts) + 2
IF TileType(Map&(mx, my)) = 0 AND TileType(MapFG&(mx, my)) = 0 THEN
  IF enemy(e).xdir = left THEN enemy(e).xdir = right ELSE enemy(e).xdir = left
END IF

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


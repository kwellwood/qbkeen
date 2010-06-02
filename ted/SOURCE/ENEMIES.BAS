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
ErrorHandlerSub 0
RESUME NEXT

REM $STATIC
SUB DeleteEnemy (x, y)

FOR k = 1 TO LEN(activefoestack(0))
  IF k > LEN(activefoestack(0)) THEN EXIT FOR
  e = ASC(MID$(activefoestack(0), k, 1))

  ex1 = enemy(e).x - (efsize(enemy(e).id).x / 2)
  ex2 = enemy(e).x + (efsize(enemy(e).id).x / 2)
  ey1 = enemy(e).y - (efsize(enemy(e).id).y / 2)
  ey2 = enemy(e).y + (efsize(enemy(e).id).y / 2)
  IF x >= ex1 AND x <= ex2 AND y >= ey1 AND y <= ey2 THEN
    activefoestack(0) = LEFT$(activefoestack(0), k - 1) + RIGHT$(activefoestack(0), LEN(activefoestack(0)) - k)
    unusedfoestack(0) = unusedfoestack(0) + CHR$(e)
    k = k - 1
  END IF
NEXT k

END SUB

SUB DrawEnemies

FOR k = 1 TO LEN(activefoestack(0))
  e = ASC(MID$(activefoestack(0), k, 1))

  IF (enemy(e).x + (efsize(enemy(e).id).x / 2)) / (ts / zoom) >= camera(0).vx1 AND (enemy(e).x - (efsize(enemy(e).id).x / 2)) / (ts / zoom) <= camera(0).vx2 THEN
    IF (enemy(e).y + (efsize(enemy(e).id).y / 2)) / (ts / zoom) >= camera(0).vy1 AND (enemy(e).y - (efsize(enemy(e).id).y / 2)) / (ts / zoom) <= camera(0).vy2 THEN
      x = (enemy(e).x / (ts / zoom)) - camera(0).vx1 - ((efsize(enemy(e).id).x / 2) / (ts / zoom))
      y = (enemy(e).y / (ts / zoom)) - camera(0).vy1 - ((efsize(enemy(e).id).y / 2) / (ts / zoom))

      frame& = eframe(enemy(e).id)
      xsize = efsize(enemy(e).id).x / (ts / zoom)
      ysize = efsize(enemy(e).id).y / (ts / zoom)
      IF zoom < ts THEN PutSpriteS frame&, x, y, xsize, ysize, drawpage ELSE PutSprite frame&, x, y, drawpage
    END IF
  END IF
NEXT k

END SUB

SUB GroundEnemy (e)
                                                    
mx = INT(enemy(e).x / ts) + 1
eysize = efsize(enemy(e).id).y
my = INT((enemy(e).y + (eysize / 2)) / ts) + 1

DO
  my = my + 1
LOOP WHILE TileType(Map&(mx, my)) = 0 AND TileType(MapFG&(mx, my)) = 0 AND my <= mapysize
IF my > mapysize THEN EXIT SUB

my = my - 1
enemy(e).y = (my * ts - 1) - (efsize(enemy(e).id).y / 2)

END SUB

SUB InitEnemies

OPEN "tedenemy.dat" FOR INPUT AS 1
  FOR e = 1 TO numenemytypes
    INPUT #1, eframe(e)
    INPUT #1, efsize(e).x
    INPUT #1, efsize(e).y
  NEXT e
CLOSE 1

cenemy = 0
activefoestack(0) = ""
unusedfoestack(0) = ""

END SUB

SUB SpawnEnemy (x, y, id)

IF LEN(unusedfoestack(0)) > 0 THEN
  e = ASC(LEFT$(unusedfoestack(0), 1))
  unusedfoestack(0) = RIGHT$(unusedfoestack(0), LEN(unusedfoestack(0)) - 1)
  activefoestack(0) = activefoestack(0) + CHR$(e)
  enemy(e).id = id
  enemy(e).x = x: enemy(e).y = y
   
  SELECT CASE id
   CASE slug: GroundEnemy e
   CASE lick: GroundEnemy e
   CASE arachnut: GroundEnemy e
   CASE worm: GroundEnemy e
   CASE snake: GroundEnemy e
   CASE ancient: GroundEnemy e
   CASE mimrock: GroundEnemy e
  END SELECT
END IF

END SUB


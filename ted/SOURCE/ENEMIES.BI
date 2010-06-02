DEFINT A-Z
'$DYNAMIC

CONST slug = 1, ball = 2, mushroom = 3, lick = 4, arachnut = 5, worm = 6
CONST snake = 7, ancient = 8, spearup = 9, speardown = 10, spearleft = 11
CONST spearright = 12, shooterup = 13, shooterdown = 14, shooterleft = 15
CONST shooterright = 16, mimrock = 17, cloud = 18
CONST numenemytypes = 18

COMMON SHARED cenemy

DECLARE SUB DeleteEnemy (x, y)
DECLARE SUB DrawEnemies ()
DECLARE SUB GroundEnemy (e)
DECLARE SUB InitEnemies ()
DECLARE SUB SpawnEnemy (x, y, id)

TYPE enemytype
  id AS INTEGER
  x AS SINGLE
  y AS SINGLE
  xv AS SINGLE
  vy AS SINGLE
  xdir AS INTEGER
  onground AS INTEGER
  action AS INTEGER
  actiontime AS INTEGER
  frame AS LONG
  xsize AS INTEGER
  ysize AS INTEGER
  txsize AS INTEGER
  tysize AS INTEGER
  status AS INTEGER
  statustime AS INTEGER
END TYPE

COMMON SHARED enemy() AS enemytype, eframe() AS LONG, efsize() AS intcoordinate
COMMON SHARED activefoestack() AS STRING, unusedfoestack() AS STRING


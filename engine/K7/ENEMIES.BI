DEFINT A-Z
'$DYNAMIC

CONST slug = 1, ball = 2
CONST crawling = 0
CONST slugcrawl1 = 0, slugcrawl2 = 1, slugpooping = 2, dead = 10

DECLARE SUB AssignEnemyFrame (e)
DECLARE SUB DoEnemyFrame (e)
DECLARE SUB DrawEnemies ()
DECLARE SUB EnemyAI (e)
DECLARE SUB EnemyHitWall (e, p, hx!, hy!) 'point hit, clippoint hit (x, y)
DECLARE SUB EnemyOnGround (e)
DECLARE SUB EnemyPhysics (e)
DECLARE SUB HandleEnemies ()
DECLARE SUB InitEnemies ()
DECLARE SUB KillEnemy (e)
DECLARE SUB SlugAI (e)
DECLARE SUB SlugFrames (e)
DECLARE FUNCTION EnemyHitPoint (x!, y!)

TYPE enemytype
  id AS INTEGER
  x AS SINGLE
  y AS SINGLE
  xv AS SINGLE
  yv AS SINGLE
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
  xmax AS INTEGER
  ymax AS INTEGER
END TYPE

COMMON SHARED enemy() AS enemytype, eframe() AS LONG, efsize() AS intcoordinate
COMMON SHARED activefoestack() AS STRING


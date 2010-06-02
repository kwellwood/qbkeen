DEFINT A-Z
'$DYNAMIC

CONST maxenemyframes = 68

DECLARE SUB DrawEnemies ()
DECLARE SUB HandleEnemies ()
DECLARE SUB InitEnemies ()
DECLARE SUB KillEnemy (e)
DECLARE SUB LoadEnemies (f)
DECLARE SUB LoadEnemiesFromFile (f)
DECLARE SUB ReverseOnHole (e, mx, my)
DECLARE SUB SetEnemyFriction (f!)
DECLARE SUB SetEnemyGravity (g!)
DECLARE SUB WriteEnemiesToFile (f)
DECLARE FUNCTION ActiveEnemies ()
DECLARE FUNCTION EnemyInRange (e, range)
DECLARE FUNCTION EnemyInRangeY (e, range)
DECLARE FUNCTION EnemyInRangeOfX (e, range1, range2)
DECLARE FUNCTION EnemyShootable (e)
DECLARE FUNCTION EnemyTouchPlayer (e)
DECLARE FUNCTION ShotEnemy (sx1, sy1, sx2, sy2)


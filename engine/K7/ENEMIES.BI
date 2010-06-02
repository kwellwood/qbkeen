DEFINT A-Z
'$DYNAMIC

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
DECLARE FUNCTION EnemyShootable (id)
DECLARE FUNCTION EnemyTouchPlayer (e)
DECLARE FUNCTION ShotEnemy (sx1, sy1, sx2, sy2)


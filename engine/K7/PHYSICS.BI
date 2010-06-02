DEFINT A-Z
'$DYNAMIC

DECLARE SUB CheckJumpHeight ()
DECLARE SUB CheckOnGround ()
DECLARE SUB DoPhysics ()
DECLARE SUB DoPlayerFrame ()
DECLARE SUB HitWall (p, hx!, hy!)
DECLARE SUB MovePlayer (d)
DECLARE SUB UpdateClipPoints ()
DECLARE FUNCTION HitPoint (p)

COMMON SHARED ClipPoint() AS coordinate


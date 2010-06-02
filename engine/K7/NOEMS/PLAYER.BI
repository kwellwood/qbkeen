DEFINT A-Z
'$DYNAMIC

COMMON SHARED friction!, gravity!

DECLARE SUB CheckJumpHeight ()
DECLARE SUB CheckOnGround ()
DECLARE SUB ClipPlayerToMap ()
DECLARE SUB DoPhysics ()
DECLARE SUB DoPlayerFrame ()
DECLARE SUB DyingFrames ()
DECLARE SUB HandlePogoStick ()
DECLARE SUB HitSlope (x!, y!, l)
DECLARE SUB HitWall (p, hx!, hy!)
DECLARE SUB KillPlayer ()
DECLARE SUB MovingFrames ()
DECLARE SUB MovePlayer (D)
DECLARE SUB PlayerState ()
DECLARE SUB PogoFrames ()
DECLARE SUB TogglePogo ()
DECLARE SUB UpdateClipPoints ()
DECLARE FUNCTION HitPoint (p)

COMMON SHARED ClipPoint() AS coordinate


DEFINT A-Z
'$DYNAMIC

CONST lookup = 4, lookdown = 5
CONST moving = 0, shooting = 1, switching = 2, dying = 3, teleporting = 4
CONST climbing = 5, pogo = 6, hanging = 7, hangclimb = 8
CONST idle = 9

DECLARE SUB CheckJumpHeight ()
DECLARE SUB ClipPlayerToMap ()
DECLARE SUB DoPhysics ()
DECLARE SUB DoPlayerFrame ()
DECLARE SUB DoPlayerOnBall ()
DECLARE SUB DoPlayerState ()
DECLARE SUB DrawPlayer ()
DECLARE SUB DyingFrames ()
DECLARE SUB HandlePogoStick ()
DECLARE SUB HitSlope (x!, y!, l)
DECLARE SUB HitWall (p, hx!, hy!)
DECLARE SUB IdleFrames ()
DECLARE SUB InitPlayer ()
DECLARE SUB InitPlayerState ()
DECLARE SUB KillPlayer ()
DECLARE SUB MovingFrames ()
DECLARE SUB MovePlayer (D)
DECLARE SUB PogoFrames ()
DECLARE SUB SetPlayerFriction (f!)
DECLARE SUB SetPlayerGravity (g!)
DECLARE SUB ShiftPlayer (x!, y!)
DECLARE SUB TogglePogo ()
DECLARE SUB UpdateClipPoints ()
DECLARE FUNCTION PFrameSizeX (slot)
DECLARE FUNCTION PFrameSizeY (slot)
DECLARE FUNCTION PlayerFrame& (slot)


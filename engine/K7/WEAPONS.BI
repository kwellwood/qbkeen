DEFINT A-Z
'$DYNAMIC

'Different types of shooting positions
CONST groundleft = 1, groundright = 2, groundup = 3
CONST airleft = 4, airright = 5, airup = 6, airdown = 7
CONST poleleft = 8, poleleftup = 9, poleleftdown = 10, poleright = 11
CONST polerightup = 12, polerightdown = 13

DECLARE SUB ClearShots ()
DECLARE SUB DoShots ()
DECLARE SUB DrawShots ()
DECLARE SUB InitWeapons ()
DECLARE SUB LoadShotsFromFile (f)
DECLARE SUB SetShootingFrame ()
DECLARE SUB ShootingFrames ()
DECLARE SUB SpawnEnemyShot (e, d, st)
DECLARE SUB SpawnPlayerShot ()
DECLARE SUB WriteShotsToFile (f)
DECLARE FUNCTION ActiveShots ()
DECLARE FUNCTION ShotActive (s)


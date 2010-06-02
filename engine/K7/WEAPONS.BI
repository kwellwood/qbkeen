DEFINT A-Z
'$DYNAMIC

COMMON SHARED shotsframe&, shoteframe&, shotframedelay, shotxsize, shotysize
COMMON SHARED shotexpsframe&, shotexpeframe&, shotexpframedelay, shotexpxsize
COMMON SHARED shotexpysize, shotvelocity

'Different types of shooting positions
CONST groundleft = 1, groundright = 2, groundup = 3, airleft = 4, airright = 5
CONST airup = 6, airdown = 7, poleleft = 8, poleleftup = 9, poleleftdown = 10
CONST poleright = 11, polerightup = 12, polerightdown = 13

DECLARE SUB DoShots ()
DECLARE SUB DrawShots ()
DECLARE SUB InitWeapons ()
DECLARE SUB KillShot (s)
DECLARE SUB SetShootingFrame ()
DECLARE SUB ShootingFrames ()
DECLARE SUB SpawnPlayerShot ()
DECLARE FUNCTION ShotCollide (s)
DECLARE FUNCTION ShotEnemy (s)
DECLARE FUNCTION ShotInRange (s, range)

TYPE shottype
 x AS SINGLE
 y AS SINGLE
 xv AS SINGLE
 yv AS SINGLE
 frame AS LONG
 sframe AS LONG
 eframe AS LONG
 delay AS INTEGER
 active AS INTEGER
END TYPE

COMMON SHARED shot() AS shottype


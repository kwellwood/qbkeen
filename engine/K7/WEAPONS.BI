DEFINT A-Z
'$DYNAMIC

COMMON SHARED shotsframe&, shoteframe&, shotframedelay, shotxsize, shotysize
COMMON SHARED shotexpsframe&, shotexpeframe&, shotexpframedelay, shotexpxsize
COMMON SHARED shotexpysize, shotvelocity

CONST groundleft = 1, groundright = 2, groundup = 3, airleft = 4, airright = 5
CONST airup = 6, airdown = 7, poleleft = 8, poleright = 9, poleup = 10
CONST poledown = 11

DECLARE SUB DoShots ()
DECLARE SUB DrawShots ()
DECLARE SUB InitWeapons ()
DECLARE SUB KillShot (s)
DECLARE SUB SetShootingFrame ()
DECLARE SUB ShootingFrames ()
DECLARE SUB SpawnPlayerShot ()
DECLARE FUNCTION ShotCollide (s)
DECLARE FUNCTION ShotEnemy (s)

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


DEFINT A-Z
'$DYNAMIC

COMMON SHARED shotsframe&, shoteframe&, shotframedelay, shotxsize, shotysize
COMMON SHARED shotexpsframe&, shotexpeframe&, shotexpframedelay, shotexpxsize
COMMON SHARED shotexpysize, shotvelocity

DECLARE SUB DoShots ()
DECLARE SUB DrawShots ()
DECLARE SUB InitWeapons ()
DECLARE SUB KillShot (s)
DECLARE SUB SetShootingFrame ()
DECLARE SUB ShootingFrames ()
DECLARE SUB SpawnPlayerShot ()
DECLARE FUNCTION ShotCollide (s)

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


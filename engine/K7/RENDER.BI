DEFINT A-Z
'$DYNAMIC

COMMON SHARED backgroundused

DECLARE SUB DoCamera ()
DECLARE SUB DrawHUD ()
DECLARE SUB DrawScreen ()

TYPE camtype
 x AS INTEGER
 y AS INTEGER
 vx1 AS INTEGER
 vy1 AS INTEGER
 vx2 AS INTEGER
 vy2 AS INTEGER
END TYPE

COMMON SHARED camera() AS camtype


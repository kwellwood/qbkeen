DEFINT A-Z
'$DYNAMIC

COMMON SHARED backgroundused, DisplayHud

DECLARE SUB DoCamera ()
DECLARE SUB DrawHUD ()
DECLARE SUB DrawMarkerBox (x, y, xsize, ysize, c)
DECLARE SUB DrawScreen ()
DECLARE FUNCTION OnScreen (x, y, xsize, ysize)
DECLARE FUNCTION OnScreen2 (x1, y1, x2, y2)

TYPE camtype
 x AS INTEGER
 y AS INTEGER
 vx1 AS INTEGER
 vy1 AS INTEGER
 vx2 AS INTEGER
 vy2 AS INTEGER
END TYPE

COMMON SHARED camera() AS camtype


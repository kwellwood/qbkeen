DEFINT A-Z
'$DYNAMIC

CONST mapsysver = 1

COMMON SHARED MapHandle, MapFGHandle
COMMON SHARED mapxsize, mapysize

DECLARE SUB LoadMap (file$)
DECLARE FUNCTION Map& (x, y)
DECLARE FUNCTION MapFG& (x, y)


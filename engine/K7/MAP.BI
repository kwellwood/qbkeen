DEFINT A-Z
'$DYNAMIC

CONST mapsysver = 3

COMMON SHARED MapHandle, MapFGHandle
COMMON SHARED mapxsize, mapysize

DECLARE SUB LoadMap (file$)
DECLARE SUB SetMap (x, y, t&)
DECLARE SUB SetMapFG (x, y, t&)
DECLARE FUNCTION Map& (x, y)
DECLARE FUNCTION MapFG& (x, y)


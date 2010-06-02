DEFINT A-Z
'$DYNAMIC

CONST mapsysver = 3

COMMON SHARED MapHandle, MapFGHandle
COMMON SHARED mapxsize, mapysize, bgfile$

DECLARE SUB DrawTile (x, y, t&)
DECLARE SUB LoadMap (file$)
DECLARE SUB NewMap ()
DECLARE SUB ReplaceTile (t1&, t2&)
DECLARE SUB SaveMap (file$)
DECLARE SUB SetMap (x, y, t&)
DECLARE SUB SetMapFG (x, y, t&)
DECLARE FUNCTION Map& (x, y)
DECLARE FUNCTION MapFG& (x, y)


DEFINT A-Z
'$DYNAMIC

DECLARE SUB AddChangingTile (x, y)
DECLARE SUB ClearChangingTiles ()
DECLARE SUB LoadMap (file$)
DECLARE SUB MapCloseXMS ()
DECLARE SUB MapGetXMS ()
DECLARE SUB SetMap (x, y, t&)
DECLARE SUB SetMapFG (x, y, t&)
DECLARE SUB UpdateChangingTiles ()
DECLARE FUNCTION Map& (x, y)
DECLARE FUNCTION MapFG& (x, y)
DECLARE FUNCTION MapHeight ()
DECLARE FUNCTION MapWidth ()
DECLARE FUNCTION NumChangingTiles ()


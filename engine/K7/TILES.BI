DEFINT A-Z
'$DYNAMIC

COMMON SHARED TileTypeHandle, AnmLengthHandle, AnmDelayHandle
COMMON SHARED numtiles&

DECLARE SUB LoadTiles ()
DECLARE SUB SetTileType (t&, v)
DECLARE SUB SetAnmLength (t&, l)
DECLARE SUB SetAnmDelay (t&, d)
DECLARE SUB SetSlopeMask (t&, m&)

DECLARE FUNCTION TileType (t&)
DECLARE FUNCTION AnmLength (t&)
DECLARE FUNCTION AnmDelay (t&)
DECLARE FUNCTION SlopeMask& (t&)


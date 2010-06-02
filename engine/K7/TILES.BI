DEFINT A-Z
'$DYNAMIC

'==TILE TYPES==
'0=passive
'1=wall
'2=slope
'3=hazzard
'4=switch

COMMON SHARED TileTypeHandle, AnmLengthHandle, AnmDelayHandle
COMMON SHARED numtiles&, tileset$

DECLARE SUB LoadTiles ()
DECLARE SUB SetTileType (t&, v)
DECLARE SUB SetAnmLength (t&, l)
DECLARE SUB SetAnmDelay (t&, d)
DECLARE SUB SetSlopeMask (t&, m&)

DECLARE FUNCTION TileType (t&)
DECLARE FUNCTION AnmLength (t&)
DECLARE FUNCTION AnmDelay (t&)
DECLARE FUNCTION SlopeMask& (t&)


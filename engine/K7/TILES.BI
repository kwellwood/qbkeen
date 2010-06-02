DEFINT A-Z
'$DYNAMIC

'==TILE TYPES==
'0=passive
'1=wall
'2=slope
'3=hazzard
'4=switch
'5=pole/ladder
'8=reserved(slope in fg)
'9=special: wall in foreground (passive if in background)

'==TILE TAG 2==
'0=no tag
'1=draw as overlay on bg

COMMON SHARED TileTypeHandle, TileType2Handle, AnmLengthHandle, AnmDelayHandle
COMMON SHARED numtiles&, tileset$

DECLARE SUB LoadTiles ()
DECLARE SUB SetTileType (t&, v)
DECLARE SUB SetTileType2 (t&, v)
DECLARE SUB SetAnmLength (t&, l)
DECLARE SUB SetAnmDelay (t&, d)
DECLARE SUB SetSlopeMask (t&, m&)

DECLARE FUNCTION TileType (t&)
DECLARE FUNCTION TileType2 (t&)
DECLARE FUNCTION AnmLength (t&)
DECLARE FUNCTION AnmDelay (t&)
DECLARE FUNCTION SlopeHeight (x, y, l)
DECLARE FUNCTION SlopeMask& (t&)


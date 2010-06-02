DEFINT A-Z
'$DYNAMIC

COMMON SHARED TileTypeHandle, TileType2Handle, AnmLengthHandle, AnmDelayHandle
COMMON SHARED SlopeMaskHandle
COMMON SHARED numtiles&, tileset$

DECLARE SUB LoadTiles ()
DECLARE SUB SetTileType (t&, v)
DECLARE SUB SetTileType2 (t&, v)
DECLARE SUB SetAnmLength (t&, l)
DECLARE SUB SetAnmDelay (t&, d)
DECLARE SUB SetSlopeMask (t&, m&)

DECLARE FUNCTION TileDescrip$ (typ)
DECLARE FUNCTION TileDescrip2$ (typ)
DECLARE FUNCTION TileType (t&)
DECLARE FUNCTION TileType2 (t&)
DECLARE FUNCTION AnmLength (t&)
DECLARE FUNCTION AnmDelay (t&)
DECLARE FUNCTION SlopeMask& (t&)


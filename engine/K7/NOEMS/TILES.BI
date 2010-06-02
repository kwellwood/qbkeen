DEFINT A-Z
'$DYNAMIC

'==TILE TAG 1==
'00=passive
'01=wall
'02=slope
'03=hazzard
'04=switch
'05=pole/ladder
'08=[RESERVED]- foreground slope
'09=special:
'  wall if in foreground (passive if in background)
'10=[RESERVED]- end level

'==TILE TAG 2==
'00=no tag
'01=draw as overlay on bg
'10=end level, do not draw

COMMON SHARED TileTypeHandle, TileType2Handle, AnmLengthHandle, AnmDelayHandle
COMMON SHARED SlopeMaskHandle
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


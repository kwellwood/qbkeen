DEFINT A-Z
'$DYNAMIC
'       == TILE TAG 1 ==
'Background           Foreground
'00=passive           00=passive
'01=wall              01=null
'02=slope             02=slope
'03=hazzard           03=null
'04=switch            04=null
'05=pole/ladder       05=pole/ladder
'06=null              06=null
'07=null              07=empty gem socket
'08=[reserved]        08=[reserved]
'09=null              09=wall
'11=null              11=change tile +1

'==TILE TAG 2==
'00=no tag
'01=draw as overlay on bg
'10=end level, do not draw

'Slope Types:
'-------------------------------
'01 - /.    05 - /.1    09 - \'1
'02 - .\    06 - /.2    10 - \'2
'03 - \'    07 - .\1    11 - '/1
'04 - '/    08 - .\2    12 - '/2

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


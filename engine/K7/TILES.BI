DEFINT A-Z
'$DYNAMIC

'       == TILE TAG 1 ==
'Background           Foreground
'00=passive           00=passive
'01=wall              01=null
'02=slope             02=slope
'03=hazzard           03=hazzard
'04=switch            04=null
'05=pole/ladder       05=pole/ladder
'06=oneway floor      06=oneway floor
'07=null              07=empty gem socket
'08=[reserved]        08=[reserved]
'09=null              09=wall
'13=water in mapmode  13=null

'==TILE TAG 2==
'00=no tag
'01=draw as overlay on bg
'10=end level, do not draw
'11=end level with scuba gear
'12=enter level from map
'14=change to tile+x after a delay
'15=change to tile-x after a delay

'Slope Types:
'-------------------------------
'01 - /.    05 - /.1    09 - \'1
'02 - .\    06 - /.2    10 - \'2
'03 - \'    07 - .\1    11 - '/1
'04 - '/    08 - .\2    12 - '/2

DECLARE SUB EntityOnGround (onground, onslope, onobject, x!, y!, yv!, ysize)
DECLARE SUB LoadArtFile (t&, f$)
DECLARE SUB LoadTiles (tileset$)
DECLARE SUB PutSprite (t&, x, y, p)
DECLARE SUB PutTile (t&, x, y, p)
DECLARE SUB SetTileType (t&, v)
DECLARE SUB SetTileType2 (t&, v)
DECLARE SUB SetAnmLength (t&, l)
DECLARE SUB SetAnmDelay (t&, d)
DECLARE SUB SetSlopeMask (t&, m&)
DECLARE SUB TilesCloseXMS ()
DECLARE SUB TilesGetXMS ()
DECLARE FUNCTION AnmLength (t&)
DECLARE FUNCTION AnmDelay (t&)
DECLARE FUNCTION HitPoint (x!, y!)
DECLARE FUNCTION SlopeHeight (x, y, l)
DECLARE FUNCTION SlopeMask& (t&)
DECLARE FUNCTION TileType (t&)
DECLARE FUNCTION TileType2 (t&)


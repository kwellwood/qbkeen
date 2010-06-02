DEFINT A-Z
'$DYNAMIC

'$INCLUDE: 'engine.bi'
'$INCLUDE: 'directqb.bi'
'$INCLUDE: 'xms.bi'
'$INCLUDE: 'paklib.bi'
'$INCLUDE: 'plugins.bi'

ON ERROR GOTO ErrorHandler

'============================================================================
ErrorHandler:
e = ERR
ErrorHandlerSub e
RESUME NEXT

REM $STATIC
FUNCTION AnmDelay (t&)

BiosXRead AnmDelayHandle, t& * 2 - 2, 2, VARSEG(biti(0)), VARPTR(biti(0))
AnmDelay = biti(0)

END FUNCTION

FUNCTION AnmLength (t&)

BiosXRead AnmLengthHandle, t& * 2 - 2, 2, VARSEG(biti(0)), VARPTR(biti(0))
AnmLength = biti(0)

END FUNCTION

SUB LoadTiles

xmspos& = 0
OPEN tileset$ FOR INPUT AS 1
  INPUT #1, gfxarchive$
  a = MountPAK(gfxarchive$)
  IF a THEN ErrorHandlerSub 132 + a
 
  INPUT #1, numtiles&
  FOR t& = 1 TO numtiles&
    INPUT #1, file$
    LoadArtFile t&, file$

    INPUT #1, tileprop
    IF tileprop <> 99 THEN INPUT #1, tileprop2 ELSE tileprop2 = 0
   
    SetTileType t&, tileprop
    SetTileType2 t&, tileprop2
    SELECT CASE tileprop
     CASE 2
      INPUT #1, sm&: SetSlopeMask t&, sm&
      INPUT #1, af: ad = 0  'get af to check for being overlay too
     CASE 99
      af = 0: ad = 0
     CASE ELSE
      INPUT #1, af
      IF af > 0 THEN INPUT #1, ad ELSE ad = 0
    END SELECT
    SetAnmLength t&, af
    SetAnmDelay t&, ad
  NEXT t&
CLOSE 1

END SUB

SUB SetAnmDelay (t&, d)

biti(0) = d
BiosXWrite AnmDelayHandle, t& * 2 - 2, 2, VARSEG(biti(0)), VARPTR(biti(0))

END SUB

SUB SetAnmLength (t&, l)

biti(0) = l
BiosXWrite AnmLengthHandle, t& * 2 - 2, 2, VARSEG(biti(0)), VARPTR(biti(0))

END SUB

SUB SetSlopeMask (t&, m&)

bitl(0) = m&
BiosXWrite SlopeMaskHandle, t& * 4 - 4, 4, VARSEG(bitl(0)), VARPTR(bitl(0))

END SUB

SUB SetTileType (t&, v)

biti(0) = v
BiosXWrite TileTypeHandle, t& * 2 - 2, 2, VARSEG(biti(0)), VARPTR(biti(0))

END SUB

SUB SetTileType2 (t&, v)

biti(0) = v
BiosXWrite TileType2Handle, t& * 2 - 2, 2, VARSEG(biti(0)), VARPTR(biti(0))

END SUB

FUNCTION SlopeHeight (x, y, l)

mapx = INT(x / ts) + 1: mapy = INT(y / ts) + 1
SELECT CASE l
 CASE 0: tile& = Map&(mapx, mapy)
 CASE 1: tile& = MapFG&(mapx, mapy)
END SELECT

PutTile SlopeMask&(tile&), 0, 0, slopepage
SlopeHeight = DQBpoint(slopepage, x - ((mapx - 1) * ts), y - ((mapy - 1) * ts))

END FUNCTION

FUNCTION SlopeMask& (t&)

BiosXRead SlopeMaskHandle, t& * 4 - 4, 4, VARSEG(bitl(0)), VARPTR(bitl(0))
SlopeMask& = bitl(0)

END FUNCTION

FUNCTION TileType (t&)

biti(0) = 0
BiosXRead TileTypeHandle, t& * 2 - 2, 2, VARSEG(biti(0)), VARPTR(biti(0))
TileType = biti(0)

END FUNCTION

FUNCTION TileType2 (t&)

biti(0) = 5
BiosXRead TileType2Handle, t& * 2 - 2, 2, VARSEG(biti(0)), VARPTR(biti(0))
TileType2 = biti(0)

END FUNCTION


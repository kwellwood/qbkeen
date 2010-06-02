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
    '---[ Load artwork ]---
    INPUT #1, file$
    LoadArtFile t&, file$

    '---[ Handle tile properties ]---
    INPUT #1, tileprop
    IF tileprop <> 99 THEN INPUT #1, tileprop2 ELSE tileprop2 = 0
    SetTileType t&, tileprop
    SetTileType2 t&, tileprop2
    SetSlopeMask t&, 0
    SELECT CASE tileprop
     '--- slope tile ---
     CASE 2
      INPUT #1, sm&: SetSlopeMask t&, sm&     'sm&=slope type
      INPUT #1, af: ad = 0                    'af=overlay tag for slope tiles
     '--- nul tile ---
     CASE 99
      af = 0: ad = 0                          'nul tiles not animated
     '--- any other tile ---
     CASE ELSE
      INPUT #1, af                            'if animation length,
      IF af > 0 THEN INPUT #1, ad ELSE ad = 0 ' get animation delay too
    END SELECT
    SetAnmLength t&, af                       'set anm length tag
    SetAnmDelay t&, ad                        'set anm delay tag
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

'Slope Types:
'-------------------------------
'01 - /.    05 - /.1    09 - \'1
'02 - .\    06 - /.2    10 - \'2
'03 - \'    07 - .\1    11 - '/1
'04 - '/    08 - .\2    12 - '/2

tx = INT(x / ts) + 1             'get tile coordinates
ty = INT(y / ts) + 1             '

SELECT CASE l                    'get tile number
 CASE 0: tile& = Map&(tx, ty)    ' from background
 CASE 1: tile& = MapFG&(tx, ty)  ' from foreground
END SELECT
stype = SlopeMask&(tile&)        'get tile slope type

px = (tx - 1) * ts               'upper left corner
py = (ty - 1) * ts               ' of tile in pixels
sx = x - px                      'difference between x,y and
sy = y - py                      ' upper left of tile in pixels

SELECT CASE stype
 CASE 1: IF sx > ts - sy - 1 THEN hit = (ts - sy - 1) - sx
 CASE 2: IF sx < sy THEN hit = sx - sy
 CASE 3: IF sx > sy THEN hit = sx - sy
 CASE 4: IF sx < ts - sy THEN hit = (ts - sy - 1) - sx
 CASE 5: IF sx > (ts - sy - 1) * 2 THEN hit = FIX((ts - sy - 1) - sx / 2)
 CASE 6: IF sx > (ts - sy - 1) * 2 - ts THEN hit = FIX((ts - sy - 1) - ts / 2 - sx / 2)
 CASE 7: IF sx < sy * 2 - ts THEN hit = (ts - sy - 1) - FIX((ts - sx) / 2 - .5)
 CASE 8: IF sx < sy * 2 THEN hit = (ts - sy - 1) - FIX((ts - sx) / 2 - .5) - ts / 2
 CASE 9: IF sx > sy * 2 + 1 THEN hit = 1
 CASE 10: IF sx > sy * 2 - (ts - 1) THEN hit = 1
 CASE 11: IF sx < ts - (sy * 2) - 2 THEN hit = 1
 CASE 12: IF sx < ts - (sy * 2) + (ts - 2) THEN hit = 1
END SELECT
SlopeHeight = hit

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

biti(0) = 0
BiosXRead TileType2Handle, t& * 2 - 2, 2, VARSEG(biti(0)), VARPTR(biti(0))
TileType2 = biti(0)

END FUNCTION


DEFINT A-Z
'$INCLUDE: 'engine.bi'
'$INCLUDE: 'directqb.bi'
'$INCLUDE: 'xms.bi'
'$INCLUDE: 'paklib.bi'
'$INCLUDE: 'map.bi'
'$INCLUDE: 'tiles.bi'
DECLARE FUNCTION CEIL (x!)
'$STATIC

ON ERROR GOTO ErrorHandler

DIM SHARED ArtHandle, ArtOffSetHandle, ArtLengthHandle
DIM SHARED xmspos&
DIM SHARED TileTypeHandle, TileType2Handle, AnmLengthHandle, AnmDelayHandle
DIM SHARED SlopeMaskHandle
DIM SHARED numtiles&
DIM SHARED biti(0) AS INTEGER, bitl(0) AS LONG
'============================================================================
ErrorHandler:
e = ERR
ErrorHandlerSub e
RESUME NEXT

REM $DYNAMIC
FUNCTION AnmDelay (t&)

BiosXRead AnmDelayHandle, t& * 2 - 2, 2, VARSEG(biti(0)), VARPTR(biti(0))
AnmDelay = biti(0)

END FUNCTION

FUNCTION AnmLength (t&)

BiosXRead AnmLengthHandle, t& * 2 - 2, 2, VARSEG(biti(0)), VARPTR(biti(0))
AnmLength = biti(0)

END FUNCTION

REM $STATIC
FUNCTION CEIL (x!)

CEIL = FIX(x!) - (x! - FIX(x!) > 0)

END FUNCTION

SUB EntityOnGround (onground, onslope, onobject, x!, y!, yv!, ysize)

'--- already standing on an object ---
IF onobject THEN
  global(0).onground = 1
  global(0).onslope = 0
  global(0).y = y!
  global(0).yv = yv!
  EXIT SUB
END IF

'--- previous ground values ---
oldonslope = onslope
oldonground = onground
'--- map location of player's feet ---
mapx = INT(x! / ts) + 1
mapy = INT((y! + (ysize / 2)) / ts) + 1

'=========================[ CHECK FOR GROUND TILE ]==========================
IF yv! >= 0 THEN
  mapx = INT(x! / ts) + 1: mapy = INT((y! + (ysize / 2)) / ts) + 1
  IF INT((y! + (ysize / 2)) MOD ts) >= ts - 1 THEN
    mapx = INT(x! / ts) + 1: mapy = INT((y! + (ysize / 2)) / ts) + 2
    IF TileType(Map&(mapx, mapy)) = 1 OR TileType(MapFG&(mapx, mapy)) = 9 OR TileType(MapFG&(mapx, mapy)) = 6 THEN
      onground = 1
      onslope = 0
      IF INT((y! + (ysize / 2)) MOD ts) < ts - 1 THEN y! = INT(y!) + 1
     ELSE
      onground = 0
      onslope = 0
    END IF
   ELSE
    onground = 0
    onslope = 0
  END IF
 ELSE
  onground = 0
  onslope = 0
END IF

'===========================[ CHECK FOR SLOPES ]=============================
IF TileType(Map&(mapx, mapy)) = 2 OR TileType(MapFG&(mapx, mapy)) = 2 THEN
  IF TileType(Map&(mapx, mapy)) = 2 THEN l = 0 ELSE l = 1
  tmpx = x!: tmpy = y! + (ysize / 2)
  h1 = SlopeHeight(tmpx, tmpy, l)
  h2 = SlopeHeight(tmpx, tmpy + 1, l)
  IF h1 = 0 AND h2 < 0 THEN
    onground = 1: onslope = 1
   ELSE
    onground = 0: onslope = 0
  END IF
END IF

'========================[ KEEP PLAYER ON A SLOPE ]==========================
IF onground = 0 AND oldonground = 1 AND yv! >= 0 THEN
  mapx = INT(x! / ts) + 1
  mapy = INT((y! + (ysize / 2)) / ts) + 1
  IF TileType(Map&(mapx, mapy)) = 2 OR TileType(MapFG&(mapx, mapy)) = 2 THEN
    sticktoslope = 1
   ELSEIF TileType(Map&(mapx, mapy + 1)) = 2 OR TileType(MapFG&(mapx, mapy + 1)) = 2 THEN
    sticktoslope = 1: mapy = mapy + 1
    y! = y! + (ts - ((y! + (ysize / 2) + ts) MOD ts))
   ELSEIF TileType(Map&(mapx, mapy + 1)) = 1 OR TileType(MapFG&(mapx, mapy + 1)) = 9 THEN
    y! = y! + (ts - (y! + (ysize / 2) + ts) MOD ts) - 1
    yv! = 0
    onground = 1
  END IF
  IF sticktoslope THEN
    IF TileType(Map&(mapx, mapy)) = 2 THEN l = 0 ELSE l = 1
    y! = y! + (ts - (y! + (ysize / 2) + 1) MOD ts) - 1
    tmpx = INT(x!): tmpy = INT(y! + (ysize / 2) + 1)
    y! = y! + SlopeHeight(tmpx, tmpy, l)
    yv! = 0
    onground = 1: onslope = 1
  END IF
END IF

'========================[ RETURN CHANGED VARIABLES ]=========================
global(0).onground = onground
global(0).onslope = onslope
global(0).y = y!
global(0).yv = yv!

END SUB

FUNCTION HitPoint (x!, y!)

'fg =Foreground Tag 1
'fg2=Foreground Tag 2
'bg =Background Tag 1

'--- get tile coordinates ---
mx = INT(x! / ts) + 1
my = INT(y! / ts) + 1

mapfgtile& = MapFG&(mx, my)
maptile& = Map&(mx, my)
fg = TileType(mapfgtile&)
fg2 = TileType2(mapfgtile&)
bg = TileType(maptile&)

IF fg2 = 10 THEN HitPoint = 10: EXIT FUNCTION   ' exit level tile
IF fg2 = 13 THEN HitPoint = 13: EXIT FUNCTION   ' get scuba gear tile

SELECT CASE fg
 CASE 2: HitPoint = 8: EXIT FUNCTION     ' slope in foreground
 CASE 3: HitPoint = 3: EXIT FUNCTION     ' hazzard in foreground
 CASE 6: HitPoint = 6: EXIT FUNCTION     ' oneway floor
 CASE 7: HitPoint = 7: EXIT FUNCTION     ' gem socket
 CASE 9: HitPoint = 1: EXIT FUNCTION     ' wall in foreground
END SELECT
HitPoint = bg

END FUNCTION

REM $DYNAMIC
SUB LoadArtFile (t&, f$)

IF f$ = "NO_FILE" THEN
  '--- spaceholder tile ---
  filesize& = 4
 ELSE
  '--- load from mounted pak ---
  a = LoadFromPAK(f$, VARSEG(scr(0)), 0)
  IF a THEN debuglog "File(" + LTRIM$(STR$(t&)) + ") not found: `" + f$ + "'": ErrorHandlerSub 134 + a
  filesize& = PAKFileSize(f$)
END IF

'--- write to xms ---
BiosXWrite ArtHandle, xmspos&, filesize&, VARSEG(scr(0)), VARPTR(scr(0))
bitl(0) = xmspos&: BiosXWrite ArtOffSetHandle, t& * 4 - 4, 4, VARSEG(bitl(0)), VARPTR(bitl(0))
bitl(0) = filesize&: BiosXWrite ArtLengthHandle, t& * 4 - 4, 4, VARSEG(bitl(0)), VARPTR(bitl(0))

'- increment current write offset in xms -
xmspos& = xmspos& + filesize&

END SUB

REM $STATIC
SUB LoadTiles (tileset$)

bary = CSRLIN: barx = POS(0) + 1

e = InitPAKLib: IF e THEN ErrorHandlerSub 104

xmspos& = 0
OPEN tileset$ FOR INPUT AS 1
  INPUT #1, gfxarchive$
  a = MountPAK(gfxarchive$)
  IF a THEN ErrorHandlerSub 132 + a

  INPUT #1, numtiles&
  ' --- Show status bar ---
  'PRINT "[" + SPACE$(INT(numtiles& / 100)) + "]";
  PRINT "[" + SPACE$(16) + "]";
  loadchunk = numtiles& \ 16

  LOCATE bary, barx
  FOR t& = 1 TO numtiles&
    '---[ Load artwork ]---
    DO
      INPUT #1, file$
    LOOP UNTIL LEFT$(file$, 1) <> "*"
    file$ = UCASE$(file$)
   
    LoadArtFile t&, file$
    '---[ Handle tile properties ]---
    IF file$ = "NO_FILE" THEN
      SetTileType t&, 100
      SetTileType2 t&, 0
      SetSlopeMask t&, 0
      SetAnmLength t&, 0
      SetAnmDelay t&, 0
     ELSE
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
       '--- gem socket ---
       CASE 7
        INPUT #1, sm&: SetSlopeMask t&, sm&     'sm&=key color
        INPUT #1, af                            'if animation length,
        IF af > 0 THEN INPUT #1, ad ELSE ad = 0 ' get animation delay too
       '--- not-a-tile ---
       CASE 99                              'these tiles not animated
        af = 0: ad = 0                      '(menu screen or character frame)
       '--- any other tile ---
       CASE ELSE
        IF tileprop2 = 14 THEN                 'these change into other tiles
          INPUT #1, nt&: SetSlopeMask t&, nt&  'sm& = tile to change to
          INPUT #1, af: ad = 0                 'af=delay before change
         ELSE
          INPUT #1, af                            'if animation length,
          IF af > 0 THEN INPUT #1, ad ELSE ad = 0 ' get animation delay too
        END IF
      END SELECT
      SetAnmLength t&, af                       'set anm length tag
      SetAnmDelay t&, ad                        'set anm delay tag
    END IF

    '--- Update status bar ---
    'IF t& / 100 = FIX(t& / 100) THEN
    IF t& / loadchunk = FIX(t& / loadchunk) THEN
      COLOR 10, 0
      PRINT MID$("COMMANDER KEEN 7", t& / (numtiles& \ 16), 1);
      'PRINT "*";
      COLOR 7, 0
    END IF

  NEXT t&
CLOSE 1

ClosePAKLib
PRINT ""

END SUB

REM $DYNAMIC
SUB PutSprite (t&, x, y, p)

BiosXRead ArtOffSetHandle, t& * 4 - 4, 4, VARSEG(bitl(0)), VARPTR(bitl(0)): xmspos& = bitl(0)
BiosXRead ArtLengthHandle, t& * 4 - 4, 4, VARSEG(bitl(0)), VARPTR(bitl(0)): tlength& = bitl(0)
BiosXRead ArtHandle, xmspos&, tlength&, VARSEG(scr(0)), VARPTR(scr(0))

DQBsetTransPut
DQBput p, x, y, VARSEG(scr(0)), VARPTR(scr(0))

END SUB

SUB PutTile (t&, x, y, p)

BiosXRead ArtOffSetHandle, t& * 4 - 4, 4, VARSEG(bitl(0)), VARPTR(bitl(0)): xmspos& = bitl(0)
BiosXRead ArtLengthHandle, t& * 4 - 4, 4, VARSEG(bitl(0)), VARPTR(bitl(0)): tlength& = bitl(0)
BiosXRead ArtHandle, xmspos&, tlength&, VARSEG(scr(0)), VARPTR(scr(0))

DQBsetSolidPut
DQBput p, x, y, VARSEG(scr(0)), VARPTR(scr(0))

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

SUB TilesCloseXMS

BiosXClose TileTypeHandle
BiosXClose TileType2Handle
BiosXClose AnmLengthHandle
BiosXClose AnmDelayHandle
BiosXClose SlopeMaskHandle

BiosXClose ArtHandle
BiosXClose ArtOffSetHandle
BiosXClose ArtLengthHandle

END SUB

SUB TilesGetXMS

BiosXOpen 16, TileTypeHandle, a     ' INTEGER elements
IF a THEN ErrorHandlerSub 105
BiosXOpen 16, AnmLengthHandle, a
IF a THEN ErrorHandlerSub 106
BiosXOpen 16, AnmDelayHandle, a
IF a THEN ErrorHandlerSub 107
BiosXOpen 16, TileType2Handle, a
IF a THEN ErrorHandlerSub 114
BiosXOpen 16, SlopeMaskHandle, a
IF a THEN ErrorHandlerSub 115

BiosXOpen 4096, ArtHandle, a
IF a THEN ErrorHandlerSub 108

BiosXOpen 16, ArtOffSetHandle, a    ' LONG elements
IF a THEN ErrorHandlerSub 109
BiosXOpen 16, ArtLengthHandle, a
IF a THEN ErrorHandlerSub 110

END SUB

FUNCTION TileType (t&)

biti(0) = 0   ' default tile type
BiosXRead TileTypeHandle, t& * 2 - 2, 2, VARSEG(biti(0)), VARPTR(biti(0))
TileType = biti(0)

END FUNCTION

FUNCTION TileType2 (t&)

biti(0) = 0    ' default tile type
BiosXRead TileType2Handle, t& * 2 - 2, 2, VARSEG(biti(0)), VARPTR(biti(0))
TileType2 = biti(0)

END FUNCTION


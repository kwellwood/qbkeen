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
ErrorHandlerSub 0
RESUME NEXT

REM $STATIC
FUNCTION AnmDelay (t&)

IF t& = 0 THEN AnmDelay = 0: EXIT FUNCTION

BiosXRead AnmDelayHandle, t& * 2 - 2, 2, VARSEG(biti(0)), VARPTR(biti(0))
AnmDelay = biti(0)

END FUNCTION

FUNCTION AnmLength (t&)

IF t& = 0 THEN AnmLength = 0: EXIT FUNCTION

BiosXRead AnmLengthHandle, t& * 2 - 2, 2, VARSEG(biti(0)), VARPTR(biti(0))
AnmLength = biti(0)

END FUNCTION

SUB LoadTiles

xmspos& = 0
OPEN tileset$ FOR INPUT AS 1
  INPUT #1, gfxarchive$
  a = MountPAK(gfxarchive$)
  IF a THEN ErrorHandlerSub 0
 
  INPUT #1, numtiles&
  FOR t& = 1 TO numtiles&
    DO                                    ' skip comment lines starting
      INPUT #1, file$                     ' with an asterisk
    LOOP UNTIL LEFT$(file$, 1) <> "*"     '
    file$ = UCASE$(file$)

    LoadArtFile t&, file$

    IF file$ = "NO_FILE" THEN
      SetTileType t&, 100
      SetTileType2 t&, 0
      af = 0     ' animation length
     ELSE
      INPUT #1, tileprop
      IF tileprop <> 99 THEN INPUT #1, tileprop2 ELSE tileprop2 = 0
   
      SetTileType t&, tileprop
      SetTileType2 t&, tileprop2
      SELECT CASE tileprop
       CASE 2
        INPUT #1, sm&': SetSlopeMask t&, sm&
        'SetAnmLength t&, 0
        INPUT #1, af: ad = 0  'get af to check for being overlayed too. if af
       CASE 7                 '  then must it be -1 because slopes cant animate
        INPUT #1, sm&': SetSlopeMask t&, sm&
        INPUT #1, af
        IF af > 0 THEN INPUT #1, ad ELSE ad = 0
       CASE 99
       af = 0: ad = 0
       CASE ELSE
        IF tileprop2 = 14 THEN                   ' changing tiles
          INPUT #1, sm&': SetSlopeMask t&, sm&   ' tile to change to
          INPUT #1, af: ad = 0                   ' pause before change
         ELSE
          INPUT #1, af
          IF af > 0 THEN INPUT #1, ad ELSE ad = 0
        END IF
      END SELECT
    END IF

    SetAnmLength t&, af
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

FUNCTION SlopeMask& (t&)

IF t& = 0 THEN SlopeMask& = 0: EXIT FUNCTION

BiosXRead SlopeMaskHandle, t& * 4 - 4, 4, VARSEG(bitl(0)), VARPTR(bitl(0))
SlopeMask& = bitl(0)

END FUNCTION

FUNCTION TileDescrip$ (typ)

TileDescrip$ = ""
SELECT CASE typ
 CASE 0: TileDescrip$ = "PAS"
 CASE 1: TileDescrip$ = "WAL"
 CASE 2: TileDescrip$ = "SLP"
 CASE 3: TileDescrip$ = "HAZ"
 CASE 4: TileDescrip$ = "SWT"
 CASE 5: TileDescrip$ = "POL"
 CASE 6: TileDescrip$ = "1WY"
 CASE 7: TileDescrip$ = "GEM"
 CASE 9: TileDescrip$ = "WAL"
 CASE 13: TileDescrip$ = "H2O"
END SELECT

END FUNCTION

FUNCTION TileDescrip2$ (typ)

TileDescrip2$ = ""
SELECT CASE typ
 CASE 1: TileDescrip2$ = "O"
 CASE 10: TileDescrip2$ = "X"
 CASE 12: TileDescrip2$ = "X"
 CASE 14: TileDescrip2$ = "C"
END SELECT

END FUNCTION

FUNCTION TileType (t&)

IF t& = 0 THEN TileType = 0: EXIT FUNCTION

biti(0) = 0
BiosXRead TileTypeHandle, t& * 2 - 2, 2, VARSEG(biti(0)), VARPTR(biti(0))
TileType = biti(0)

END FUNCTION

FUNCTION TileType2 (t&)

IF t& = 0 THEN TileType2 = 0: EXIT FUNCTION

biti(0) = 0
BiosXRead TileType2Handle, t& * 2 - 2, 2, VARSEG(biti(0)), VARPTR(biti(0))
TileType2 = biti(0)

END FUNCTION


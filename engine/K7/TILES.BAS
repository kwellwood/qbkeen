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
a = MountPAK("graphics.gpk")
IF a THEN ErrorHandlerSub 132 + a
OPEN "graphics.dat" FOR INPUT AS 1
  INPUT #1, numtiles&
  FOR t& = 1 TO numtiles&
    INPUT #1, file$
    LoadArtFile t&, file$

    INPUT #1, tileprop
    IF tileprop <> 99 THEN
      SetTileType t&, tileprop
      IF tileprop = 3 THEN
        INPUT #1, sm&: SetSlopeMask t&, sm&
        SetAnmLength t&, 0
       ELSE
        INPUT #1, af
        INPUT #1, ad
        SetAnmLength t&, af
        SetAnmDelay t&, ad
      END IF
    END IF
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
BiosXWrite SlopeMaskHandle, t& * 4 - 4, 4, VARSEG(bitl(0)), VARSEG(bitl(0))

END SUB

SUB SetTileType (t&, v)

biti(0) = v
BiosXWrite TileTypeHandle, t& * 2 - 2, 2, VARSEG(biti(0)), VARPTR(biti(0))

END SUB

FUNCTION SlopeMask& (t&)

BiosXRead SlopeMaskHandle, t& * 4 - 4, 4, VARSEG(bitl(0)), VARPTR(bitl(0))
SlopeMask& = bitl(0)

END FUNCTION

FUNCTION TileType (t&)

biti(0) = 0
BiosXRead TileTypeHandle, t& * 2 - 2, 2, VARSEG(biti(0)), VARPTR(biti(0))
TileType = biti(0)

END FUNCTION


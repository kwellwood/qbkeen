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
SUB LoadArtFile (t&, f$)

IF f$ = "NO_FILE" THEN
  fsize& = 4                ' just leave a gap, not write all data
 ELSE
  a = LoadFromPAK(f$, scrbuf)
  IF a THEN DebugLog "Tile(" + STR$(t&) + ") not found: " + f$: ErrorHandlerSub a
  fsize& = PAKFileSize(f$)
END IF

BiosXWrite ArtHandle, xmspos&, fsize&, VARSEG(scr(0)), VARPTR(scr(0))
bitl(0) = xmspos&
BiosXWrite ArtOffsetHandle, t& * 4 - 4, 4, VARSEG(bitl(0)), VARPTR(bitl(0))
bitl(0) = fsize&
BiosXWrite ArtLengthHandle, t& * 4 - 4, 4, VARSEG(bitl(0)), VARPTR(bitl(0))
xmspos& = xmspos& + fsize&

END SUB

SUB PutMask (t&, x, y, p)

BiosXRead ArtOffsetHandle, t& * 4 - 4, 4, VARSEG(bitl(0)), VARPTR(bitl(0))
xmspos& = bitl(0)

BiosXRead ArtLengthHandle, t& * 4 - 4, 4, VARSEG(bitl(0)), VARPTR(bitl(0))
tlength& = bitl(0)

BiosXRead ArtHandle, xmspos&, tlength&, VARSEG(scr(0)), VARPTR(scr(0))
DQBsetsolidput
DQBhput p, x, y, VARSEG(scr(0)), VARPTR(scr(0)), 144

END SUB

SUB PutSprite (t&, x, y, p)

BiosXRead ArtOffsetHandle, t& * 4 - 4, 4, VARSEG(bitl(0)), VARPTR(bitl(0))
xmspos& = bitl(0)

BiosXRead ArtLengthHandle, t& * 4 - 4, 4, VARSEG(bitl(0)), VARPTR(bitl(0))
tlength& = bitl(0)

BiosXRead ArtHandle, xmspos&, tlength&, VARSEG(scr(0)), VARPTR(scr(0))
DQBsettransput
DQBput p, x, y, VARSEG(scr(0)), VARPTR(scr(0))

END SUB

SUB PutSpriteS (t&, x, y, x1, y1, p)

BiosXRead ArtOffsetHandle, t& * 4 - 4, 4, VARSEG(bitl(0)), VARPTR(bitl(0))
xmspos& = bitl(0)

BiosXRead ArtLengthHandle, t& * 4 - 4, 4, VARSEG(bitl(0)), VARPTR(bitl(0))
tlength& = bitl(0)

BiosXRead ArtHandle, xmspos&, tlength&, VARSEG(scr(0)), VARPTR(scr(0))
DQBsettransput
DQBsput p, x, y, VARSEG(scr(0)), VARPTR(scr(0)), x1, y1

END SUB

SUB PutTile (t&, x, y, p)

BiosXRead ArtOffsetHandle, t& * 4 - 4, 4, VARSEG(bitl(0)), VARPTR(bitl(0))
xmspos& = bitl(0)

BiosXRead ArtLengthHandle, t& * 4 - 4, 4, VARSEG(bitl(0)), VARPTR(bitl(0))
tlength& = bitl(0)

IF tlength& = 4 THEN EXIT SUB

BiosXRead ArtHandle, xmspos&, tlength&, VARSEG(scr(0)), VARPTR(scr(0))
DQBsetsolidput
DQBput p, x, y, VARSEG(scr(0)), VARPTR(scr(0))

END SUB

SUB PutTileS (t&, x, y, x1, y1, p)

BiosXRead ArtOffsetHandle, t& * 4 - 4, 4, VARSEG(bitl(0)), VARPTR(bitl(0))
xmspos& = bitl(0)

BiosXRead ArtLengthHandle, t& * 4 - 4, 4, VARSEG(bitl(0)), VARPTR(bitl(0))
tlength& = bitl(0)

IF tlength& = 4 THEN EXIT SUB  ' this is a null tile

BiosXRead ArtHandle, xmspos&, tlength&, VARSEG(scr(0)), VARPTR(scr(0))
DQBsetsolidput
DQBsput p, x, y, VARSEG(scr(0)), VARPTR(scr(0)), x1, y1

END SUB

FUNCTION TileXSize (t&)

BiosXRead ArtOffsetHandle, t& * 4 - 4, 4, VARSEG(bitl(0)), VARPTR(bitl(0))
xmspos& = bitl(0)

BiosXRead ArtHandle, xmspos&, 2, VARSEG(biti(0)), VARPTR(biti(0))
TileXSize = biti(0) / 8

END FUNCTION

FUNCTION TileYSize (t&)

BiosXRead ArtOffsetHandle, t& * 4 - 4, 4, VARSEG(bitl(0)), VARPTR(bitl(0))
xmspos& = bitl(0)

BiosXRead ArtHandle, xmspos& + 2, 2, VARSEG(biti(0)), VARPTR(biti(0))
TileYSize = biti(0)

END FUNCTION


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

a = LoadFromPAK(f$, scrbuf)
IF a THEN ErrorHandlerSub a
fsize& = PAKFileSize(f$)
BiosXWrite ArtHandle, xmspos&, fsize&, VARSEG(scr(0)), VARPTR(scr(0))
bitl(0) = xmspos&
BiosXWrite ArtOffsetHandle, t& * 4 - 4, 4, VARSEG(bitl(0)), VARPTR(bitl(0))
bitl(0) = fsize&
BiosXWrite ArtLengthHandle, t& * 4 - 4, 4, VARSEG(bitl(0)), VARPTR(bitl(0))
xmspos& = xmspos& + fsize&

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

SUB PutTile (t&, x, y, p)

BiosXRead ArtOffsetHandle, t& * 4 - 4, 4, VARSEG(bitl(0)), VARPTR(bitl(0))
xmspos& = bitl(0)

BiosXRead ArtLengthHandle, t& * 4 - 4, 4, VARSEG(bitl(0)), VARPTR(bitl(0))
tlength& = bitl(0)

BiosXRead ArtHandle, xmspos&, tlength&, VARSEG(scr(0)), VARPTR(scr(0))
DQBsetsolidput
DQBput p, x, y, VARSEG(scr(0)), VARPTR(scr(0))

END SUB


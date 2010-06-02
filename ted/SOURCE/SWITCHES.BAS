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
SUB SetSwitchTag (x, y, sw&)

mxs& = mapxsize: x& = x: y& = y
bitl(0) = sw&
BiosXWrite SwitchTagHandle, ((y& * mxs& - mxs&) + x&) * 4& - 4&, 4, VARSEG(bitl(0)), VARPTR(bitl(0))

END SUB

FUNCTION SwitchTag& (x, y)

mxs& = mapxsize: x& = x: y& = y
BiosXRead SwitchTagHandle, ((y& * mxs& - mxs&) + x&) * 4& - 4&, 4, VARSEG(bitl(0)), VARPTR(bitl(0))
SwitchTag& = bitl(0)

END FUNCTION


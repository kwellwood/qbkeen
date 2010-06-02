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
SUB CheckSwitch

IF player(0).onground = 0 THEN EXIT SUB  ' must be standing on the ground

' get the number of the switch at this location
s = SwitchTag(INT(player(0).x / ts) + 1, INT((player(0).y - (player(0).tysize / 4)) / ts) + 1)

' no switch at this location?
IF s = 0 THEN EXIT SUB

' already flipping a switch?
IF player(0).action = switching AND player(0).actiontime THEN EXIT SUB

IF switch(s) = 0 THEN switch(s) = 1 ELSE switch(s) = 0
player(0).action = switching
player(0).actiontime = maxfps / 3
player(0).xv = 0: player(0).frozen = 1

END SUB

SUB SetSwitchTag (x, y, sw)

biti(0) = sw
BiosXWrite SwitchTagHandle, ((y * mapxsize - mapxsize) + x) * 2 - 2, 2, VARSEG(biti(0)), VARPTR(biti(0))

END SUB

SUB SwitchingFrames

player(0).frame = pframe(21)
player(0).txsize = fsize(21).x
player(0).tysize = fsize(21).y

END SUB

FUNCTION SwitchTag (x, y)

BiosXRead SwitchTagHandle, ((y * mapxsize - mapxsize) + x) * 2 - 2, 2, VARSEG(biti(0)), VARPTR(biti(0))
SwitchTag = biti(0)

END FUNCTION


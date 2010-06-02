DEFINT A-Z
'$DYNAMIC

COMMON SHARED SwitchTagHandle, flipsframe&, flipeframe&, flipframedelay

DECLARE SUB CheckSwitch ()
DECLARE SUB InitSwitches ()
DECLARE SUB SetSwitchTag (x, y, sw&)
DECLARE SUB SwitchingFrames ()
DECLARE SUB UnlockDoor ()
DECLARE FUNCTION SwitchTag& (x, y)

COMMON SHARED switch()


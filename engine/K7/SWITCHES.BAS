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

'-- must be standing on the ground --
IF player(0).onground = 0 THEN EXIT SUB

mx = INT(player(0).x / ts) + 1
my = INT((player(0).y - (player(0).tysize / 4)) / ts) + 1

'-- check for a switch-type tile --
IF TileType(Map&(mx, my)) <> 4 THEN EXIT SUB

' get the number of the switch at this location
s& = SwitchTag&(mx, my)
s2& = SwitchTag&(mx, my - 1)

' no switch tag at this location?
IF s& = 0 THEN EXIT SUB

' already flipping a switch?
IF player(0).action = switching AND player(0).actiontime THEN EXIT SUB

'--- flip the switch ---
IF switch(s&) = 0 THEN switch(s&) = 1 ELSE switch(s&) = 0

'--- flip attached bridge ---
IF s2& > 0 THEN
  by = INT(s2& / mapxsize) + 1           'location of top left of bridge
  bx = s2& - (by * mapxsize - mapxsize)  'to toggle.
  bl = SwitchTag(bx, by)
  blON = SwitchTag(bx, by + 1)
  IF blON = 1 THEN tileshift = 1 ELSE tileshift = -1
  FOR x = bx TO bx + bl - 1
    SetMapFG x, by, MapFG&(x, by) + tileshift
    SetMapFG x, by + 1, MapFG&(x, by + 1) + tileshift
  NEXT x
  IF blON THEN SetSwitchTag bx, by + 1, 0 ELSE SetSwitchTag bx, by + 1, 1
END IF

player(0).action = switching
player(0).actiontime = maxfps / 3
player(0).xv = 0: player(0).frozen = 1
PlaySound 5

END SUB

SUB SetSwitchTag (x, y, sw&)

bitl(0) = sw&
BiosXWrite SwitchTagHandle, ((y * mapxsize - mapxsize) + x) * 4 - 4, 4, VARSEG(bitl(0)), VARPTR(bitl(0))

END SUB

SUB SwitchingFrames

player(0).frame = pframe(21)
player(0).txsize = fsize(21).x
player(0).tysize = fsize(21).y

END SUB

FUNCTION SwitchTag& (x, y)

BiosXRead SwitchTagHandle, ((y * mapxsize - mapxsize) + x) * 4 - 4, 4, VARSEG(bitl(0)), VARPTR(bitl(0))
SwitchTag& = bitl(0)

END FUNCTION

SUB UnlockDoor

mx = INT(player(0).x / ts) + 1
my = INT((player(0).y + (player(0).tysize / 4)) / ts) + 1

hadkey = 0
SELECT CASE SlopeMask&(MapFG&(mx, my))
 CASE 1: IF player(0).keyred = 1 THEN player(0).keyred = 0: hadkey = 1
 CASE 2: IF player(0).keyblu = 1 THEN player(0).keyblu = 0: hadkey = 1
 CASE 3: IF player(0).keygrn = 1 THEN player(0).keygrn = 0: hadkey = 1
 CASE 4: IF player(0).keyyel = 1 THEN player(0).keyyel = 0: hadkey = 1
END SELECT

IF hadkey THEN
  t& = SwitchTag&(mx, my)               'use switchtag to find the top of
  dy = INT(t& / mapxsize) + 1           'the door to open. check there to
  dx = t& - (dy * mapxsize - mapxsize)  'find the height of the door then
  dh& = SwitchTag&(dx, dy)              'change the tiles.
  FOR y = dy TO dy + dh& - 1            '
    SetMapFG dx, y, MapFG&(dx, y) + 1   '
  NEXT y                                '
  SetMapFG mx, my, MapFG&(mx, my) + 1   'change socket to filled socket
 
  SetSwitchTag mx, my, 0
  SetSwitchTag dx, dy, 0
 
  player(0).action = switching
  player(0).actiontime = maxfps / 3
  player(0).xv = 0: player(0).frozen = 1
  PlaySound 17
END IF

END SUB


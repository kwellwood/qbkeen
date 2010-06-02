DEFINT A-Z
'$INCLUDE: 'engine.bi'
'$INCLUDE: 'player.bi'
'$INCLUDE: 'render.bi'
'$INCLUDE: 'teleport.bi'
'$STATIC

CONST portalxsize = 24, portalysize = 24

TYPE portaltype
 x AS INTEGER
 y AS INTEGER
 destx AS INTEGER
 desty AS INTEGER
END TYPE

ON ERROR GOTO ErrorHandler

DIM SHARED numportals
DIM SHARED portal(1 TO 32) AS portaltype
'============================================================================
ErrorHandler:
e = ERR
ErrorHandlerSub e
RESUME NEXT

SUB CheckTeleport

'-- must be standing on the ground --
IF player(0).onground = 0 THEN EXIT SUB

' already teleporting?
IF player(0).action = teleporting AND player(0).actiontime THEN EXIT SUB

'---[ Check for a Portal ]---
p = 0 'assume no portal
FOR k = 1 TO numportals
  px1 = portal(k).x - (portalxsize / 2): py1 = portal(k).y - (portalysize / 2)
  px2 = portal(k).x + (portalxsize / 2): py2 = portal(k).y + (portalxsize / 2)
  IF player(0).x >= px1 AND player(0).x <= px2 AND player(p).y >= py1 AND player(0).y <= py2 THEN
    p = k: EXIT FOR
  END IF
NEXT k
IF p = 0 THEN EXIT SUB  'no portal found

'--- Update player state ---
player(0).x = portal(p).x
player(0).usingportal = p
player(0).action = teleporting
player(0).actiontime = maxfps * .7 'teleport time=(actiontime/maxfps) seconds
player(0).xv = 0: player(0).yv = 0
player(0).frozen = 1
UpdateClipPoints

END SUB

SUB LoadPortals (f)

'--- clear portals stack ---
numportals = 0

GET #f, , numportals
IF numportals > 32 THEN debuglog "WARNING: Portals in map:" + STR$(numportals): numportals = 32

'--- load portals ---
FOR p = 1 TO numportals
  GET #f, , portal(p).x
  GET #f, , portal(p).y
  GET #f, , portal(p).destx
  GET #f, , portal(p).desty
NEXT p

END SUB

SUB TeleportingFrames

framedataslot = 23

player(0).frame = PlayerFrame&(framedataslot) + INT(((maxfps * .7) - player(0).actiontime) / ((maxfps * .7) / PlayerFrame&(24)))
player(0).txsize = PFrameSizeX(framedataslot)
player(0).tysize = PFrameSizeY(framedataslot) + ((player(0).frame - PlayerFrame&(framedataslot)) * 8)

END SUB

SUB TeleportPlayer

player(0).x = portal(player(0).usingportal).destx
player(0).y = portal(player(0).usingportal).desty
player(0).usingportal = 0
UpdateClipPoints
FocusCamera

END SUB


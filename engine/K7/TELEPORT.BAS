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
SUB CheckTeleport

IF player(0).onground = 0 THEN EXIT SUB  ' must be standing on the ground

p = 0 'assume no portal

FOR k = 1 TO numportals
  px1 = portal(k).x - (portalxsize / 2): py1 = portal(k).y - (portalysize / 2)
  px2 = portal(k).x + (portalxsize / 2): py2 = portal(k).y + (portalxsize / 2)
  IF player(0).x >= px1 AND player(0).x <= px2 AND player(p).y >= py1 AND player(0).y <= py2 THEN
    p = k: EXIT FOR
  END IF
NEXT k

IF p = 0 THEN EXIT SUB  'no portal found

' already teleporting?
IF player(0).action = teleporting AND player(0).actiontime THEN EXIT SUB

player(0).x = portal(p).x
player(0).usingportal = p
player(0).action = teleporting
player(0).actiontime = maxfps * .7 'teleport time=actiontime/maxfps seconds
player(0).xv = 0: player(0).yv = 0: player(0).frozen = 1
UpdateClipPoints

END SUB

SUB TeleportingFrames

framedataslot = 23
anmframe = INT(anmcounter / (player(0).adelay * 4)) MOD pframe(24)
     
'anmframe is the number of frames to add for an animated pose.
'based on anmcounter.

'player(0).frame = pframe(framedataslot) + anmframe
player(0).frame = pframe(framedataslot) + INT(((maxfps * .7) - player(0).actiontime) / ((maxfps * .7) / pframe(24)))
player(0).txsize = fsize(framedataslot).x
player(0).tysize = fsize(framedataslot).y + ((player(0).frame - pframe(framedataslot)) * 8)

END SUB

SUB TeleportPlayer

player(0).x = portal(player(0).usingportal).destx
player(0).y = portal(player(0).usingportal).desty
player(0).usingportal = 0
UpdateClipPoints
FocusCamera

END SUB

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
SUB CheckClimb

IF player(0).changeaction THEN EXIT SUB

' get tile location of player
x = INT(player(0).x / ts) + 1: y = INT((player(0).y - (player(0).tysize / 4)) / ts) + 1

' no pole at this location?
IF TileType(Map&(x, y)) <> 5 THEN EXIT SUB

player(0).xv = 0: player(0).yv = 0
player(0).action = climbing: player(0).actiontime = -1
player(0).changeaction = maxfps / 3
player(0).x = (x * ts) - (ts / 2)

'allow player to rejump off of pole at 1/8 normal height
player(0).canjump = ts * (player(0).jumpheight / 8)

END SUB

SUB ClimbDown

' get tile location just below player
x = INT(player(0).x / ts) + 1: y = INT(((player(0).y + 8) - (player(0).tysize / 4)) / ts) + 1

' if the pole stops, fall off
IF TileType(Map&(x, y)) <> 5 THEN
  player(0).action = moving
END IF

player(0).y = player(0).y + 3.5

END SUB

SUB ClimbingFrames

'25=climbing up left
'26=climbing up left frames
'27=climbing up right
'28=climbing up right frames
'29=climbing down
'30=climbing down frames

SELECT CASE player(0).aim
 CASE up    ' climbing up
  IF player(0).xdir = left THEN
    framedataslot = 25
    anmframe = INT(anmcounter / player(0).adelay) MOD pframe(26)
   ELSEIF player(0).xdir = right THEN
    framedataslot = 27
    anmframe = INT(anmcounter / player(0).adelay) MOD pframe(28)
  END IF
 CASE down  ' sliding down
  framedataslot = 29
  anmframe = INT(anmcounter / (player(0).adelay * 2)) MOD pframe(30)
 CASE -1    ' hanging still
  IF player(0).xdir = left THEN
    framedataslot = 25: anmframe = 0
   ELSEIF player(0).xdir = right THEN
    framedataslot = 27: anmframe = 0
  END IF
END SELECT

player(0).frame = pframe(framedataslot) + anmframe
player(0).txsize = fsize(framedataslot).x
player(0).tysize = fsize(framedataslot).y

END SUB

SUB ClimbUp

' get tile location just above player
x = INT(player(0).x / ts) + 1: y = INT(((player(0).y - 6) - (player(0).tysize / 4)) / ts) + 1

' if the pole stops, dont climb higher       \/ dont animate climbing up
IF TileType(Map&(x, y)) <> 5 THEN player(0).aim = -1: EXIT SUB

player(0).y = player(0).y - 2

END SUB


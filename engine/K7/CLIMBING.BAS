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

'-- too soon to grab a pole --
IF player(0).changeaction THEN EXIT SUB

'-- get tile location of player --
x = INT(player(0).x / ts) + 1
y = INT((player(0).y - (player(0).tysize / 4)) / ts) + 1

'-- no pole at this location? --
IF TileType(Map&(x, y)) <> 5 THEN EXIT SUB

'-- set climbing state --
player(0).xv = 0: player(0).yv = 0
player(0).action = climbing: player(0).actiontime = -1
player(0).changeaction = maxfps / 3
player(0).x = (x * ts) - (ts / 2)
player(0).canjump = ts * (player(0).jumpheight / 8) 'allow player to jump off
                                                    ' pole at 1/8 norm height

END SUB

SUB CheckForLedge (s, mx, my)

'+--+--+  . = mx, my
'|1 |  |
'|  |  |
'+--+--+
'|##|. |
'|##|  |
'+--+--+

SELECT CASE s
 CASE left: mx = mx - 1
 CASE right: mx = mx + 1
END SELECT

'--- check for wall in tile 1 area ---
fg = TileType(MapFG&(mx, my - 1))
bg = TileType(Map&(mx, my - 1))
IF fg = 2 OR fg = 9 OR bg THEN EXIT SUB

'--- not if using pogo or shooting ---
IF player(0).action <> moving THEN EXIT SUB
IF player(0).yv <= 0 THEN EXIT SUB

player(0).y = (my * ts - ts - 4) + (player(0).ysize / 2)
UpdateClipPoints

player(0).action = hanging
player(0).actiontime = -1
player(0).changeaction = maxfps / 6
player(0).frozen = 1
player(0).holdingjump = 0
player(0).stoppedjump = 0
player(0).canjump = 0
player(0).yv = 0: player(0).xv = 0

END SUB

SUB ClimbDown

'-- get tile location just below player --
x = INT(player(0).x / ts) + 1
y = INT(((player(0).y + 8) - (player(0).tysize / 4)) / ts) + 1

'-- if the pole stops, fall off --
IF TileType(Map&(x, y)) <> 5 THEN
  player(0).action = moving
END IF

'-- move down pole --
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
 '-- climbing up --
 CASE up
  IF player(0).xdir = left THEN
    framedataslot = 25
    anmframe = INT(anmcounter / player(0).adelay) MOD pframe(26)
   ELSEIF player(0).xdir = right THEN
    framedataslot = 27
    anmframe = INT(anmcounter / player(0).adelay) MOD pframe(28)
  END IF
 '-- sliding down --
 CASE down
  framedataslot = 29
  anmframe = INT(anmcounter / (player(0).adelay * 2)) MOD pframe(30)
 '-- hanging still --
 CASE -1
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

'-- get tile location just above player --
x = INT(player(0).x / ts) + 1
y = INT(((player(0).y - 6) - (player(0).tysize / 4)) / ts) + 1

'-- if the pole stops --
' dont move up, dont aim up
IF TileType(Map&(x, y)) <> 5 THEN player(0).aim = -1: EXIT SUB

'-- climb up pole --
player(0).y = player(0).y - 2

END SUB

SUB FinishHangClimb

SELECT CASE player(0).xdir
 CASE left
  p = 5: mx = INT(clippoint(5).x / ts + 1) - 1: posontile! = .5
 CASE right
  p = 6: mx = INT(clippoint(6).x / ts + 1) + 1: posontile! = .5
END SELECT
my = INT(clippoint(p).y / ts + 1)

player(0).x = (mx * ts - ts) + (ts * posontile!)
player(0).y = ((my * ts - ts) - 1) - (player(0).ysize / 2)
player(0).onground = 1
UpdateClipPoints

END SUB

SUB HangClimbFrames

SELECT CASE player(0).xdir
 CASE left: framedataslot = 43
 CASE right: framedataslot = 44
END SELECT

anmframes = 4
anmframe = INT(((maxfps * .5) - player(0).actiontime) / ((maxfps * .5) / anmframes))

SELECT CASE player(0).xdir
 CASE left
  SELECT CASE anmframe
   CASE 0: xsize = 22: ysize = 76
   CASE 1: xsize = 28: ysize = 92
   CASE 2: xsize = 40: ysize = 94
   CASE 3: xsize = 44: ysize = 96
  END SELECT
 CASE right
  SELECT CASE anmframe
   CASE 0: xsize = 22: ysize = 76
   CASE 1: xsize = 16: ysize = 92
   CASE 2: xsize = 4: ysize = 94
   CASE 3: xsize = 0: ysize = 96
  END SELECT
END SELECT

player(0).frame = pframe(framedataslot) + anmframe
player(0).txsize = xsize
player(0).tysize = ysize

END SUB

SUB HangClimbUp

IF player(0).changeaction THEN EXIT SUB

player(0).action = hangclimb
player(0).actiontime = maxfps * .5

END SUB

SUB HangingFrames

SELECT CASE player(0).xdir
 CASE left: framedataslot = 41
 CASE right: framedataslot = 42
END SELECT

player(0).frame = pframe(framedataslot)
player(0).txsize = fsize(framedataslot).x
player(0).tysize = fsize(framedataslot).y

END SUB


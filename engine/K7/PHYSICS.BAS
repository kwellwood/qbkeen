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
SUB DoPhysics

poldx! = player(0).x
poldy! = player(0).y

'=======[ MAX SPEED ]=======
IF player(0).xv > player(0).xmax THEN player(0).xv = player(0).xmax
IF player(0).yv > player(0).ymax THEN player(0).yv = player(0).ymax
IF player(0).xv < -player(0).xmax THEN player(0).xv = -player(0).xmax
IF player(0).yv < -player(0).ymax THEN player(0).yv = -player(0).ymax

'=======[ MOVE PLAYER ]=======
player(0).x = player(0).x + player(0).xv
player(0).y = player(0).y + player(0).yv

'=======[ FRICTION ]=======
player(0).xv = player(0).xv * (8 / 10)
player(0).yv = player(0).yv * (8 / 10)
IF player(0).xv < .2 AND player(0).xv > 0 THEN player(0).xv = 0
IF player(0).xv > -.2 AND player(0).xv < 0 THEN player(0).xv = 0
IF player(0).yv < .2 AND player(0).yv > 0 THEN player(0).yv = 0
IF player(0).yv > -.2 AND player(0).yv < 0 THEN player(0).yv = 0

'=======[ BOUNDARIES ]=======
IF player(0).x < 0 THEN player(0).x = 0: player(0).xv = 0
IF player(0).y < 0 THEN player(0).y = 0: player(0).yv = 0
IF player(0).x > (mapxsize * ts) - 1 THEN player(0).x = (mapxsize * ts) - 1: player(0).xv = 0
IF player(0).y > (mapysize * ts) - 1 THEN player(0).y = (mapysize * ts) - 1: player(0).yv = 0

'===============================[ CLIPPING ]=================================

' 1--5--2
' |     |
' |     |
' |     |
' 3--6--4

IF HitPoint(5) THEN HitWall 5, player(0).x, player(0).y - (player(0).ysize / 2)
IF HitPoint(6) THEN HitWall 6, player(0).x, player(0).y + (player(0).ysize / 2)

IF HitPoint(1) THEN HitWall 1, player(0).x - (player(0).xsize / 2), player(0).y - (player(0).ysize / 2)
IF HitPoint(2) THEN HitWall 2, player(0).x + (player(0).xsize / 2), player(0).y - (player(0).ysize / 2)
IF HitPoint(3) THEN HitWall 3, player(0).x - (player(0).xsize / 2), player(0).y + (player(0).ysize / 2)
IF HitPoint(4) THEN HitWall 4, player(0).x + (player(0).xsize / 2), player(0).y + (player(0).ysize / 2)

END SUB

FUNCTION HitPoint (p)

'px1! = player(0).x - (player(0).xsize / 2)
'py1! = player(0).y - (player(0).ysize / 2)
'px2! = player(0).x + (player(0).xsize / 2)
'py2! = player(0).y + (player(0).ysize / 2)
'ptopx! = player(0).x: ptopy! = player(0).y - (player(0).ysize / 2)
'pbotx! = player(0).x: pboty! = player(0).y + (player(0).ysize / 2)

'tpx1 = INT(px1! / ts) + 1: tpy1 = INT(py1! / ts) + 1
'tpx2 = INT(px2! / ts) + 1: tpy2 = INT(py2! / ts) + 1
'tptopx = INT(ptopx! / ts) + 1: tptopy = INT(ptopy! / ts) + 1
'tpbotx = INT(pbotx! / ts) + 1: tpboty = INT(pboty! / ts) + 1
'----------------------------------------------------------------------------
'tpx1 = INT((player(0).x - (player(0).xsize / 2)) / ts) + 1
'tpy1 = INT((player(0).y - (player(0).ysize / 2)) / ts) + 1
'tpx2 = INT((player(0).x + (player(0).xsize / 2)) / ts) + 1
'tpy2 = INT((player(0).y + (player(0).ysize / 2)) / ts) + 1
'tptopx = INT(player(0).x / ts) + 1
'tptopy = INT((player(0).y - (player(0).ysize / 2)) / ts) + 1
'tpbotx = INT(player(0).x / ts) + 1
'tpboty = INT((player(0).y + (player(0).ysize / 2)) / ts) + 1
'============================================================================

SELECT CASE p
 CASE 1
  mx = INT((player(0).x - (player(0).xsize / 2)) / ts) + 1
  my = INT((player(0).y - (player(0).ysize / 2)) / ts) + 1
 CASE 2
  mx = INT((player(0).x + (player(0).xsize / 2)) / ts) + 1
  my = INT((player(0).y - (player(0).ysize / 2)) / ts) + 1
 CASE 3
  mx = INT((player(0).x - (player(0).xsize / 2)) / ts) + 1
  my = INT((player(0).y + (player(0).ysize / 2)) / ts) + 1
 CASE 4
  mx = INT((player(0).x + (player(0).xsize / 2)) / ts) + 1
  my = INT((player(0).y + (player(0).ysize / 2)) / ts) + 1
 CASE 5
  mx = INT(player(0).x / ts) + 1
  my = INT((player(0).y - (player(0).ysize / 2)) / ts) + 1
 CASE 6
  mx = INT(player(0).x / ts) + 1
  my = INT((player(0).y + (player(0).ysize / 2)) / ts) + 1
END SELECT

IF TileType(Map&(mx, my)) THEN HitPoint = 1 ELSE HitPoint = 0

END FUNCTION

SUB HitWall (p, hx!, hy!)

side = -1

IF p = 5 THEN 'AND player(0).yv < 0 THEN
  ny! = INT((hy! - (hy! MOD ts)) + ts)
  'nx! = hx! + ((ny! - hy!) / (player(0).yv / player(0).xv))
  side = up
 ELSEIF p = 6 THEN 'AND player(0).yv > 0 THEN
  ny! = INT((hy! - (hy! MOD ts)) - 1)
  'nx! = hx! + ((ny! - hy!) / (player(0).yv / player(0).xv))
  side = down
 ELSEIF p = 1 THEN 'AND player(0).xv < 0 THEN
  nx! = INT((hx! - (hx! MOD ts)) + ts)
  'ny! = hy! + ((nx! - hx!) * (player(0).yv / player(0).xv))
  side = right
 ELSEIF p = 3 THEN 'AND player(0).xv < 0 THEN
  nx! = INT((hx! - (hx! MOD ts)) + ts)
  'ny! = hy! + ((nx! - hx!) * (player(0).yv / player(0).xv))
  side = right
 ELSEIF p = 2 THEN 'AND player(0).xv > 0 THEN
  nx! = INT((hx! - (hx! MOD ts)) - 1)
  'ny! = hy! + ((nx! - hx!) * (player(0).yv / player(0).xv))
  side = left
 ELSEIF p = 4 THEN 'AND player(0).xv > 0 THEN
  nx! = INT((hx! - (hx! MOD ts)) - 1)
  'ny! = hy! + ((nx! - hx!) * (player(0).yv / player(0).xv))
  side = left
END IF

SELECT CASE side
 CASE up
  player(0).yv = 0
  player(0).y = ny! + (player(0).ysize / 2)
 CASE down
  player(0).yv = 0
  player(0).y = ny! - (player(0).ysize / 2)
 CASE left
  player(0).xv = 0
  IF p = 1 OR p = 3 THEN player(0).x = nx! + (player(0).xsize / 2)
  IF p = 2 OR p = 4 THEN player(0).x = nx! - (player(0).xsize / 2)
 CASE right
  player(0).xv = 0
  IF p = 1 OR p = 3 THEN player(0).x = nx! + (player(0).xsize / 2)
  IF p = 2 OR p = 4 THEN player(0).x = nx! - (player(0).xsize / 2)
END SELECT

END SUB


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
SUB AddItem (x, y, id)

IF LEN(unuseditemstack(0)) > 0 THEN
  i = ASC(LEFT$(unuseditemstack(0), 1))
  unuseditemstack(0) = RIGHT$(unuseditemstack(0), LEN(unuseditemstack(0)) - 1)
  activeitemstack(0) = activeitemstack(0) + CHR$(i)
  item(i).id = id
  item(i).x = x: item(i).y = y
  WHILE DQBmouseLB: WEND
  refresh = 1
END IF

END SUB

SUB DeleteItem (x, y)

FOR k = 1 TO LEN(activeitemstack(0))
  IF k > LEN(activeitemstack(0)) THEN EXIT FOR
  i = ASC(MID$(activeitemstack(0), k, 1))
 
  ix1 = item(i).x - (bonus(item(i).id).xsize / 2)
  ix2 = item(i).x + (bonus(item(i).id).xsize / 2)
  iy1 = item(i).y - (bonus(item(i).id).ysize / 2)
  iy2 = item(i).y + (bonus(item(i).id).ysize / 2)
  IF x >= ix1 AND x <= ix2 AND y >= iy1 AND y <= iy2 THEN
    activeitemstack(0) = LEFT$(activeitemstack(0), k - 1) + RIGHT$(activeitemstack(0), LEN(activeitemstack(0)) - k)
    unuseditemstack(0) = unuseditemstack(0) + CHR$(i)
    k = k - 1
  END IF
NEXT k

END SUB

SUB DrawItems

FOR k = 1 TO LEN(activeitemstack(0))
  i = ASC(MID$(activeitemstack(0), k, 1))
 
  IF (item(i).x + (bonus(item(i).id).xsize / 2)) / (ts / zoom) >= camera(0).vx1 AND (item(i).x - (bonus(item(i).id).xsize / 2)) / (ts / zoom) <= camera(0).vx2 THEN
    IF (item(i).y + (bonus(item(i).id).ysize / 2)) / (ts / zoom) >= camera(0).vy1 AND (item(i).y - (bonus(item(i).id).ysize / 2)) / (ts / zoom) <= camera(0).vy2 THEN
      x = (item(i).x / (ts / zoom)) - camera(0).vx1 - (bonus(item(i).id).xsize / 2) / (ts / zoom)
      y = (item(i).y / (ts / zoom)) - camera(0).vy1 - (bonus(item(i).id).ysize / 2) / (ts / zoom)

      frame& = bonus(item(i).id).sframe
      xsize = bonus(item(i).id).xsize / (ts / zoom)
      ysize = bonus(item(i).id).ysize / (ts / zoom)
      IF zoom < ts THEN PutSpriteS frame&, x, y, xsize, ysize, drawpage ELSE PutSprite frame&, x, y, drawpage
    END IF
  END IF
NEXT k

END SUB

SUB InitItems

OPEN "items.dat" FOR INPUT AS 1
  INPUT #1, numitemtypes
  FOR i = 1 TO numitemtypes
    INPUT #1, bonus(i).sframe
    INPUT #1, bonus(i).frames
    INPUT #1, bonus(i).delay
    INPUT #1, bonus(i).psframe
    INPUT #1, bonus(i).pframes
    INPUT #1, bonus(i).pdelay
    INPUT #1, bonus(i).xsize
    INPUT #1, bonus(i).ysize
    INPUT #1, bonus(i).pxsize
    INPUT #1, bonus(i).pysize
    INPUT #1, bonus(i).points
    INPUT #1, bonus(i).ammo
    INPUT #1, bonus(i).lifedrop
    INPUT #1, bonus(i).gemkey
  NEXT i
CLOSE 1

activeitemstack(0) = ""

END SUB


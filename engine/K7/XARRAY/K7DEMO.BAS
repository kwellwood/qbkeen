DEFINT A-Z
'$DYNAMIC
DECLARE FUNCTION XMSError% ()
DECLARE FUNCTION WhichXError% ()
DECLARE FUNCTION GetXMS% (handle%)
DECLARE SUB InitXMS (there%, memsize%)
DECLARE SUB FreeXMS (memsize%)
DECLARE SUB XSetElement (handle, array AS ANY, elementSize, element)
DECLARE SUB XGetElement (handle, array AS ANY, elementSize, element)

      'CALL XSetElement(handle, temp, 40, element)
      'IF XMSError THEN GOTO errorend

      'PRINT : PRINT "Element"; element; "is: ";
      'CALL XGetElement(handle, temp, 40, element)


TYPE enemytype    'SIZE: 50 bytes
  id AS INTEGER
  x AS SINGLE
  y AS SINGLE
  xv AS SINGLE
  yv AS SINGLE
  xdir AS INTEGER
  onground AS INTEGER
  onslope AS INTEGER
  action AS INTEGER
  actiontime AS INTEGER
  frame AS LONG
  xsize AS INTEGER
  ysize AS INTEGER
  txsize AS INTEGER
  tysize AS INTEGER
  status AS INTEGER
  statustime AS INTEGER
  xmax AS INTEGER
  ymax AS INTEGER
  starsprite AS INTEGER
END TYPE

InitXMS exists, memsize
handle = GetXMS(memsize)

DIM enemy AS enemytype

FOR x = 1 TO 3000
  enemy.x = x + 5
  XSetElement handle, enemy, 50, x
NEXT x

t! = TIMER
FOR x = 1 TO 3000
  XGetElement handle, enemy, 50, x
'  PRINT enemy.x
NEXT x
PRINT "**"; TIMER - t!

t! = TIMER
FOR x = 1 TO 3000
  newx! = enemy.x
'  PRINT newx!
NEXT x
PRINT "**"; TIMER - t!

FreeXMS handle


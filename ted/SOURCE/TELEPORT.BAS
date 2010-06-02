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
FUNCTION AddPortal (x, y)

IF LEN(unusedportalstack(0)) > 0 THEN
  p = ASC(LEFT$(unusedportalstack(0), 1))
  unusedportalstack(0) = RIGHT$(unusedportalstack(0), LEN(unusedportalstack(0)) - 1)
  activeportalstack(0) = activeportalstack(0) + CHR$(p)
  portal(p).x = x: portal(p).destx = 0
  portal(p).y = y: portal(p).desty = 0
  AddPortal = p
 ELSE
  AddPortal = 0
END IF

END FUNCTION

SUB DeletePortal (x, y)

FOR k = 1 TO LEN(activeportalstack(0))
  IF k > LEN(activeportalstack(0)) THEN EXIT FOR
  p = ASC(MID$(activeportalstack(0), k, 1))

  px1 = portal(p).x - (portalxsize / 2)
  px2 = portal(p).x + (portalxsize / 2)
  py1 = portal(p).y - (portalysize / 2)
  py2 = portal(p).y + (portalysize / 2)
  IF x >= px1 AND x <= px2 AND y >= py1 AND y <= py2 THEN
    activeportalstack(0) = LEFT$(activeportalstack(0), k - 1) + RIGHT$(activeportalstack(0), LEN(activeportalstack(0)) - k)
    unusedportalstack(0) = unusedportalstack(0) + CHR$(p)
    portal(p).x = 0: portal(p).y = 0: portal(p).destx = 0: portal(p).desty = 0
    k = k - 1
  END IF
NEXT k
refresh = 1

END SUB

SUB DrawPortals

FOR k = 1 TO LEN(activeportalstack(0))
  p = ASC(MID$(activeportalstack(0), k, 1))
 
  '--- entry portals ---
  IF OnScreen(portal(p).x, portal(p).y, portalxsize, portalysize) THEN
    DQBprint drawpage, "T" + LTRIM$(STR$(p)), (portal(p).x / (ts / zoom)) - camera(0).vx1 - 6, (portal(p).y / (ts / zoom)) - camera(0).vy1 - 3, 144
    DrawMarkerBox portal(p).x, portal(p).y, portalxsize, portalysize, 144
  END IF
 
  '--- destination portals ---
  IF OnScreen(portal(p).destx, portal(p).desty, destxsize, destysize) THEN
    DQBprint drawpage, "D" + LTRIM$(STR$(p)), (portal(p).destx / (ts / zoom)) - camera(0).vx1 - 5, (portal(p).desty / (ts / zoom)) - camera(0).vy1 - 3, 167
    DrawMarkerBox portal(p).destx, portal(p).desty, destxsize, destysize, 167
  END IF
NEXT k

END SUB

SUB SetPortalDest (p, x, y)

portal(p).destx = x
portal(p).desty = y

END SUB


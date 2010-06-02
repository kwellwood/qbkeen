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
SUB AddLift (x, y)

IF numlocators(currentTrack) AND numlifts < 16 THEN
  '--- find nearest locator on track ---
  leastd! = 50000: nearestloc = 0
  FOR k = 1 TO numlocators(currentTrack)
    dx& = ABS(locator(currentTrack, k).x - x)
    dy& = ABS(locator(currentTrack, k).y - y)
    d! = SQR(dx& * dx& + dy& * dy&)
    IF d! < leastd! THEN
      leastd! = d!: nearestloc = k   'found nearer locator
    END IF
  NEXT k
  IF nearestloc = 0 THEN EXIT SUB ELSE l = nearestloc

  '--- check for a lift already there ---
  FOR p = 1 TO numlifts
    IF lift(p).track = currentTrack THEN
      IF lift(p).target = l THEN EXIT SUB
    END IF
  NEXT p

  '--- create new lift ---
  numlifts = numlifts + 1
  lift(numlifts).track = currentTrack
  lift(numlifts).target = l
  lift(numlifts).x = locator(currentTrack, l).x
  lift(numlifts).y = locator(currentTrack, l).y
END IF

END SUB

SUB AddLocator (x, y)

IF numlocators(currentTrack) < 16 THEN
  DQBbox drawpage, 100, 93, 205, 105, 15
  DQBboxf drawpage, 101, 94, 204, 104, 14
  DQBprint drawpage, "Delay:", 102, 96, 71
  DrawpageToVideo
  d$ = LTRIM$(RTRIM$(GetNumber$(131, 96)))
  IF d$ <> "" THEN delay = VAL(d$) ELSE EXIT SUB

  DQBbox drawpage, 100, 93, 205, 105, 15
  DQBboxf drawpage, 101, 94, 204, 104, 14
  DQBprint drawpage, "Switch:", 102, 96, 71
  DrawpageToVideo
  l$ = LTRIM$(RTRIM$(GetNumber$(137, 96)))
  IF l$ <> "" THEN locksw = VAL(l$) ELSE EXIT SUB

  numlocators(currentTrack) = numlocators(currentTrack) + 1
  l = numlocators(currentTrack)
  locator(currentTrack, l).x = x
  locator(currentTrack, l).y = y
  locator(currentTrack, l).delay = delay
  locator(currentTrack, l).locksw = locksw
END IF

END SUB

SUB DeleteLift (x, y)

FOR l = 1 TO numlifts
  lx1 = lift(l).x - liftxsize / 2
  lx2 = lift(l).x + liftxsize / 2
  ly1 = lift(l).y - liftysize / 2
  ly2 = lift(l).y + liftysize / 2
  IF x >= lx1 AND x <= lx2 AND y >= ly1 AND y <= ly2 THEN
   
    IF l = numlifts THEN numlifts = numlifts - 1: EXIT FOR
   
    FOR k = l + 1 TO numlifts
      lift(k - 1).x = lift(k).x
      lift(k - 1).y = lift(k).y
      lift(k - 1).target = lift(k).target
      lift(k - 1).track = lift(k).track
    NEXT k
    numlifts = numlifts - 1
    l = l - 1
  END IF
NEXT l

END SUB

SUB DeleteLocator (x, y)

FOR t = 1 TO 16
  FOR l = 1 TO numlocators(t)
    lx1 = locator(t, l).x - locatorxsize / 2
    lx2 = locator(t, l).x + locatorxsize / 2
    ly1 = locator(t, l).y - locatorysize / 2
    ly2 = locator(t, l).y + locatorysize / 2
    IF x >= lx1 AND x <= lx2 AND y >= ly1 AND y <= ly2 THEN
      '--- delete any attached lifts ---
      FOR n = 1 TO numlifts
        IF lift(n).track = t AND lift(n).target = l THEN DeleteLift locator(t, l).x, locator(t, l).y
      NEXT n
     
      '--- fill gap in arry ---
      IF l = numlocators(t) THEN numlocators(t) = numlocators(t) - 1: EXIT FOR
      FOR k = l + 1 TO numlocators(t)
        locator(t, k - 1).x = locator(t, k).x
        locator(t, k - 1).y = locator(t, k).y
        locator(t, k - 1).delay = locator(t, k).delay
        locator(t, k - 1).locksw = locator(t, k).locksw
      NEXT k
      numlocators(t) = numlocators(t) - 1
      l = l - 1
    END IF
  NEXT l
NEXT t

END SUB

SUB DrawLifts

FOR p = 1 TO numlifts
  x = (lift(p).x / (ts / zoom)) - camera(0).vx1 - (liftxsize / 2) / (ts / zoom)
  y = (lift(p).y / (ts / zoom)) - camera(0).vy1 - (liftysize / 2) / (ts / zoom)

  xsize = liftxsize / (ts / zoom)
  ysize = liftysize / (ts / zoom)
 
  'IF zoom < ts THEN PutSpriteS 1110, x, y, liftxsize, liftysize, drawpage ELSE PutSprite 1110, x, y, drawpage
  IF zoom < ts THEN PutSpriteS 700, x, y, xsize, ysize, drawpage ELSE PutSprite 700, x, y, drawpage
NEXT p

END SUB

SUB DrawLocators

FOR t = 1 TO 16
  FOR l = 1 TO numlocators(t)
    IF OnScreen(locator(t, l).x, locator(t, l).y, locatorxsize, locatorysize) THEN
      DrawMarkerBox locator(t, l).x, locator(t, l).y, locatorxsize, locatorysize, 233
      DQBprint drawpage, "T" + LTRIM$(STR$(t)) + ".L" + LTRIM$(STR$(l)), (locator(t, l).x / (ts / zoom)) - camera(0).vx1 - 10, (locator(t, l).y / (ts / zoom)) - camera(0).vy1 - 3, 15
    END IF
  NEXT l
NEXT t

END SUB

SUB InitLifts

currentTrack = 1
locatorxsize = 20: locatorysize = 20
liftxsize = 56: liftysize = 18

END SUB


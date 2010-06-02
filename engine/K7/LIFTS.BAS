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
SUB DrawLifts

FOR l = 1 TO numlifts
  '--- if item is on screen ---
  IF lift(l).x + (52 / 2) >= camera(0).vx1 AND lift(l).x - (52 / 2) <= camera(0).vx2 THEN
    IF lift(l).y + (16 / 2) >= camera(0).vy1 AND lift(l).y - (16 / 2) <= camera(0).vy2 THEN
   
      '--- draw item ---
      x = lift(l).x - camera(0).vx1 - (52 / 2)
      y = lift(l).y - camera(0).vy1 - (16 / 2)
      IF lift(l).xv <= -1! THEN frame& = 1104
      IF lift(l).xv >= 1! THEN frame& = 1106
      IF lift(l).yv <= -1! THEN frame& = 1108
      IF lift(l).yv >= 1! THEN frame& = 1109
      IF lift(l).xv = 0 AND lift(l).yv = 0 THEN frame& = 1110
     
      IF frame& <> 1110 THEN frame& = frame& + (INT(anmcounter / liftframedelay) MOD 2)
      PutSprite frame&, x, y, drawpage
    END IF
  END IF
NEXT l

END SUB

SUB HandleLifts

FOR l = 1 TO numlifts
  IF lift(l).x = locator(lift(l).track, lift(l).target).x AND lift(l).y = locator(lift(l).track, lift(l).target).y THEN
    '================[ AT A TARGET ]================
    '--- decrease waiting time ---
    IF lift(l).delay THEN lift(l).delay = lift(l).delay - 1
   
    '--- set new target for lift ---
    IF lift(l).delay = 0 THEN
      IF locator(lift(l).track, lift(l).target).locksw THEN
        IF switch(locator(lift(l).track, lift(l).target).locksw) = 1 THEN SetLiftTarget l
       ELSE SetLiftTarget l
      END IF
    END IF
   ELSE
    '===================[ MOVING ]==================
    '--- record original positions ---
    ox! = lift(l).x: oy! = lift(l).y
   
    '--- move along track ---
    lift(l).x = lift(l).x + lift(l).xv
    lift(l).y = lift(l).y + lift(l).yv

    '--- set delay if arriving at target ---
    IF LiftNearTarget(l) THEN
      lift(l).x = locator(lift(l).track, lift(l).target).x
      lift(l).y = locator(lift(l).track, lift(l).target).y
      IF locator(lift(l).track, lift(l).target).delay THEN lift(l).delay = locator(lift(l).track, lift(l).target).delay
    END IF
    
    '--- move player if attached to lift ---
    IF player(0).onlift = l THEN
      DebugLog "Onlift:" + STR$(l)
      DebugLog "Lift().xv,yv:" + STR$(lift(l).xv) + "," + STR$(lift(l).yv)
      DebugLog "Lift().x,y[1]:" + STR$(ox!) + "," + STR$(oy!)
      DebugLog "Lift().x,y[2]:" + STR$(lift(l).x) + "," + STR$(lift(l).y)
      DebugLog "Player().x,y[1]:" + STR$(player(0).x) + "," + STR$(player(0).y)
      player(0).x = player(0).x + (lift(l).x - ox!)
      player(0).y = player(0).y + (lift(l).y - oy!)
      DebugLog "Player().x,y[2]:" + STR$(player(0).x) + "," + STR$(player(0).y)
      DebugLog "Distance from lift (x,y):" + STR$(lift(l).x - player(0).x) + "," + STR$(lift(l).y - player(0).y)
      DebugLog "----------------"
      UpdateClipPoints
     ELSEIF player(0).onlift = 0 THEN
      DebugLog "*** Not on lift ***"
    END IF
  END IF
NEXT l

'if platform is at target then
'  if platform has delay then decrease delay
'  if platform has no delay and target not locked then
'    set next target for platform
'    set new velocities
'  --
'--
'if platform is not at target then
'  move toward target
'  if platform close to target then
'    platform at target
'    if target has delay then copy to platform
'  --
'--

END SUB

FUNCTION LiftNearTarget (l)

IF ABS(lift(l).x - locator(lift(l).track, lift(l).target).x) < 2 THEN
  IF ABS(lift(l).y - locator(lift(l).track, lift(l).target).y) < 2 THEN
    LiftNearTarget = 1
   ELSE LiftNearTarget = 0
  END IF
 ELSE LiftNearTarget = 0
END IF

END FUNCTION

FUNCTION LiftTouchPlayer (l)

px1! = player(0).x: py1! = player(0).y + (player(0).tysize / 2)
lx1! = lift(l).x - (56 / 2): ly1! = lift(l).y - 1
lx2! = lift(l).x + (56 / 2): ly2! = lift(l).y + (18 / 2)

IF px1! >= lx1! AND px1! <= lx2! AND py1! >= ly1! AND py1! <= ly2! THEN touch = 1

LiftTouchPlayer = touch

END FUNCTION

SUB LoadPlatforms (f)

'--- load locators ---
FOR t = 1 TO 16                 'loop through tracks
  GET #f, , numlocators(t)      'locators on this track
  FOR l = 1 TO numlocators(t)   'loop through locators
    GET #f, , locator(t, l).x
    GET #f, , locator(t, l).y
    GET #f, , locator(t, l).delay
    GET #f, , locator(t, l).locksw
  NEXT l
NEXT t

'--- load lifts ---
GET #f, , numlifts
FOR l = 1 TO numlifts
  GET #f, , lift(l).track
  GET #f, , lift(l).target
  lift(l).x = locator(lift(l).track, lift(l).target).x
  lift(l).y = locator(lift(l).track, lift(l).target).y
  lift(l).delay = 0
NEXT l

END SUB

SUB SetLiftTarget (l)

'--- set next target ---
lift(l).target = lift(l).target + 1
IF lift(l).target > numlocators(lift(l).track) THEN lift(l).target = 1

'--- set lift velocity ---
x1 = lift(l).x
y1 = lift(l).y
x2 = locator(lift(l).track, lift(l).target).x
y2 = locator(lift(l).track, lift(l).target).y
angle! = (DQBangle(x1, y1, x2, y2) - 64)

IF angle! = 63 THEN angle! = 64                     'wierd correction
angle! = angle! * (45! / 32!)                       'convert to 260deg angle
angle! = angle! * (3.141593# / 180#)                'convert from deg to rad
lift(l).xv = COS(angle!) * liftspeed!               'horizontal component
lift(l).yv = SIN(angle!) * liftspeed!               'vertical component

IF lift(l).xv < .001 AND lift(l).xv > 0 THEN lift(l).xv = 0
IF lift(l).xv > -.001 AND lift(l).xv < 0 THEN lift(l).xv = 0
IF lift(l).yv < .001 AND lift(l).yv > 0 THEN lift(l).yv = 0
IF lift(l).yv > -.001 AND lift(l).yv < 0 THEN lift(l).yv = 0

END SUB


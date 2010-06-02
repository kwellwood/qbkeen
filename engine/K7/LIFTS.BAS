DEFINT A-Z
'$INCLUDE: 'engine.bi'
'$INCLUDE: 'directqb.bi'
'$INCLUDE: 'tiles.bi'
'$INCLUDE: 'player.bi'
'$INCLUDE: 'switches.bi'
'$INCLUDE: 'render.bi'
'$INCLUDE: 'lifts.bi'
'$STATIC

CONST liftspeed! = 1.6, liftframedelay = 1

TYPE locatortype
 x AS INTEGER
 y AS INTEGER
 locksw AS INTEGER   'if locksw then check switch(locksw)
 delay AS INTEGER
END TYPE

TYPE lifttype
 x AS SINGLE
 y AS SINGLE
 xv AS SINGLE
 yv AS SINGLE
 delay AS INTEGER
 target AS INTEGER
 track AS INTEGER
END TYPE

ON ERROR GOTO ErrorHandler

DIM SHARED numtracks, numlifts
DIM SHARED liftstop&, liftleft&, liftright&, liftup&, liftdown&
DIM SHARED locator(1 TO 16, 1 TO 16) AS locatortype, numlocators(1 TO 16)
DIM SHARED lift(1 TO 16) AS lifttype
'============================================================================
ErrorHandler:
e = ERR
ErrorHandlerSub e
RESUME NEXT

SUB DoPlayerOnLift

'--- is keen on a platform? ---
player(0).onlift = 0
IF player(0).action = hangclimb THEN EXIT SUB
IF player(0).action = dying THEN EXIT SUB
FOR l = 1 TO numlifts
  IF LiftTouchPlayer(l) THEN player(0).onlift = l
NEXT l

IF player(0).onlift AND player(0).yv >= 0 THEN
  l = player(0).onlift
  player(0).onball = 0

  '--- clip player to lift ---
  ny! = lift(l).y - 1
  player(0).yv = 0
  player(0).y = ny! - (player(0).ysize / 2)
  player(0).onground = 1
  player(0).canjump = ts * player(0).jumpheight
  IF player(0).action = hanging THEN player(0).action = moving
  player(0).holdingjump = 0
  player(0).stoppedjump = 0
  UpdateClipPoints
END IF

END SUB

SUB DrawLifts

FOR l = 1 TO numlifts
  '--- if item is on screen ---
  x1 = lift(l).x - (52 / 2)
  y1 = lift(l).y - (16 / 2)
  x2 = lift(l).x + (52 / 2)
  y2 = lift(l).y + (16 / 2)
  IF OnCamera(x1, y1, x2, y2) THEN
     
    '--- draw item ---
    x = lift(l).x - CameraOrigX - (52 / 2)
    y = lift(l).y - CameraOrigY - (16 / 2)
    IF lift(l).xv <= -1! THEN frame& = liftleft&  '1104
    IF lift(l).xv >= 1! THEN frame& = liftright&  '1106
    IF lift(l).yv <= -1! THEN frame& = liftup&    '1108
    IF lift(l).yv >= 1! THEN frame& = liftdown&   '1109
    IF lift(l).xv = 0 AND lift(l).yv = 0 THEN frame& = liftstop&  '1110
     
    IF frame& <> 1110 THEN frame& = frame& + (INT(anmcounter / liftframedelay) MOD 2)
    PutSprite frame&, x, y, drawpage
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
        IF GetSwitch(locator(lift(l).track, lift(l).target).locksw) = 1 THEN SetLiftTarget l
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
      player(0).x = player(0).x + (lift(l).x - ox!)
      player(0).y = player(0).y + (lift(l).y - oy!)
      UpdateClipPoints
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

SUB InitLifts

OPEN "engine.dat" FOR INPUT AS 1
  DO: INPUT #1, Text$
  LOOP UNTIL UCASE$(Text$) = "[LIFTS.DAT]"
  INPUT #1, liftstop&
  INPUT #1, liftleft&
  INPUT #1, liftright&
  INPUT #1, liftup&
  INPUT #1, liftdown&
CLOSE 1

END SUB

FUNCTION LiftNearTarget (l)

IF ABS(lift(l).x - locator(lift(l).track, lift(l).target).x) < 4 THEN
  IF ABS(lift(l).y - locator(lift(l).track, lift(l).target).y) < 4 THEN
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

IF px1! >= lx1! AND px1! <= lx2! AND py1! >= ly1! AND py1! <= ly2! THEN LiftTouchPlayer = 1

END FUNCTION

SUB LoadLiftsFromFile (f)

FOR l = 1 TO numlifts
  GET #f, , lift(l)
NEXT l

END SUB

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

SUB WriteLiftsToFile (f)

FOR l = 1 TO numlifts
  PUT #f, , lift(l)
NEXT l

END SUB


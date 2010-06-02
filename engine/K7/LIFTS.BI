DEFINT A-Z
'$DYNAMIC

CONST liftspeed! = 1.6, liftframedelay = 1

COMMON SHARED numtracks, numlifts

DECLARE SUB DrawLifts ()
DECLARE SUB HandleLifts ()
DECLARE SUB LoadPlatforms (f)
DECLARE SUB SetLiftTarget (l)
DECLARE FUNCTION LiftNearTarget (l)
DECLARE FUNCTION LiftTouchPlayer (l)

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

COMMON SHARED locator() AS locatortype, numlocators(), lift() AS lifttype


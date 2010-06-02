DEFINT A-Z
'$DYNAMIC

COMMON SHARED numtracks, numlifts, currentTrack, locatorxsize, locatorysize
COMMON SHARED liftxsize, liftysize

DECLARE SUB AddLocator (x, y)
DECLARE SUB AddLift (x, y)
DECLARE SUB DeleteLift (x, y)
DECLARE SUB DeleteLocator (x, y)
DECLARE SUB DrawLifts ()
DECLARE SUB DrawLocators ()
DECLARE SUB InitLifts ()

TYPE locatortype
 x AS INTEGER
 y AS INTEGER
 delay AS INTEGER
 locksw AS INTEGER
END TYPE

TYPE lifttype
 x AS INTEGER
 y AS INTEGER
 track AS INTEGER
 target AS INTEGER
END TYPE

COMMON SHARED numlocators(), locator() AS locatortype, lift() AS lifttype


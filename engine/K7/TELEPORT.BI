DEFINT A-Z
'$DYNAMIC

COMMON SHARED numportals

CONST portalxsize = 24, portalysize = 24

DECLARE SUB CheckTeleport ()
DECLARE SUB LoadPortals (f)
DECLARE SUB TeleportingFrames ()
DECLARE SUB TeleportPlayer ()

TYPE portaltype
 x AS INTEGER
 y AS INTEGER
 destx AS INTEGER
 desty AS INTEGER
END TYPE

COMMON SHARED portal() AS portaltype


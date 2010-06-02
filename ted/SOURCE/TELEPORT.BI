DEFINT A-Z
'$DYNAMIC

COMMON SHARED placingportal

CONST portalxsize = 24, portalysize = 24, destxsize = 16, destysize = 16

DECLARE SUB DeletePortal (x, y)
DECLARE SUB DrawPortals ()
DECLARE SUB SetPortalDest (p, x, y)
DECLARE FUNCTION AddPortal (x, y)

TYPE portaltype
 x AS INTEGER
 y AS INTEGER
 destx AS INTEGER
 desty AS INTEGER
END TYPE

COMMON SHARED portal() AS portaltype, activeportalstack() AS STRING
COMMON SHARED unusedportalstack() AS STRING


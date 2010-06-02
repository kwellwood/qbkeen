DEFINT A-Z
'$DYNAMIC

CONST red = 1, green = 2, yellow = 3, blue = 4
COMMON SHARED numitems, numitemtypes, citem

DECLARE SUB AddItem (x, y, id)
DECLARE SUB DeleteItem (x, y)
DECLARE SUB DrawItems ()
DECLARE SUB InitItems ()

TYPE itemclass
 x AS INTEGER
 y AS INTEGER
 id AS INTEGER
END TYPE

TYPE itemtypeclass
 sframe AS LONG
 frames AS INTEGER
 delay AS INTEGER
 points AS INTEGER
 lifedrop AS INTEGER
 gemkey AS INTEGER
 xsize AS INTEGER
 ysize AS INTEGER
 pxsize AS INTEGER
 pysize AS INTEGER
 ammo AS INTEGER
 psframe AS LONG
 pframes AS LONG
 pdelay AS INTEGER
END TYPE

COMMON SHARED item() AS itemclass, bonus() AS itemtypeclass
COMMON SHARED activeitemstack() AS STRING, unuseditemstack() AS STRING

'activeitemstack(0) = "list of active items to handle"
'                     "312456890"


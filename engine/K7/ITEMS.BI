DEFINT A-Z
'$DYNAMIC

CONST red = 1, green = 2, yellow = 3, blue = 4
COMMON SHARED numitems, numitemtypes

DECLARE SUB DoItems ()
DECLARE SUB DoSprites ()
DECLARE SUB DrawItems ()
DECLARE SUB DrawSprites ()
DECLARE SUB InitItems ()
DECLARE FUNCTION TouchItem (i)
DECLARE FUNCTION TouchSprite (s)

TYPE itemclass
 x AS INTEGER
 y AS INTEGER
 sframe AS LONG
 frames AS INTEGER
 delay AS INTEGER
 id AS INTEGER
 xsize AS INTEGER
 ysize AS INTEGER
 scored AS INTEGER
END TYPE

TYPE spriteclass
 x AS INTEGER
 y AS INTEGER
 frame AS LONG
 sframe AS LONG
 eframe AS LONG
 delay AS INTEGER     ' ticks per frame
 ticks AS INTEGER     ' set to delay and decrease for next frame
 xsize AS INTEGER
 ysize AS INTEGER
 deadly AS INTEGER   ' kill player if touched
 repeat AS INTEGER   ' dont kill sprite, loop animation
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
COMMON SHARED activeitemstack() AS STRING, activespritestack() AS STRING
COMMON SHARED sprite() AS spriteclass, unusedspritestack() AS STRING

'activeitemstack(0) = "list of active items to handle"
'                     "31246890"
'activespritestack(0) = "list of active passive sprites to handle"
'                       "1375"
'unusedspritestack(0) = "list of inactive passive sprites for later use"
'                       "246890"


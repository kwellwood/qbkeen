DEFINT A-Z
'$DYNAMIC

COMMON SHARED maxfps, ts
COMMON SHARED quitgame

CONST enginever = 1
CONST inmenu = 1, ingame = 2
'CONST up = 1, down = 2, left = 3, right = 4
CONST drawpage = 1, backdroppage = 2, menupage = 3, slopepage = 4

DECLARE SUB AllocXMS ()
DECLARE SUB DeallocXMS ()
DECLARE SUB DoInput ()
DECLARE SUB ErrorHandlerSub (e)
DECLARE SUB InitEngine ()
DECLARE SUB MainLoop ()
DECLARE SUB SetPalette ()

TYPE hues
 red AS INTEGER
 grn AS INTEGER
 blu AS INTEGER
END TYPE

TYPE playertype
 x AS SINGLE
 y AS SINGLE
 xv AS SINGLE
 yv AS SINGLE
 xmax AS SINGLE
 ymax AS SINGLE
 sframe AS LONG
 eframe AS LONG
 frame AS LONG
 delay AS INTEGER
 xsize AS INTEGER
 ysize AS INTEGER
END TYPE

COMMON SHARED player() AS playertype, scr(), file() AS STRING * 12
COMMON SHARED biti() AS INTEGER, bitl() AS LONG, pal() AS hues


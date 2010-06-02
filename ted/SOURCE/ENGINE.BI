DEFINT A-Z
'$DYNAMIC

COMMON SHARED maxfps, ts, refresh, scrollspeed, zoom
COMMON SHARED llcx, llcy, lrcx, lrcy, pentile&, fgvisible, tlvisible
COMMON SHARED quitgame, gamemode, keypress!, mxsize, mysize, gridsnapitems
COMMON SHARED matrices, objmode, curitem
COMMON SHARED ems, drawpage

CONST enginever = 2
CONST ingame = 1, inmenu = 2

DECLARE SUB AllocXMS ()
DECLARE SUB DeallocXMS ()
DECLARE SUB DebugLog (t$)
DECLARE SUB DoInput ()
DECLARE SUB DrawpageToVideo ()
DECLARE SUB ErrorHandlerSub (e)
DECLARE SUB GroundPlayer ()
DECLARE SUB InitEngine ()
DECLARE SUB MainLoop ()
DECLARE SUB SetPalette ()

TYPE hues
 red AS INTEGER
 grn AS INTEGER
 blu AS INTEGER
END TYPE

TYPE intcoordinate
 x AS INTEGER
 y AS INTEGER
END TYPE

TYPE playertype
 x AS SINGLE
 y AS SINGLE
 xv AS SINGLE
 yv AS SINGLE
 xdir AS INTEGER
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
COMMON SHARED matrix() AS LONG, matrixoffset() AS intcoordinate
COMMON SHARED mapidtag() AS STRING * 3


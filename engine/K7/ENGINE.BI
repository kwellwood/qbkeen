DEFINT A-Z
'$DYNAMIC

COMMON SHARED maxfps, ts, gamemode, realtimer!, anmcounter
COMMON SHARED quitgame

CONST enginever = 1
CONST inmenu = 1, ingame = 2
'CONST up = 1, down = 2, left = 3, right = 4
CONST lookup = 4, lookdown = 5
CONST drawpage = 1, backdroppage = 2, menupage = 3, slopepage = 4
CONST groundleft = 1, groundright = 2, groundup = 3, airleft = 4, airright = 5
CONST airup = 6, airdown = 7
CONST moving = 0, shooting = 1, switching = 2

DECLARE SUB AllocXMS ()
DECLARE SUB DeallocXMS ()
DECLARE SUB DebugLog (t$)
DECLARE SUB DoInput ()
DECLARE SUB DoTimers ()
DECLARE SUB ErrorHandlerSub (e)
DECLARE SUB InitEngine ()
DECLARE SUB MainLoop ()
DECLARE SUB SetPalette ()

TYPE coordinate
 x AS SINGLE
 y AS SINGLE
END TYPE

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
 txsize AS INTEGER
 tysize AS INTEGER
 onground AS INTEGER
 adelay AS INTEGER
 canjump AS INTEGER
 jumpheight AS SINGLE
 score AS LONG          ' scores.bi, items.bi
 ammo  AS INTEGER       ' scores.bi, weapon.bi
 lives AS INTEGER       ' scores.bi
 reload AS INTEGER      ' time to wait for reload
 shooting AS INTEGER    ' time to display shooting frame
 shootingframe AS LONG  ' shooting frame to show
 aim AS INTEGER         ' aiming to shoot up or down
 action AS INTEGER      ' moving, shooting, climbing, flipping switch
 actiontime AS INTEGER  ' time left to complete action
 frozen AS INTEGER      ' cant move left or right
END TYPE

COMMON SHARED player() AS playertype, scr(), file() AS STRING * 12
COMMON SHARED biti() AS INTEGER, bitl() AS LONG, pal() AS hues
COMMON SHARED pframe() AS LONG, fsize() AS intcoordinate


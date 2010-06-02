DEFINT A-Z
'$DYNAMIC

'$INCLUDE: 'engine.bi'
'$INCLUDE: 'directqb.bi'
'$INCLUDE: 'xms.bi'
'$INCLUDE: 'paklib.bi'
'$INCLUDE: 'plugins.bi'

ON ERROR GOTO ErrorHandler

'============================================================================
ErrorHandler:
e = ERR
ErrorHandlerSub 0
RESUME NEXT

REM $STATIC
SUB DoCamera

IF player(0).x - camera(0).x > 60 THEN camera(0).x = player(0).x - 60
IF player(0).x - camera(0).x < -60 THEN camera(0).x = player(0).x + 60
IF player(0).y - camera(0).y > 40 THEN camera(0).y = player(0).y - 40
IF player(0).y - camera(0).y < -40 THEN camera(0).y = player(0).y + 40
IF camera(0).x < 0 THEN camera(0).x = 0
IF camera(0).y < 0 THEN camera(0).y = 0

camera(0).vx1 = camera(0).x - 160: camera(0).vy1 = camera(0).y - 100
camera(0).vx2 = camera(0).vx1 + 319: camera(0).vy2 = camera(0).vy1 + 199

IF camera(0).vx1 < 0 THEN camera(0).vx1 = 0
IF camera(0).vy1 < 0 THEN camera(0).vy1 = 0
camera(0).vx2 = camera(0).vx1 + 319: camera(0).vy2 = camera(0).vy1 + 199
IF camera(0).vx2 > (ts * mapxsize) - 1 THEN camera(0).vx2 = (ts * mapxsize) - 1
IF camera(0).vy2 > (ts * mapysize) - 1 THEN camera(0).vy2 = (ts * mapysize) - 1
camera(0).vx1 = camera(0).vx2 - 319: camera(0).vy1 = camera(0).vy2 - 199

END SUB

SUB DrawHUD
'=================[ CLIP POINTS ON PLAYER ]=================
DQBpset drawpage, player(0).x - camera(0).vx1, player(0).y - camera(0).vy1, 15
px1 = player(0).x - (player(0).xsize / 2)
py1 = player(0).y - (player(0).ysize / 2)
px2 = player(0).x + (player(0).xsize / 2)
py2 = player(0).y + (player(0).ysize / 2)
DQBpset drawpage, px1 - camera(0).vx1, py1 - camera(0).vy1, 15
DQBpset drawpage, px2 - camera(0).vx1, py1 - camera(0).vy1, 15
DQBpset drawpage, px1 - camera(0).vx1, py2 - camera(0).vy1, 15
DQBpset drawpage, px2 - camera(0).vx1, py2 - camera(0).vy1, 15
DQBpset drawpage, player(0).x - camera(0).vx1, (player(0).y - player(0).ysize / 2) - camera(0).vy1, 15
DQBpset drawpage, player(0).x - camera(0).vx1, (player(0).y + player(0).ysize / 2) - camera(0).vy1, 15

'=================[ MISC TEXT INFO ]=================
'DQBprint drawpage, STR$(player(0).xv) + " " + STR$(player(0).yv), 0, 0, 15

'ptopx! = player(0).x: ptopy! = player(0).y - (player(0).ysize / 2)
'pbotx! = player(0).x: pboty! = player(0).y + (player(0).ysize / 2)
'DQBprint drawpage, "PTOP: " + STR$(ptopx!) + " " + STR$(ptopy!), 0, 10, 15
'DQBprint drawpage, "PBOT: " + STR$(pbotx!) + " " + STR$(pboty!), 0, 20, 15
'tptopx = INT(ptopx! / ts) + 1: tptopy = INT(ptopy! / ts) + 1
'tpbotx = INT(pbotx! / ts) + 1: tpboty = INT(pboty! / ts) + 1
'DQBprint drawpage, "TPTOP: " + STR$(tptopx) + " " + STR$(tptopy), 0, 30, 15
'DQBprint drawpage, "TPBOT: " + STR$(tpbotx) + " " + STR$(tpboty), 0, 40, 15
'IF TileType(Map&(tptopx, tptopy)) THEN p5 = 1 ELSE p5 = 0
'IF TileType(Map&(tpbotx, tpboty)) THEN p6 = 1 ELSE p6 = 0
'DQBprint drawpage, "TILETOP: " + STR$(TileType(Map&(tptopx, tptopy))), 0, 50, 15
'DQBprint drawpage, "TILEBOT: " + STR$(TileType(Map&(tpbotx, tpboty))), 0, 60, 15

END SUB

SUB DrawScreen

'=======[ CLEAR DRAW SPACE ]=======
DQBclearLayer drawpage

'=========[ BACKGROUND ]========
x = (camera(0).vx1 / 2) MOD 320
IF x = 0 THEN
  DQBcopyLayer backdroppage, drawpage
 ELSE
  DQBget backdroppage, 0, 0, x - 1, 199, VARSEG(scr(0)), VARPTR(scr(0))
  DQBput drawpage, 320 - x, 0, VARSEG(scr(0)), VARPTR(scr(0))
  DQBget backdroppage, x, 0, 319, 199, VARSEG(scr(0)), VARPTR(scr(0))
  DQBput drawpage, 0, 0, VARSEG(scr(0)), VARPTR(scr(0))
END IF

'=======[ TRANSLATE CAMERA ]=======
minx = INT((camera(0).vx1 / ts) + 1): subx = camera(0).vx1 MOD ts
miny = INT((camera(0).vy1 / ts) + 1): suby = camera(0).vy1 MOD ts
maxx = INT((camera(0).vx2 / ts) + 1)
maxy = INT((camera(0).vy2 / ts) + 1)

'========[ DRAW TILES ]========
FOR y = miny TO maxy
  FOR x = minx TO maxx
    px = (x - minx) * ts - subx
    py = (y - miny) * ts - suby

    t& = Map&(x, y)
    IF t& THEN
      al = AnmLength(t&)
      IF al THEN
        ad = AnmDelay(t&)
        t& = (INT(anmcounter / ad) MOD al) + t&
      END IF
      PutSprite t&, px, py, drawpage
    END IF
  NEXT x
NEXT y

'=========[ DRAW PLAYER ]=========
px = player(0).x - camera(0).vx1 - (player(0).xsize / 2)
py = player(0).y - camera(0).vy1 - (player(0).ysize / 2)
PutSprite player(0).frame, px, py, drawpage

'========[ DRAW FOREGROUND ]========
FOR y = miny TO maxy
  FOR x = minx TO maxx
    px = (x - minx) * ts - subx
    py = (y - miny) * ts - suby

    t& = MapFG&(x, y)
    IF t& THEN
      al = AnmLength(t&)
      IF al THEN
        ad = AnmDelay(t&)
        t& = (INT(anmcounter / ad) MOD al) + t&
      END IF
      PutSprite t&, px, py, drawpage
    END IF
  NEXT x
NEXT y

DrawHUD

IF gamemode = inmenu THEN DrawMenu
DQBcopyLayer drawpage, video

END SUB


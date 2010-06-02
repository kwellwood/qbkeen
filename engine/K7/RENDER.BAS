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
ErrorHandlerSub e
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
DQBpset drawpage, px1 - camera(0).vx1, player(0).y - camera(0).vy1, 15
DQBpset drawpage, px2 - camera(0).vx1, player(0).y - camera(0).vy1, 15
DQBpset drawpage, px1 - camera(0).vx1, py2 - camera(0).vy1, 15
DQBpset drawpage, px2 - camera(0).vx1, py2 - camera(0).vy1, 15
DQBpset drawpage, player(0).x - camera(0).vx1, py1 - camera(0).vy1, 15
DQBpset drawpage, player(0).x - camera(0).vx1, py2 - camera(0).vy1, 15

'=================[ MISC TEXT INFO ]=================
'DQBprint drawpage, "player(0).y: " + STR$(player(0).y) + " player(0).x: " + STR$(player(0).x), 0, 0, 14
'DQBprint drawpage, "player(0).yv: " + STR$(player(0).yv) + " player(0).xv: " + STR$(player(0).xv), 0, 10, 14

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


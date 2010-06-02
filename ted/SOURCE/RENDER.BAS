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

IF camera(0).x < 160 THEN camera(0).x = 160
IF camera(0).y < 100 THEN camera(0).y = 100
IF camera(0).x > (mapxsize * zoom) - 1 THEN camera(0).x = (mapxsize * zoom) - 1
IF camera(0).y > (mapysize * zoom) - 1 THEN camera(0).y = (mapysize * zoom) - 1

camera(0).vx1 = camera(0).x - 160: camera(0).vy1 = camera(0).y - 100
camera(0).vx2 = camera(0).vx1 + 319: camera(0).vy2 = camera(0).vy1 + 199

END SUB

SUB DrawHUD

'=================[ MISC TEXT INFO ]=================
DQBprint drawpage, "Camera(0).v1: (" + STR$(camera(0).vx1) + "," + STR$(camera(0).vy1) + ")", 200, 0, 15
DQBprint drawpage, "Camera(0).v2: (" + STR$(camera(0).vx2) + "," + STR$(camera(0).vy2) + ")", 200, 10, 15
DQBline drawpage, 198, 18, 318, 18, 15
DQBprint drawpage, "ActiveItemStack(0):" + STR$(LEN(activeitemstack(0))), 200, 20, 15
DQBprint drawpage, "ActivePortalStack(0):" + STR$(LEN(activeportalstack(0))), 200, 30, 15
DQBprint drawpage, "ActiveFoeStack(0):" + STR$(LEN(activefoestack(0))), 200, 40, 15
DQBline drawpage, 198, 48, 318, 48, 15

mx = (DQBmouseX + camera(0).vx1) * (ts / zoom): my = (DQBmouseY + camera(0).vy1) * (ts / zoom)
DQBprint drawpage, "Mouse: (" + STR$(mx) + "," + STR$(my) + ")", 200, 50, 15
DQBprint drawpage, "Map: (" + STR$(INT(mx / zoom + 1)) + "," + STR$(INT(my / zoom + 1)) + ")", 200, 60, 15

END SUB

SUB DrawMarkerBox (x, y, xsize, ysize, c)

x1 = (x / (ts / zoom)) - camera(0).vx1 - (xsize / 2) / (ts / zoom)
y1 = (y / (ts / zoom)) - camera(0).vy1 - (ysize / 2) / (ts / zoom)
x2 = (x / (ts / zoom)) - camera(0).vx1 + (xsize / 2) / (ts / zoom)
y2 = (y / (ts / zoom)) - camera(0).vy1 + (ysize / 2) / (ts / zoom)
DQBbox drawpage, x1, y1, x2, y2, c

END SUB

SUB DrawScreen

DQBmouseHide
DQBclearLayer drawpage

'=======[ TRANSLATE CAMERA ]=======
minx = INT((camera(0).vx1 / zoom) + 1): subx = camera(0).vx1 MOD zoom
miny = INT((camera(0).vy1 / zoom) + 1): suby = camera(0).vy1 MOD zoom
maxx = INT((camera(0).vx2 / zoom) + 1)
maxy = INT((camera(0).vy2 / zoom) + 1)

'========[ DRAW TILES ]========
FOR y = miny TO maxy
  FOR x = minx TO maxx
    px = (x - minx) * zoom - subx
    py = (y - miny) * zoom - suby

    IF tlvisible THEN
      t& = Map&(x, y)
      t2& = MapFG&(x, y)
      IF t& THEN
        al = AnmLength(t&)
       
        IF zoom < ts THEN PutSpriteS t&, px, py, zoom, zoom, drawpage ELSE PutSprite t&, px, py, drawpage
        IF t2& AND (TileType2(t2&) = 1 OR TileType2(t2&) = 14) THEN
          IF zoom < ts THEN PutSpriteS t2&, px, py, zoom, zoom, drawpage ELSE PutSprite t2&, px, py, drawpage
        END IF

        IF zoom = ts THEN
          IF al AND TileType2(t2&) <> 14 THEN DQBprint drawpage, "A", px + (ts / 2) - 3, py + (ts / 2) - 4, 15
          IF TileType2(t2&) = 14 THEN DQBprint drawpage, "C", px + (ts / 2) - 3, py + (ts / 2) - 4, 15
          IF TileType(t&) = 4 THEN DQBprint drawpage, "S", px + (ts / 2) - 3, py + (ts / 2) - 4, 15
        END IF
      END IF
    END IF

    IF fgvisible THEN
      t2& = MapFG&(x, y)
      IF t2& AND TileType2(t2&) <> 1 AND TileType2(t2&) <> 14 THEN
        al = AnmLength(t2&)
        PutSpriteS t2&, px, py, zoom, zoom, drawpage
        IF al AND zoom = ts THEN DQBprint drawpage, "A", px + (ts / 2) - 3, py + (ts / 2) - 4, 15
       ELSEIF t2& AND (TileType2(t2&) = 1 OR TileType2(t2&) = 14) AND tlvisible = 0 THEN
        al = AnmLength(t2&)
        PutSpriteS t2&, px, py, zoom, zoom, drawpage
        IF al AND zoom = ts AND TileType2(t2&) <> 14 THEN DQBprint drawpage, "A", px + (ts / 2) - 3, py + (ts / 2) - 4, 15
        IF zoom = ts AND TileType2(t2&) = 14 THEN DQBprint drawpage, "C", px + (ts / 2) - 3, py + (ts / 2) - 4, 15
      END IF
    END IF
 
    '--- view switch tags ---
    IF objmode = 8 AND x <= mapxsize AND y <= mapysize AND zoom = ts THEN
      IF SwitchTag&(x, y) > 0 THEN
        x1 = px + camera(0).vx1: y1 = py + camera(0).vy1
        x2 = px + zoom - 1 + camera(0).vx1: y2 = py + zoom - 1 + camera(0).vy1
        IF OnScreen2(x1, y1, x2, y2) THEN
          DQBprint drawpage, LTRIM$(STR$(SwitchTag&(x, y))), px + 2, py + 2, 16
          DQBbox drawpage, px, py, px + zoom - 1, py + zoom - 1, 16
        END IF
      END IF
    END IF
  NEXT x
NEXT y

DrawEnemies
DrawItems
DrawPortals
DrawLifts
DrawLocators
'---- draw player marker ----
IF (player(0).x / (ts / zoom)) - (zoom / 2) >= camera(0).vx1 AND (player(0).x / (ts / zoom)) + (zoom / 2) <= camera(0).vx2 THEN
  IF (player(0).y / (ts / zoom)) - (zoom / 2) >= camera(0).vy1 AND (player(0).y / (ts / zoom)) + (zoom / 2) <= camera(0).vy2 THEN
    IF player(0).xdir = left THEN playerdir$ = "<P"
    IF player(0).xdir = right THEN playerdir$ = "P>"
    DQBprint drawpage, playerdir$, (player(0).x / (ts / zoom)) - camera(0).vx1 - 2, (player(0).y / (ts / zoom)) - camera(0).vy1 - 3, 32
    DQBbox drawpage, (player(0).x / (ts / zoom)) - camera(0).vx1 - (zoom / 2), (player(0).y / (ts / zoom)) - camera(0).vy1 - (zoom / 2), (player(0).x / (ts / zoom)) - camera(0).vx1 + (zoom / 2), (player(0).y / (ts / zoom)) - camera(0).vy1 + (zoom /  _
2), 32
  END IF
END IF
'----------------------------

IF DQBkey(59) THEN DrawHUD
IF gamemode = inmenu THEN DrawMenu

IF ems THEN DQBcopyLayer drawpage, video

DQBmouseShow

END SUB

FUNCTION OnScreen (x, y, xsize, ysize)

x1 = (x - (xsize / 2)) / (ts / zoom)
x2 = (x + (xsize / 2)) / (ts / zoom)
y1 = (y - (ysize / 2)) / (ts / zoom)
y2 = (y + (ysize / 2)) / (ts / zoom)

IF x1 >= camera(0).vx1 AND x2 <= camera(0).vx2 THEN
  IF y1 >= camera(0).vy1 AND y2 <= camera(0).vy2 THEN
    OnScreen = 1
   ELSE OnScreen = 0
  END IF
 ELSE OnScreen = 0
END IF

END FUNCTION

FUNCTION OnScreen2 (x1, y1, x2, y2)

IF x1 >= camera(0).vx1 AND x2 <= camera(0).vx2 THEN
  IF y1 >= camera(0).vy1 AND y2 <= camera(0).vy2 THEN
    OnScreen2 = 1
   ELSE OnScreen2 = 0
  END IF
 ELSE OnScreen2 = 0
END IF

END FUNCTION


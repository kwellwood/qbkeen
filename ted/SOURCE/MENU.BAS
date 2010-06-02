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

CheckFile:
RESUME NEXT

REM $STATIC
SUB CreatePulldown

DrawBox2 43, 0, 75, 9
DQBprint drawpage, "Create", 45, 2, 16

DrawBox 43, 10, 85, 35
IF objmode = 7 THEN c1 = 71: c2 = 28 ELSE c1 = 14: c2 = 22
DQBboxf drawpage, 44, 11, 84, 18, c2
DQBprint drawpage, "Lift", 45, 12, c1
IF objmode = 6 THEN c1 = 71: c2 = 28 ELSE c1 = 14: c2 = 22
DQBboxf drawpage, 44, 19, 84, 26, c2
DQBprint drawpage, "Locator", 45, 20, c1
IF objmode = 5 THEN c1 = 71: c2 = 28 ELSE c1 = 14: c2 = 22
DQBboxf drawpage, 44, 27, 84, 34, c2
DQBprint drawpage, "Portal", 45, 28, c1
DrawpageToVideo

WHILE DQBmouseLB: WEND

DO
  '--- abort the pulldown menu ---
  IF DQBmouseRB THEN commandreceived = -1

  '--- click on menu item or abort ---
  IF DQBmouseLB THEN
    mx = DQBmouseX: my = DQBmouseY: commandreceived = -1
    IF InArea(mx, my, 43, 11, 85, 18) THEN commandreceived = 1   'new map
    IF InArea(mx, my, 43, 19, 85, 26) THEN commandreceived = 2   'save map
    IF InArea(mx, my, 43, 27, 85, 34) THEN commandreceived = 3   'load map
  END IF
LOOP UNTIL commandreceived

SELECT CASE commandreceived
 CASE -1
  WHILE DQBmouseLB: WEND: WHILE DQBmouseRB: WEND
 CASE 1 '---------------------------------------------------------[ LIFT ]---
  DQBboxf drawpage, 44, 11, 84, 18, 148
  DQBprint drawpage, "Lift", 45, 12, 15
  DrawpageToVideo
  WHILE DQBmouseLB: WEND: WHILE DQBmouseRB: WEND
  IF InArea(DQBmouseX, DQBmouseY, 43, 11, 85, 18) = 0 THEN EXIT SUB

  IF objmode <> 7 THEN objmode = 7 ELSE objmode = 0
  curitem = 0
 CASE 2 '------------------------------------------------------[ LOCATOR ]---
  DQBboxf drawpage, 44, 19, 84, 26, 148
  DQBprint drawpage, "Locator", 45, 20, 15
  DrawpageToVideo
  WHILE DQBmouseLB: WEND: WHILE DQBmouseRB: WEND
  IF InArea(DQBmouseX, DQBmouseY, 43, 19, 85, 26) = 0 THEN EXIT SUB
 
  IF objmode <> 6 THEN objmode = 6 ELSE objmode = 0
  curitem = 0
 CASE 3 '-------------------------------------------------------[ PORTAL ]---
  DQBboxf drawpage, 44, 27, 84, 34, 148
  DQBprint drawpage, "Portal", 45, 28, 15
  DrawpageToVideo
  WHILE DQBmouseLB: WEND: WHILE DQBmouseRB: WEND
  IF InArea(DQBmouseX, DQBmouseY, 43, 27, 85, 34) = 0 THEN EXIT SUB

  IF objmode <> 5 THEN objmode = 5 ELSE objmode = 0
  curitem = 0
END SELECT

END SUB

SUB DrawBox (x1, y1, x2, y2)

DQBboxf drawpage, x1 + 1, y1 + 1, x2 - 1, y2 - 1, 22  'fill center

DQBline drawpage, x1, y1, x2, y1, 20 'top
DQBline drawpage, x1, y2, x2, y2, 24 'bottom
DQBline drawpage, x1, y1, x1, y2, 20 'left
DQBline drawpage, x2, y1, x2, y2, 24 'right
DQBpset drawpage, x2, y1, 21         'top right
DQBpset drawpage, x1, y2, 21         'bottom left

END SUB

SUB DrawBox2 (x1, y1, x2, y2)

DQBboxf drawpage, x1, y1, x2, y2, 23 'filler
DQBline drawpage, x1, y1, x2, y1, 24 'top
DQBline drawpage, x1, y2, x2, y2, 20 'bottom
DQBline drawpage, x1, y1, x1, y2, 24 'left
DQBline drawpage, x2, y1, x2, y2, 20 'right
DQBpset drawpage, x2, y1, 23         'top right
DQBpset drawpage, x1, y2, 23         'bottom left

END SUB

SUB DrawMenu

'====[ MENU BOX ]====
DQBboxf drawpage, 0, 0, 319, 17, 22
DQBline drawpage, 0, 17, 319, 17, 24

'====[ PULLDOWN MENUS ]====
DrawBox 0, 0, 20, 9
DQBprint drawpage, "File", 2, 2, 14
DrawBox 21, 0, 42, 9
DQBprint drawpage, "Edit", 23, 2, 14
DrawBox 43, 0, 75, 9
DQBprint drawpage, "Create", 45, 2, 14

'====[ ADJUSTMENT BUTTONS ]====
DrawBox 156, 0, 196, 8
DQBprint drawpage, "Track:" + LTRIM$(STR$(currentTrack)), 158, 2, 14
IF objmode = 1 THEN
  DrawBox 139, 9, 196, 17
  DQBprint drawpage, "Offset:" + LTRIM$(STR$(matrixoffset(curitem).x)) + "," + LTRIM$(STR$(matrixoffset(curitem).y)), 141, 10, 14
END IF

'====[ LAYER BUTTONS ]====
DrawBox 197, 0, 221, 8
IF tlvisible THEN DQBboxf drawpage, 198, 1, 220, 7, 32 ELSE DQBboxf drawpage, 198, 1, 220, 7, 38
DQBprint drawpage, "L1", 205, 2, 15
DrawBox 197, 9, 221, 17
IF fgvisible THEN DQBboxf drawpage, 198, 10, 220, 16, 32 ELSE DQBboxf drawpage, 198, 10, 220, 16, 38
DQBprint drawpage, "L2", 204, 11, 15

'====[ CURRENT ENEMY ]====
DrawBox 222, 0, 239, 17
IF objmode = 3 THEN
  xs = TileXSize(eframe(curitem))
  ys = TileYSize(eframe(curitem))
  IF xs > 16 OR ys > 16 THEN
    PutTileS eframe(curitem), 223, 1, 16, 16, drawpage
   ELSE
    PutTile eframe(curitem), 223, 1, drawpage
  END IF
 ELSE
  DQBprint drawpage, "EN", 225, 6, 15
END IF

'====[ CURRENT ITEM ]====
DrawBox 240, 0, 257, 17
IF objmode = 2 THEN
  xs = TileXSize(bonus(curitem).sframe)
  ys = TileYSize(bonus(curitem).sframe)
  IF xs > 16 OR ys > 16 THEN
    PutTileS bonus(curitem).sframe, 241, 1, 16, 16, drawpage
   ELSE
    PutTile bonus(curitem).sframe, 241, 1, drawpage
  END IF
 ELSE
  DQBprint drawpage, "IT", 243, 6, 15
END IF

'====[ CURRENT MATRIX ]====
DrawBox 258, 0, 275, 17
IF objmode = 1 THEN
  xs = TileXSize(matrix(1, 1))
  ys = TileYSize(matrix(1, 1))
  IF xs > 16 OR ys > 16 THEN
    PutTileS matrix(1, 1), 259, 1, 16, 16, drawpage
   ELSE
    PutTile matrix(1, 1), 259, 1, drawpage
  END IF
  DQBprint drawpage, LTRIM$(RTRIM$(STR$(curitem))), 261, 6, 15
 ELSE
  DQBprint drawpage, "MA", 261, 6, 15
END IF

'====[ CURRENT TILE ]====
DrawBox 276, 0, 319, 17
IF pentile& THEN
  xs = TileXSize(pentile&)
  ys = TileYSize(pentile&)
  IF xs > 16 OR ys > 16 THEN
    PutTileS pentile&, 303, 1, 16, 16, drawpage
   ELSE
    PutTile pentile&, 303, 1, drawpage
  END IF
 ELSE
  DQBboxf drawpage, 303, 1, 318, 16, 0
END IF
DQBprint drawpage, LTRIM$(RTRIM$(STR$(pentile&))), 278, 2, 15
DQBprint drawpage, TileDescrip$(TileType(pentile&)), 278, 10, 15

END SUB

SUB EditPulldown

DrawBox2 21, 0, 42, 9
DQBprint drawpage, "Edit", 23, 2, 16

DrawBox 21, 10, 92, 51
DQBprint drawpage, "Music", 23, 12, 14
IF objmode = 4 THEN c1 = 71: c2 = 28 ELSE c1 = 14: c2 = 22
DQBboxf drawpage, 22, 19, 91, 26, c2
DQBprint drawpage, "Player Start", 23, 20, c1
IF objmode = 8 THEN c1 = 71: c2 = 28 ELSE c1 = 14: c2 = 22
DQBboxf drawpage, 22, 27, 91, 34, c2
DQBprint drawpage, "Switch Tags", 23, 28, c1
DQBprint drawpage, "Replace Tiles", 23, 36, 14
IF gridsnapitems THEN c1 = 71: c2 = 28 ELSE c1 = 14: c2 = 22
DQBboxf drawpage, 22, 43, 91, 50, c2
DQBprint drawpage, "Gridsnap Items", 23, 44, c1
DrawpageToVideo

WHILE DQBmouseLB: WEND

DO
  '--- abort the pulldown menu ---
  IF DQBmouseRB THEN commandreceived = -1

  '--- click on menu item or abort ---
  IF DQBmouseLB THEN
    mx = DQBmouseX: my = DQBmouseY: commandreceived = -1
    IF InArea(mx, my, 21, 11, 92, 18) THEN commandreceived = 1  'music
    IF InArea(mx, my, 21, 19, 92, 26) THEN commandreceived = 2  'player start
    IF InArea(mx, my, 21, 27, 92, 34) THEN commandreceived = 3  'switch tags
    IF InArea(mx, my, 21, 35, 92, 42) THEN commandreceived = 4  'replace tiles
    IF InArea(mx, my, 21, 43, 92, 50) THEN commandreceived = 5  'gridsnap item
  END IF
LOOP UNTIL commandreceived

SELECT CASE commandreceived
 CASE -1
  WHILE DQBmouseLB: WEND: WHILE DQBmouseRB: WEND
 CASE 1 '--------------------------------------------------------[ MUSIC ]---
  DQBboxf drawpage, 22, 11, 91, 18, 148
  DQBprint drawpage, "Music", 23, 12, 15
  DrawpageToVideo
  WHILE DQBmouseLB: WEND: WHILE DQBmouseRB: WEND
  IF InArea(DQBmouseX, DQBmouseY, 21, 11, 92, 18) = 0 THEN EXIT SUB
  MenuEditMusic
 CASE 2 '-------------------------------------------------[ PLAYER START ]---
  DQBboxf drawpage, 22, 19, 91, 26, 148
  DQBprint drawpage, "Player Start", 23, 20, 15
  DrawpageToVideo
  WHILE DQBmouseLB: WEND: WHILE DQBmouseRB: WEND
  IF InArea(DQBmouseX, DQBmouseY, 21, 19, 92, 26) = 0 THEN EXIT SUB
 
  IF objmode <> 4 THEN objmode = 4 ELSE objmode = 0
  curitem = 0
 CASE 3 '--------------------------------------------------[ SWITCH TAGS ]---
  DQBboxf drawpage, 22, 27, 91, 34, 148
  DQBprint drawpage, "Switch Tags", 23, 28, 15
  DrawpageToVideo
  WHILE DQBmouseLB: WEND: WHILE DQBmouseRB: WEND
  IF InArea(DQBmouseX, DQBmouseY, 21, 27, 92, 34) = 0 THEN EXIT SUB

  IF objmode <> 8 THEN objmode = 8 ELSE objmode = 0
  curitem = 0
 CASE 4 '------------------------------------------------[ REPLACE TILES ]---
  DQBboxf drawpage, 22, 35, 91, 42, 148
  DQBprint drawpage, "Replace Tiles", 23, 36, 15
  DrawpageToVideo
  WHILE DQBmouseLB: WEND: WHILE DQBmouseRB: WEND
  IF InArea(DQBmouseX, DQBmouseY, 21, 35, 92, 42) = 0 THEN EXIT SUB
  MenuEditReplace
 CASE 5 '-----------------------------------------------[ GRIDSNAP ITEMS ]---
  DQBboxf drawpage, 22, 43, 91, 50, 148
  DQBprint drawpage, "Gridsnap Items", 23, 44, 15
  DrawpageToVideo
  WHILE DQBmouseLB: WEND: WHILE DQBmouseRB: WEND
  IF InArea(DQBmouseX, DQBmouseY, 21, 43, 92, 50) = 0 THEN EXIT SUB
  IF gridsnapitems THEN gridsnapitems = 0 ELSE gridsnapitems = 1
END SELECT

END SUB

SUB EnemyPulldown

DrawBox2 222, 0, 239, 17
IF objmode = 3 THEN
  xs = TileXSize(eframe(curitem))
  ys = TileYSize(eframe(curitem))
  IF xs > 16 OR ys > 16 THEN
    PutTileS eframe(curitem), 223, 1, 16, 16, drawpage
   ELSE
    PutTile eframe(curitem), 223, 1, drawpage
  END IF
 ELSE
  DQBprint drawpage, "EN", 225, 6, 16
END IF

boxYsize = numenemytypes                   ' calculate the size
IF boxYsize > 10 THEN boxYsize = 10        ' of the dropdown grid
x! = numenemytypes / 10                    '
boxXsize = FIX(x!) - (x! - FIX(x!) > 0)    '

DrawBox 222, 18, 222 + boxXsize * 17, 18 + boxYsize * 17
FOR col = 1 TO boxXsize
  FOR row = 1 TO boxYsize
    e = (col - 1) * 10 + row
    IF e <= numenemytypes THEN
      xs = TileXSize(eframe(e))
      ys = TileYSize(eframe(e))
      IF xs > 16 OR ys > 16 THEN
        PutTileS eframe(e), 223 + (col - 1) * 17, 19 + (row - 1) * 17, 16, 16, drawpage
       ELSE
        DQBboxf drawpage, 223 + (col - 1) * 17, 19 + (row - 1) * 17, 223 + (col - 1) * 17 + 15, 19 + (row - 1) * 17 + 15, 148
        PutTile eframe(e), 223 + (col - 1) * 17, 19 + (row - 1) * 17, drawpage
      END IF
    END IF
  NEXT row
NEXT col
DrawpageToVideo

WHILE DQBmouseLB: WEND

DO
  '--- abort the pulldown menu ---
  IF DQBmouseRB THEN commandreceived = -1

  '--- click on menu item or abort ---
  IF DQBmouseLB THEN
    mx = DQBmouseX: my = DQBmouseY: commandreceived = -1
  
    FOR col = 1 TO boxXsize
      FOR row = 1 TO boxYsize
        e = (col - 1) * 10 + row
        IF e <= numenemytypes THEN
          IF InArea(mx, my, 223 + (col - 1) * 17, 19 + (row - 1) * 17, 223 + (col - 1) * 17 + 15, 19 + (row - 1) * 17 + 15) THEN commandreceived = e: erow = row: ecol = col
        END IF
      NEXT row
    NEXT col
  END IF
LOOP UNTIL commandreceived

SELECT CASE commandreceived
 CASE -1
  WHILE DQBmouseLB: WEND: WHILE DQBmouseRB: WEND
 CASE ELSE '----------------------------------------------[ SELECT ENEMY ]---
  DQBboxf drawpage, 223 + (ecol - 1) * 17, 19 + (erow - 1) * 17, 223 + (ecol - 1) * 17 + 15, 19 + (erow - 1) * 17 + 15, 148
  DrawpageToVideo
  WHILE DQBmouseLB: WEND: WHILE DQBmouseRB: WEND
  IF InArea(DQBmouseX, DQBmouseY, 223 + (ecol - 1) * 17, 19 + (erow - 1) * 17, 223 + (ecol - 1) * 17 + 15, 19 + (erow - 1) * 17 + 15) = 0 THEN EXIT SUB
  objmode = 3: curitem = commandreceived
END SELECT

END SUB

SUB FilePulldown

DrawBox2 0, 0, 20, 9
DQBprint drawpage, "File", 2, 2, 16

DrawBox 0, 10, 49, 43
DQBprint drawpage, "New Map", 2, 12, 14
DQBprint drawpage, "Save Map", 2, 20, 14
DQBprint drawpage, "Load Map", 2, 28, 14
DQBprint drawpage, "Quit", 2, 36, 14
DrawpageToVideo

WHILE DQBmouseLB: WEND

DO
  '--- abort the pulldown menu ---
  IF DQBmouseRB THEN commandreceived = -1
 
  '--- click on menu item or abort ---
  IF DQBmouseLB THEN
    mx = DQBmouseX: my = DQBmouseY: commandreceived = -1
    IF InArea(mx, my, 0, 11, 49, 18) THEN commandreceived = 1   'new map
    IF InArea(mx, my, 0, 19, 49, 26) THEN commandreceived = 2   'save map
    IF InArea(mx, my, 0, 27, 49, 34) THEN commandreceived = 3   'load map
    IF InArea(mx, my, 0, 35, 49, 42) THEN commandreceived = 4   'quit
  END IF
LOOP UNTIL commandreceived

SELECT CASE commandreceived
 CASE -1
  WHILE DQBmouseLB: WEND: WHILE DQBmouseRB: WEND
 CASE 1 '------------------------------------------------------[ NEW MAP ]---
  DQBboxf drawpage, 1, 11, 48, 18, 148
  DQBprint drawpage, "New Map", 2, 12, 15
  DrawpageToVideo
  WHILE DQBmouseLB: WEND: WHILE DQBmouseRB: WEND
  IF InArea(DQBmouseX, DQBmouseY, 0, 11, 49, 18) = 0 THEN EXIT SUB
  MenuFileNewMap
 CASE 2 '-----------------------------------------------------[ SAVE MAP ]---
  DQBboxf drawpage, 1, 19, 48, 26, 148
  DQBprint drawpage, "Save Map", 2, 20, 15
  DrawpageToVideo
  WHILE DQBmouseLB: WEND: WHILE DQBmouseRB: WEND
  IF InArea(DQBmouseX, DQBmouseY, 0, 19, 49, 26) = 0 THEN EXIT SUB
  MenuFileSaveMap
 CASE 3 '-----------------------------------------------------[ LOAD MAP ]---
  DQBboxf drawpage, 1, 27, 48, 34, 148
  DQBprint drawpage, "Load Map", 2, 28, 15
  DrawpageToVideo
  WHILE DQBmouseLB: WEND: WHILE DQBmouseRB: WEND
  IF InArea(DQBmouseX, DQBmouseY, 0, 27, 49, 34) = 0 THEN EXIT SUB
  MenuFileLoadMap
 CASE 4 '---------------------------------------------------------[ QUIT ]---
  DQBboxf drawpage, 1, 35, 48, 42, 148
  DQBprint drawpage, "Quit", 2, 36, 15
  DrawpageToVideo
  WHILE DQBmouseLB: WEND: WHILE DQBmouseRB: WEND
  IF InArea(DQBmouseX, DQBmouseY, 0, 35, 49, 42) = 0 THEN EXIT SUB
  quitgame = 1
END SELECT

END SUB

FUNCTION GetFile$ (x, y)
DQBremoveKeyboard
DQBmouseHide

Inpt$ = "": length = 0: textx = x: texty = y
DQBget drawpage, textx, texty, textx + 80, texty + 8, VARSEG(scr(0)), VARPTR(scr(0))

DO
  kbd$ = INKEY$
  IF kbd$ <> "" THEN
    SELECT CASE kbd$
     CASE CHR$(8)
      IF length > 0 THEN length = length - 1
      Inpt$ = LEFT$(Inpt$, length)
      DQBfPut drawpage, textx, texty, VARSEG(scr(0)), VARPTR(scr(0))
     CASE CHR$(13)
      EXIT DO
     CASE CHR$(27)
      Inpt$ = "": EXIT DO
     CASE ELSE
      IF ASC(kbd$) > 31 AND ASC(kbd$) < 127 THEN
        IF length < 13 THEN
          Inpt$ = Inpt$ + kbd$
          length = length + 1
        END IF
      END IF
    END SELECT
    DQBprint drawpage, Inpt$, textx, texty, 15
    DQBcopyLayer drawpage, video
  END IF
LOOP

GetFile$ = Inpt$
DQBsetMousePos llcx, llcy
DQBmouseShow
DQBinstallKeyboard

END FUNCTION

FUNCTION GetNumber$ (x, y)
DQBremoveKeyboard
DQBmouseHide

Inpt$ = "": length = 0: textx = x: texty = y
DQBget drawpage, textx, texty, textx + 80, texty + 8, VARSEG(scr(0)), VARPTR(scr(0))

DO
  kbd$ = INKEY$
  IF kbd$ <> "" THEN
    SELECT CASE kbd$
     CASE CHR$(8)
      IF length > 0 THEN length = length - 1
      Inpt$ = LEFT$(Inpt$, length)
      DQBfPut drawpage, textx, texty, VARSEG(scr(0)), VARPTR(scr(0))
     CASE CHR$(13)
      EXIT DO
     CASE CHR$(27)
      Inpt$ = "0": EXIT DO
     CASE ELSE
      IF ASC(kbd$) > 47 AND ASC(kbd$) < 58 THEN
        IF length < 6 THEN
          Inpt$ = Inpt$ + kbd$
          length = length + 1
        END IF
      END IF
    END SELECT
    DQBprint drawpage, Inpt$, textx, texty, 15
    DQBcopyLayer drawpage, video
  END IF
LOOP

GetNumber$ = LTRIM$(RTRIM$(Inpt$))
DQBsetMousePos llcx, llcy
DQBmouseShow
DQBinstallKeyboard

END FUNCTION

SUB HandleMenuInput (mx, my, mb)

'objmode tags:
'0 tiles
'1 matrix
'2 item
'3 enemy
'4 player start
'5 teleport
'6 locator
'7 lift
'8 set location tag

IF InArea(mx, my, 0, 0, 20, 9) THEN button = 1        ' file pulldown
IF InArea(mx, my, 21, 0, 42, 9) THEN button = 2       ' edit pulldown
IF InArea(mx, my, 43, 0, 69, 9) THEN button = 3       ' place pulldown
IF InArea(mx, my, 276, 0, 319, 17) THEN button = 7    ' tilelist
IF InArea(mx, my, 197, 0, 221, 8) THEN button = 8     ' layer 1
IF InArea(mx, my, 197, 9, 221, 17) THEN button = 9    ' layer 2
IF InArea(mx, my, 258, 0, 275, 17) THEN button = 10   ' matrix select
IF InArea(mx, my, 240, 0, 257, 17) THEN button = 11   ' item select
IF InArea(mx, my, 222, 0, 239, 17) THEN button = 12   ' enemy select
IF InArea(mx, my, 156, 0, 196, 8) THEN button = 13    ' platform track
IF InArea(mx, my, 139, 9, 196, 17) THEN button = 18   ' change matrix offset

SELECT CASE button
 CASE 1: IF mb = left THEN FilePulldown: refresh = 1
 CASE 2: IF mb = left THEN EditPulldown: refresh = 1
 CASE 3: IF mb = left THEN CreatePulldown: refresh = 1
 CASE 7
   IF mb = left THEN SelectTile
   refresh = 1
 CASE 8
  IF mb = left THEN
    IF tlvisible = 1 THEN tlvisible = 0 ELSE tlvisible = 1
    WHILE DQBmouseLB: WEND
    refresh = 1
  END IF
 CASE 9
  IF mb = left THEN
    IF fgvisible = 1 THEN fgvisible = 0 ELSE fgvisible = 1
    WHILE DQBmouseLB: WEND
    refresh = 1
  END IF
 CASE 10
  IF mb = left THEN
    MatrixPulldown
   ELSEIF mb = right THEN
    IF objmode = 1 THEN objmode = 0: curitem = 0
    WHILE DQBmouseRB: WEND
  END IF
  refresh = 1
 CASE 11
  IF mb = left THEN ItemPulldown
  IF mb = right THEN
    IF objmode = 2 THEN objmode = 0: curitem = 0
    WHILE DQBmouseRB: WEND
  END IF
  refresh = 1
 CASE 12
  IF mb = left THEN EnemyPulldown
  IF mb = right THEN
    IF objmode = 3 THEN objmode = 0: curitem = 0
    WHILE DQBmouseRB: WEND
  END IF
  refresh = 1
 CASE 13
  IF mb = left THEN
    currentTrack = currentTrack + 1
    IF currentTrack > 16 THEN currentTrack = 1
    WHILE DQBmouseLB: WEND
   ELSEIF mb = right THEN
    currentTrack = currentTrack - 1
    IF currentTrack < 1 THEN currentTrack = 16
    WHILE DQBmouseRB: WEND
  END IF
  refresh = 1
 CASE 18
  IF mb = left THEN
    IF objmode = 1 THEN
      DQBbox drawpage, 126, 93, 195, 105, 15
      DQBboxf drawpage, 127, 94, 194, 104, 14
      DrawpageToVideo
      F$ = GetNumber$(129, 96)
      IF F$ <> "" THEN matrixoffset(curitem).x = VAL(F$)
      DQBbox drawpage, 126, 93, 195, 105, 15
      DQBboxf drawpage, 127, 94, 194, 104, 14
      DrawpageToVideo
      F$ = GetNumber$(129, 96)
      IF F$ <> "" THEN matrixoffset(curitem).y = VAL(F$)
      IF matrixoffset(curitem).x >= mxsize THEN matrixoffset(curitem).x = mxsize - 1
      IF matrixoffset(curitem).x <= -mxsize THEN matrixoffset(curitem).x = -mxsize + 1
      IF matrixoffset(curitem).y >= mysize THEN matrixoffset(curitem).y = mysize - 1
      IF matrixoffset(curitem).y <= -mysize THEN matrixoffset(curitem).y = -mysize + 1
      refresh = 1
    END IF
  END IF
END SELECT

END SUB

FUNCTION InArea (x, y, x1, y1, x2, y2)

IF x >= x1 AND x <= x2 AND y >= y1 AND y <= y2 THEN InArea = 1 ELSE InArea = 0

END FUNCTION

SUB ItemPulldown

DrawBox2 240, 0, 257, 17
IF objmode = 2 THEN
  xs = TileXSize(bonus(curitem).sframe)
  ys = TileYSize(bonus(curitem).sframe)
  IF xs > 16 OR ys > 16 THEN
    PutTileS bonus(curitem).sframe, 241, 1, 16, 16, drawpage
   ELSE
    PutTile bonus(curitem).sframe, 241, 1, drawpage
  END IF
 ELSE
  DQBprint drawpage, "IT", 243, 6, 16
END IF

boxYsize = numitemtypes                    ' calculate the size
IF boxYsize > 10 THEN boxYsize = 10        ' of the dropdown grid
x! = numitemtypes / 10                     '
boxXsize = FIX(x!) - (x! - FIX(x!) > 0)    '

DrawBox 240, 18, 240 + boxXsize * 17, 18 + boxYsize * 17
FOR col = 1 TO boxXsize
  FOR row = 1 TO boxYsize
    i = (col - 1) * 10 + row
    IF i <= numitemtypes THEN
      xs = TileXSize(bonus(i).sframe)
      ys = TileYSize(bonus(i).sframe)
      IF xs > 16 OR ys > 16 THEN
        PutTileS bonus(i).sframe, 241 + (col - 1) * 17, 19 + (row - 1) * 17, 16, 16, drawpage
       ELSE
        DQBboxf drawpage, 241 + (col - 1) * 17, 19 + (row - 1) * 17, 241 + (col - 1) * 17 + 15, 19 + (row - 1) * 17 + 15, 148
        PutTile bonus(i).sframe, 241 + (col - 1) * 17, 19 + (row - 1) * 17, drawpage
      END IF
    END IF
  NEXT row
NEXT col
DrawpageToVideo

WHILE DQBmouseLB: WEND

DO
  '--- abort the pulldown menu ---
  IF DQBmouseRB THEN commandreceived = -1

  '--- click on menu item or abort ---
  IF DQBmouseLB THEN
    mx = DQBmouseX: my = DQBmouseY: commandreceived = -1
 
    FOR col = 1 TO boxXsize
      FOR row = 1 TO boxYsize
        i = (col - 1) * 10 + row
        IF i <= numitemtypes THEN
          IF InArea(mx, my, 241 + (col - 1) * 17, 19 + (row - 1) * 17, 241 + (col - 1) * 17 + 15, 19 + (row - 1) * 17 + 15) THEN commandreceived = i: irow = row: icol = col
        END IF
      NEXT row
    NEXT col
  END IF
LOOP UNTIL commandreceived

SELECT CASE commandreceived
 CASE -1
  WHILE DQBmouseLB: WEND: WHILE DQBmouseRB: WEND
 CASE ELSE '-----------------------------------------------[ SELECT ITEM ]---
  DQBboxf drawpage, 241 + (icol - 1) * 17, 19 + (irow - 1) * 17, 241 + (icol - 1) * 17 + 15, 19 + (irow - 1) * 17 + 15, 148
  DrawpageToVideo
  WHILE DQBmouseLB: WEND: WHILE DQBmouseRB: WEND
  IF InArea(DQBmouseX, DQBmouseY, 241 + (icol - 1) * 17, 19 + (irow - 1) * 17, 241 + (icol - 1) * 17 + 15, 19 + (irow - 1) * 17 + 15) = 0 THEN EXIT SUB
  objmode = 2: curitem = commandreceived
END SELECT

END SUB

SUB MatrixPulldown

DrawBox2 258, 0, 275, 17
IF objmode = 1 THEN
  xs = TileXSize(matrix(1, 1))
  ys = TileYSize(matrix(1, 1))
  IF xs > 16 OR ys > 16 THEN
    PutTileS matrix(1, 1), 259, 1, 20, 20, drawpage
   ELSE
    PutTile matrix(1, 1), 259, 1, drawpage
  END IF
  DQBprint drawpage, LTRIM$(RTRIM$(STR$(curitem))), 261, 6, 15
 ELSE
  DQBprint drawpage, "MA", 261, 6, 16
END IF

boxYsize = matrices                        ' calculate the size
IF boxYsize > 10 THEN boxYsize = 10        ' of the dropdown grid
x! = matrices / 10                         '
boxXsize = FIX(x!) - (x! - FIX(x!) > 0)    '

DrawBox 258, 18, 258 + boxXsize * 17, 18 + boxYsize * 17
FOR col = 1 TO boxXsize
  FOR row = 1 TO boxYsize
    m = (col - 1) * 10 + row
    IF m <= matrices THEN
      '-- Get topleft tile of matrix --
      OPEN ".\matrices\matrix." + LTRIM$(RTRIM$(STR$(m))) FOR INPUT AS 1
        INPUT #1, temp
        INPUT #1, temp
        INPUT #1, mtile&
      CLOSE 1
      xs = TileXSize(mtile&)
      ys = TileYSize(mtile&)
      IF xs > 16 OR ys > 16 THEN
        PutTileS mtile&, 259 + (col - 1) * 17, 19 + (row - 1) * 17, 16, 16, drawpage
       ELSE
        DQBboxf drawpage, 259 + (col - 1) * 17, 19 + (row - 1) * 17, 259 + (col - 1) * 17 + 15, 19 + (row - 1) * 17 + 15, 148
        PutTile mtile&, 259 + (col - 1) * 17, 19 + (row - 1) * 17, drawpage
      END IF
      DQBprint drawpage, LTRIM$(RTRIM$(STR$(m))), 261 + (col - 1) * 17, (24 + row - 1) * 17, 15
    END IF
  NEXT row
NEXT col
DrawpageToVideo

WHILE DQBmouseLB: WEND

DO
  '--- abort the pulldown menu ---
  IF DQBmouseRB THEN commandreceived = -1

  '--- click on menu item or abort ---
  IF DQBmouseLB THEN
    mx = DQBmouseX: my = DQBmouseY: commandreceived = -1

    FOR col = 1 TO boxXsize
      FOR row = 1 TO boxYsize
        m = (col - 1) * 10 + row
        IF m <= matrices THEN
          IF InArea(mx, my, 259 + (col - 1) * 17, 19 + (row - 1) * 17, 259 + (col - 1) * 17 + 15, 19 + (row - 1) * 17 + 15) THEN commandreceived = m: mrow = row: mcol = col
        END IF
      NEXT row
    NEXT col
  END IF
LOOP UNTIL commandreceived

SELECT CASE commandreceived
 CASE -1
  WHILE DQBmouseLB: WEND: WHILE DQBmouseRB: WEND
 CASE ELSE '---------------------------------------------[ SELECT MATRIX ]---
  DQBboxf drawpage, 259 + (mcol - 1) * 17, 19 + (mrow - 1) * 17, 259 + (mcol - 1) * 17 + 15, 19 + (mrow - 1) * 17 + 15, 148
  DrawpageToVideo
  WHILE DQBmouseLB: WEND: WHILE DQBmouseRB: WEND
  IF InArea(DQBmouseX, DQBmouseY, 259 + (mcol - 1) * 17, 19 + (mrow - 1) * 17, 259 + (mcol - 1) * 17 + 15, 19 + (mrow - 1) * 17 + 15) = 0 THEN EXIT SUB
  objmode = 1: curitem = commandreceived
  OPEN ".\matrices\matrix." + LTRIM$(RTRIM$(STR$(curitem))) FOR INPUT AS 1
    INPUT #1, mxsize
    INPUT #1, mysize
    REDIM matrix(mxsize, mysize) AS LONG
    FOR ry = 1 TO mysize
      FOR rx = 1 TO mxsize: INPUT #1, matrix(rx, ry): NEXT rx
    NEXT ry
  CLOSE 1
END SELECT

END SUB

SUB MenuEditMusic

DQBbox drawpage, 95, 93, 215, 110, 15
DQBboxf drawpage, 96, 94, 214, 109, 14
DQBprint drawpage, "Music:", 97, 95, 71
DQBprint drawpage, "Currently: " + LCASE$(bgfile$), 97, 103, 20
DrawpageToVideo

F$ = GetFile$(128, 95)
F$ = UCASE$(F$)
IF F$ = "" THEN bgfile$ = "NONE" ELSE bgfile$ = LTRIM$(RTRIM$(F$))
refresh = 1

END SUB

SUB MenuEditReplace

' -- tile to be replaced (or batch file to use) --
DQBbox drawpage, 80, 93, 230, 110, 15
DQBboxf drawpage, 81, 94, 229, 109, 14
DQBprint drawpage, "Tile to be replaced/Batch file:", 82, 95, 71
DrawpageToVideo
F$ = GetFile$(86, 103)
IF F$ <> "" THEN
  ON ERROR GOTO CheckFile
  OPEN F$ FOR INPUT AS 1: fs& = LOF(1): CLOSE 1
  ON ERROR GOTO ErrorHandler
  IF fs& THEN
    OPEN F$ FOR INPUT AS 1
      DO
        INPUT #1, t1&
        INPUT #1, t2&
        ReplaceTile t1&, t2&
      LOOP UNTIL EOF(1)
    CLOSE 1
    EXIT SUB
   ELSE
    t1& = VAL(F$)
  END IF
 ELSE EXIT SUB
END IF

' -- tile to replace with --
DQBbox drawpage, 100, 114, 210, 131, 15
DQBboxf drawpage, 101, 115, 209, 130, 14
DQBprint drawpage, "Tile to replace with:", 102, 116, 71
DrawpageToVideo
F$ = GetNumber$(106, 124)
IF F$ <> "" THEN t2& = VAL(F$) ELSE t2& = -1
IF t1& >= 0 AND t2& >= 0 THEN
  ReplaceTile t1&, t2&
END IF
 
END SUB

SUB MenuFileLoadMap

DQBbox drawpage, 104, 93, 212, 104, 15
DQBboxf drawpage, 105, 94, 211, 103, 14
DQBprint drawpage, "Load:", 106, 96, 71
DrawpageToVideo
F$ = GetFile$(133, 96)
IF F$ <> "" THEN LoadMap F$

END SUB

SUB MenuFileNewMap

' -- width of new map --
DQBbox drawpage, 100, 93, 210, 105, 15
DQBboxf drawpage, 101, 94, 209, 104, 14
DQBprint drawpage, "Width:", 102, 96, 71
DrawpageToVideo
F$ = GetNumber$(132, 96)
IF F$ <> "" THEN xs = VAL(F$) ELSE EXIT SUB

' -- height of new map --
DQBbox drawpage, 100, 109, 210, 121, 15
DQBboxf drawpage, 101, 110, 209, 120, 14
DQBprint drawpage, "Height:", 102, 112, 71
DrawpageToVideo
F$ = GetNumber$(137, 112)
IF F$ <> "" THEN ys = VAL(F$) ELSE EXIT SUB

' -- create valid new map --
IF xs * ts >= 320 AND xs <= 512 AND ys * ts >= 200 AND ys <= 512 THEN
  mapxsize = xs: mapysize = ys
  NewMap
END IF

END SUB

SUB MenuFileSaveMap

DQBbox drawpage, 104, 93, 212, 104, 15
DQBboxf drawpage, 105, 94, 211, 103, 14
DQBprint drawpage, "Save:", 106, 96, 71
DrawpageToVideo
F$ = GetFile$(133, 96)
IF F$ <> "" THEN SaveMap F$

END SUB

SUB SelectTile

WHILE DQBmouseLB: WEND

CurTile& = StartTile&: refresh = 1

DO
  IF refresh THEN
    CurTile& = 0
    DQBmouseHide
    DQBboxf drawpage, 0, 0, 306, 187, 150  ' tile background
    DQBboxf drawpage, 307, 0, 319, 199, 0  ' right margin
    DQBboxf drawpage, 0, 188, 319, 199, 0  ' bottom margin
    'DQBclearLayer drawpage
   
    FOR puty = 0 TO 10
      FOR putx = 0 TO 17
        IF StartTile& + CurTile& = pentile& THEN
          DQBbox drawpage, putx * 17, puty * 17, putx * 17 + 17, puty * 17 + 17, 15
        END IF
        IF StartTile& + CurTile& <= numtiles& THEN
          n& = (CurTile&) + StartTile&
          placex = putx * 17 + 1: placey = puty * 17 + 1
          IF TileType(n&) <> 100 THEN PutTileS n&, placex, placey, 16, 16, drawpage
          CurTile& = CurTile& + 1
         ELSE
          DQBboxf drawpage, putx * 17 + 1, puty * 17 + 1, putx * 17 + 16, puty * 17 + 16, 0
        END IF
      NEXT putx
    NEXT puty
 
    DrawpageToVideo
    refresh = 0
  END IF

  IF DQBkey(keyup) THEN
    IF StartTile& > 18 THEN StartTile& = StartTile& - 18
    refresh = 1
    DQBwait 5
  END IF
  IF DQBkey(keydown) THEN
    IF StartTile& + (11 * 18) <= numtiles& + 36 THEN
      StartTile& = StartTile& + 18
      refresh = 1
      DQBwait 5
    END IF
  END IF
  IF DQBkey(73) THEN  ' Page up
    IF StartTile& > 18 * 11 THEN StartTile& = StartTile& - (18 * 11) ELSE StartTile& = 1
    refresh = 1
    WHILE DQBkey(73): WEND
  END IF
  IF DQBkey(81) THEN  ' Page down
    IF StartTile& + (18 * 11 * 2) <= numtiles& + 36 THEN
      StartTile& = StartTile& + (18 * 11)
      refresh = 1
      WHILE DQBkey(81): WEND
    END IF
  END IF

  IF DQBmouseLB OR DQBmouseRB THEN
    mx = DQBmouseX: my = DQBmouseY
    IF mx > 0 AND mx < 307 AND my > 0 AND my < 187 THEN
      CurTile& = 1
      FOR chky = 0 TO 10
        FOR chkx = 0 TO 17
          IF StartTile& + CurTile& - 1 <= numtiles& THEN
            IF InArea(mx, my, chkx * 17 + 1, chky * 17 + 1, chkx * 17 + 16, chky * 17 + 16) THEN
              IF TileType(StartTile& + CurTile& - 1) <> 100 THEN
                '-- grab the tile --
                IF DQBmouseLB AND DQBmouseRB = 0 THEN pentile& = StartTile& + CurTile& - 1: EXIT DO
                '-- display number --
                IF DQBmouseRB AND DQBmouseLB = 0 THEN
                  DQBboxf video, 290, 189, 319, 199, 0
                  DQBprint video, LTRIM$(RTRIM$(STR$(StartTile& + CurTile& - 1))), 292, 190, 15
                  WHILE DQBmouseRB: WEND
                  refresh = 1
                END IF
              END IF
            END IF
          END IF
          CurTile& = CurTile& + 1
        NEXT chkx
      NEXT chky
    END IF
  END IF
LOOP UNTIL DQBkey(keyesc)
WHILE DQBmouseLB: WEND
WHILE DQBmouseRB: WEND
WHILE DQBkey(keyesc): WEND

END SUB


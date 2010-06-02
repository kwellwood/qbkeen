DEFINT A-Z
'$INCLUDE: 'engine.bi'
'$INCLUDE: 'directqb.bi'
'$INCLUDE: 'timer.bi'
'$INCLUDE: 'tiles.bi'
'$INCLUDE: 'map.bi'
'$INCLUDE: 'player.bi'
'$INCLUDE: 'items.bi'
'$INCLUDE: 'enemies.bi'
'$INCLUDE: 'switches.bi'
'$INCLUDE: 'lifts.bi'
'$INCLUDE: 'weapons.bi'
'$INCLUDE: 'menu.bi'
DECLARE SUB DrawBox (x1, y1, x2, y2, c)
DECLARE SUB DrawLoadingBox (level)
DECLARE FUNCTION GetMapLocation$ ()

DECLARE SUB DrawLight (x, y, intensity)
DECLARE SUB EnterCheat ()
DECLARE SUB NewGame ()
DECLARE SUB LoadGame (slot)
DECLARE SUB SaveGame (slot)
DECLARE SUB WinGameScreen (t&, x, y, delay!)
DECLARE FUNCTION GetFile$ (x, y, c)
DECLARE FUNCTION SavedGameTitle$ (slot)
'$STATIC

CONST menusysver = 2
CONST main = 1, options = 2, save = 3, load = 4
CONST mainitems = 5, saveloaditems = 8, optionsitems = 4
CONST introtile& = 3384

ON ERROR GOTO ErrorHandler

DIM SHARED menu, menutile&, selectorstartfrm&, selectorframes, menuopt
DIM SHARED menux, menuy, selectordelay, selectionpixels
DIM SHARED TitleScreenTile&, HelpMenuTile&, HelpMenuCursor&
DIM SHARED InstructionsTile&, StoryTile&
DIM SHARED TryAgainTile&

DIM SHARED SpotLight(40, 40) AS INTEGER, intropal AS STRING * 768
'============================================================================
ErrorHandler:
e = ERR
ErrorHandlerSub e
RESUME NEXT

CheckFile:
RESUME NEXT

SUB DrawLight (x, y, intensity)

IF intensity < 0 THEN intensity = 0
IF intensity > 100 THEN intensity = 100

'- Thanks to Angelo Mottola,   -
'- Wetspot II for this routine -
addr& = (y * 320&) + x
FOR yy = 0 TO 40
  FOR xx = 0 TO 40
    IF x + xx > 1 AND x + xx < 318 THEN
      DEF SEG = VARSEG(scr(0))
      col = INT((PEEK(addr& + xx) + SpotLight(xx, yy)) * (intensity / 100))
      IF col < 0 THEN col = 0
      IF col > 127 THEN col = 127
      DQBpset drawpage, x + xx, y + yy, col
    END IF
  NEXT xx
  addr& = addr& + 320
NEXT yy

END SUB

SUB DrawMenu

'--- select current menu ---
SELECT CASE menu
 CASE main: t& = menutile&
 CASE save: t& = menutile& + 1
 CASE load: t& = menutile& + 2
 CASE options: t& = menutile& + 3
END SELECT
PutSprite t&, 0, 0, drawpage

'--- draw text for submenus ---
IF menu = load OR menu = save THEN
  DQBbox drawpage, 126, 80, 210, 174, 146
  DQBboxf drawpage, 127, 81, 209, 173, 14
  FOR slot = 1 TO 8
    text$ = SavedGameTitle$(slot)
    IF text$ = "" THEN text$ = "[ Empty Slot ]"
    DQBprint drawpage, text$, 128, 70 + slot * 12, 131
  NEXT slot
 ELSEIF menu = options THEN
  DQBbox drawpage, 126, 80, 228, 125, 146
  DQBboxf drawpage, 127, 81, 227, 124, 14
  IF player(0).invincible THEN text$ = "ON" ELSE text$ = "OFF"
  DQBprint drawpage, "Invincibility: " + text$, 128, 82, 131
  IF dolog THEN text$ = "ON" ELSE text$ = "OFF"
  DQBprint drawpage, "Debug logging: " + text$, 128, 94, 131
  IF showdebughud THEN text$ = "ON" ELSE text$ = "OFF"
  DQBprint drawpage, "Show debug HUD: " + text$, 128, 106, 131
  DQBprint drawpage, "Enter cheat:", 128, 118, 131
END IF

'--- display animated selector ---
optionspacing = selectionpixels
cursorx = menux: cursory = menuy
IF menu = load OR menu = save OR menu = options THEN
  optionspacing = 12
  cursory = 80
END IF

frame& = (INT(anmcounter / selectordelay) MOD selectorframes) + selectorstartfrm&
PutSprite frame&, cursorx, cursory + ((menuopt - 1) * optionspacing), drawpage

END SUB

SUB EnterCheat

DrawBox 189, 116, 274, 126, 31
DQBcopyLayer drawpage, video
cheat$ = GetFile$(191, 118, 32)

SELECT CASE LCASE$(cheat$)
 CASE "geezer"
  IF gameplay <> stopped THEN
    player(0).ancientsrescued = player(0).ancientsrescued + 1
    IF player(0).ancientsrescued = totalancients THEN
      gameplay = running: pausedingame = 0: gamemode = ingame
      SetGameComplete
    END IF
    accepted = 1
  END IF
 CASE "keys"
  IF gameplay <> stopped THEN
    player(0).keyred = 1
    player(0).keyblu = 1
    player(0).keygrn = 1
    player(0).keyyel = 1
    accepted = 1
  END IF
 CASE "scuba"
  IF gameplay <> stopped THEN player(0).scuba = 1: accepted = 1
 CASE "guns"
  IF gameplay <> stopped THEN player(0).ammo = 99: accepted = 1
 CASE "f5"
  IF gameplay <> stopped THEN
    gamemode = ingame
    pausedingame = 0
    SetLevelComplete
    accepted = 1
  END IF
END SELECT

IF accepted THEN
  DrawBox 189, 116, 274, 126, 31
  DQBprint drawpage, "Accepted", 191, 118, 32
  DQBcopyLayer drawpage, video
  mark& = TimerTicks(HiResTimer) + 500 \ 5
  WHILE TimerTicks(HiResTimer) < mark&: WEND
END IF

END SUB

FUNCTION GetFile$ (x, y, c)

DQBremoveKeyboard

Inpt$ = "": length = 0: textx = x: texty = y
'DQBget drawpage, textx, texty, textx + 80, texty + 8, VARSEG(scr(0)), VARPTR(scr(0))
DQBget drawpage, textx, texty, 319, texty + 8, VARSEG(scr(0)), VARPTR(scr(0))

DO
  kbd$ = INKEY$
  IF kbd$ <> "" THEN
    SELECT CASE kbd$
     CASE CHR$(8)
      IF length > 0 THEN length = length - 1
      Inpt$ = LEFT$(Inpt$, length)
      DQBput drawpage, textx, texty, VARSEG(scr(0)), VARPTR(scr(0))
     CASE CHR$(13)
      EXIT DO
     CASE CHR$(27)
      Inpt$ = "": EXIT DO
     CASE ELSE
      IF ASC(kbd$) > 31 AND ASC(kbd$) < 127 THEN
        IF length <= 16 THEN
          Inpt$ = Inpt$ + kbd$
          length = length + 1
        END IF
      END IF
    END SELECT
    DQBprint drawpage, Inpt$, textx, texty, c
    DQBcopyLayer drawpage, video
  END IF
LOOP

DQBinstallKeyboard
GetFile$ = Inpt$

END FUNCTION

SUB HandleMenu (k)

'--- delay input ---
IF TimerTicks(HiResTimer) < menutimermark& THEN EXIT SUB

SELECT CASE k
 '--- move selector up ---
 CASE KEYUP
  IF menuopt > 1 THEN
    menuopt = menuopt - 1
    menutimermark& = TimerTicks(HiResTimer) + (200 \ 5)
  END IF
 '--- move selector down ---
 CASE KEYDOWN
  SELECT CASE menu                 'number of options
   CASE main: max = mainitems      ' depending on the
   CASE save: max = saveloaditems  ' current menu
   CASE load: max = saveloaditems
   CASE options: max = optionsitems
  END SELECT
  IF menuopt < max THEN
    menuopt = menuopt + 1
    menutimermark& = TimerTicks(HiResTimer) + (200 \ 5)
  END IF
 CASE KEYENTER
  SELECT CASE menu
   CASE main
    '--- main menu options ---
    SELECT CASE menuopt
     CASE 1: NewGame
     CASE 2
      IF player(0).action <> dying AND gameplay <> stopped THEN
        menu = save: menuopt = 1
      END IF
     CASE 3: menu = load: menuopt = 1
     CASE 4: menu = options: menuopt = 1
     CASE 5: quitgame = 1
    END SELECT
    WHILE DQBkey(KEYENTER): WEND
   CASE save: SaveGame menuopt
   CASE load: LoadGame menuopt: WHILE DQBkey(KEYENTER): WEND
   CASE options
    SELECT CASE menuopt
     CASE 1: IF player(0).invincible THEN player(0).invincible = 0 ELSE player(0).invincible = 1
     CASE 2: IF dolog THEN dolog = 0 ELSE dolog = 1
     CASE 3: IF showdebughud THEN showdebughud = 0 ELSE showdebughud = 1
     CASE 4: EnterCheat
    END SELECT
  END SELECT
  menutimermark& = TimerTicks(HiResTimer) + (200 \ 5)
 '--- move up in menu tree ---
 CASE KEYESC
  IF menu <> main THEN
    menu = main: menuopt = 1
   ELSE
    IF player(0).action <> dying AND gameplay <> stopped THEN
      gamemode = ingame
      IF pausedingame = 0 THEN gameplay = running   ' if paused only by menu
                                                    '   then unpause
    END IF
  END IF
  WHILE DQBkey(KEYESC): WEND
  menutimermark& = TimerTicks(HiResTimer) + (200 \ 5)
END SELECT

END SUB

SUB HelpMenu

HelpOpt = 0

DO
  DO
    PutTile HelpMenuTile&, 0, 0, drawpage
    PutSprite HelpMenuCursor&, 54, 76 + (HelpOpt * 26), drawpage
    DQBcopyLayer drawpage, video

    IF TimerTicks(HiResTimer) > menutimermark& THEN
      IF DQBkey(KEYUP) THEN
        HelpOpt = HelpOpt - 1
        IF HelpOpt < 0 THEN HelpOpt = 0
        menutimermark& = TimerTicks(HiResTimer) + (200 \ 5)
      END IF
      IF DQBkey(KEYDOWN) THEN
        HelpOpt = HelpOpt + 1
        IF HelpOpt > 1 THEN HelpOpt = 1
        menutimermark& = TimerTicks(HiResTimer) + (200 \ 5)
      END IF
      IF DQBkey(KEYESC) THEN
        WHILE DQBkey(KEYESC): WEND
        EXIT SUB
      END IF
    END IF
  LOOP UNTIL DQBkey(KEYENTER) AND TimerTicks(HiResTimer) > menutimermark&
  WHILE DQBkey(KEYENTER): WEND
 
  page& = 0
  IF HelpOpt = 0 THEN basetile& = InstructionsTile&: maxpages = 16 - 1
  IF HelpOpt = 1 THEN basetile& = StoryTile&: maxpages = 9 - 1
  DO
    PutTile basetile& + page&, 0, 0, drawpage
    DQBcopyLayer drawpage, video

    IF TimerTicks(HiResTimer) > menutimermark& THEN
      IF DQBkey(KEYUP) OR DQBkey(75) OR DQBkey(73) THEN
        page& = page& - 1
        IF page& < 0 THEN page& = 0
        menutimermark& = TimerTicks(HiResTimer) + (200 \ 5)
      END IF
      IF DQBkey(KEYDOWN) OR DQBkey(77) OR DQBkey(81) THEN
        page& = page& + 1
        IF page& > maxpages THEN page& = maxpages
        menutimermark& = TimerTicks(HiResTimer) + (200 \ 5)
      END IF
    END IF
  LOOP UNTIL DQBkey(KEYESC) AND TimerTicks(HiResTimer) > menutimermark&
  WHILE DQBkey(KEYESC): WEND
LOOP

END SUB

SUB InitMenu

OPEN "engine.dat" FOR INPUT AS 1
  DO: INPUT #1, text$
  LOOP UNTIL UCASE$(text$) = "[MENU.DAT]"
  INPUT #1, filever
  IF filever <> menusysver THEN ErrorHandlerSub 137

  INPUT #1, menutile&
  INPUT #1, selectorstartfrm&
  INPUT #1, selectorframes
  INPUT #1, selectordelay
  INPUT #1, menux
  INPUT #1, menuy
  INPUT #1, selectionpixels
  INPUT #1, TitleScreenTile&
  INPUT #1, HelpMenuTile&
  INPUT #1, HelpMenuCursor&
  INPUT #1, InstructionsTile&
  INPUT #1, StoryTile&
  INPUT #1, TryAgainTile&
CLOSE 1

menu = main
menuopt = 1

END SUB

SUB Intro

IF ems THEN
  '--- Set variables ---
  maxlightintensity = 56
  focus = 5

  '--- Create spotlight ---
  '- Thanks to Angelo Mottola,   -
  '- Wetspot II for this routine -
  FOR x = 0 TO 40
    FOR y = 0 TO 40
      SpotLight(x, y) = maxlightintensity - (SQR(((x - 20) ^ 2) + ((y - 20) ^ 2)) * focus)
    NEXT y
  NEXT x

  '--- Create palette ---
  FOR c = 0 TO 63: DQBsetCol c, 0, 0, c: NEXT c
  FOR c = 64 TO 127: DQBsetCol c, c - 64, c - 64, 63: NEXT c
  FOR c = 128 TO 255: DQBsetCol c, 0, 0, 0: NEXT c
  DQBgetPal intropal

  '--- Load background image ---
  PutTile introtile&, 0, 0, drawpage
  DQBget drawpage, 0, 0, 319, 199, VARSEG(scr(0)), VARPTR(scr(0))
  DQBclearLayer drawpage

  light1intensity = 100
  light1intensity2 = 100
  light2intensity = 0
  light2intensity2 = 0

  '--- Animate the spotlights ---     ' \/ 1000ths of a second per frame
  FOR t = -60 TO 280 STEP 3
    mark& = TimerTicks&(HiResTimer) + 65 / 5

    COSt8! = COS(t / 8): SINt8! = SIN(t / 8)
    COSt6! = COS(t / 6): SINt6! = SIN(t / 6)

    'light one
    x = -40 + (t * 1.2) - COSt8! * 2
    y = 21 + SINt8! * 5
    DrawLight x, y, light1intensity
    IF t > 90 THEN light1intensity = light1intensity - 5

    'light one, seconday
    x = -80 + (t * 1.2) + COSt8! * 2
    y = 21 - SINt8! * 5
    DrawLight x, y, light1intensity2
    IF t > 110 THEN light1intensity2 = light1intensity2 - 5

    'light two
    x = -35 + (t * 1.4) + COSt6! * 2
    y = 94 + SINt6! * 4
    DrawLight x, y, light2intensity
    IF t > 60 THEN light2intensity = light2intensity + 8

    'light two, secondary
    x = -75 + (t * 1.4) - COSt6! * 2
    y = 94 - SINt6! * 4
    DrawLight x, y, light2intensity2
    IF t > 90 THEN light2intensity2 = light2intensity2 + 8

    DQBcopyLayer 1, 0
    DQBclearLayer 1
    WHILE TimerTicks&(HiResTimer) < mark&: slowdown = 1: WEND
    IF slowdown = 0 THEN debuglog "reduce intro fps"
    slowdown = 0
    
    '-- Break out if a key is pressed --
    IF DQBkey(KEYENTER) OR DQBkey(KEYSPACE) OR DQBkey(KEYCTRL) THEN t = 500
  NEXT t
 
  '--- If animation was skipped ---
  WHILE DQBkey(KEYENTER) OR DQBkey(KEYSPACE) OR DQBkey(KEYCTRL): WEND

  FOR c = 0 TO 127: DQBsetCol c, 0, 0, 0: NEXT c
  DQBput 0, 0, 0, VARSEG(scr(0)), VARPTR(scr(0))
  DQBfadeIn intropal
  
  '--- Pause for a few seconds ---
  mark& = TimerTicks&(HiResTimer) + 3000 \ 5
  WHILE TimerTicks&(HiResTimer) < mark& AND DQBkey(KEYENTER) = 0 AND DQBkey(KEYSPACE) = 0 AND DQBkey(KEYCTRL) = 0: WEND
  WHILE DQBkey(KEYENTER) OR DQBkey(KEYSPACE) OR DQBkey(KEYCTRL): WEND
END IF

DQBfadeTo 0, 0, 0

'--- Plays intro FLI ---
'dummy& = SETMEM(-66000)
'e = DQBopenFLI%("dqblogo.fli", Frames%, Speed%)
'  IF e THEN ErrorHandlerSub 189 + e
'  FOR f = 1 TO Frames%: DQBplayFLIstep video: DQBwait Speed%: NEXT f
'DQBcloseFLI
'dummy& = SETMEM(66000)
'SLEEP 1
'DQBfadeTo 0, 0, 0

'--- Shot keen title screen ---
PutTile TitleScreenTile&, 0, 0, video
FadeInPalette
DO: LOOP UNTIL DQBkey(KEYCTRL) OR DQBkey(KEYSPACE) OR DQBkey(KEYENTER) OR DQBkey(KEYESC) OR DQBkey(59)
IF DQBkey(59) THEN
  HelpMenu
  WHILE DQBkey(59): WEND
END IF
WHILE DQBkey(KEYCTRL): WEND
WHILE DQBkey(KEYSPACE): WEND
WHILE DQBkey(KEYENTER): WEND
WHILE DQBkey(KEYESC): WEND

END SUB

SUB LoadGame (slot)

file$ = "SAVE" + LTRIM$(RTRIM$(STR$(slot))) + ".CK7"

'--- Check for file existance ---
ON ERROR GOTO CheckFile
OPEN file$ FOR INPUT AS 2: fs& = LOF(2): CLOSE 2
IF fs& = 0 THEN EXIT SUB
ON ERROR GOTO ErrorHandler

OPEN file$ FOR BINARY AS 2
  GET #2, , e
  IF e <> enginever THEN ErrorHandlerSub 128
  FOR l = 1 TO 16: GET #2, , c: NEXT l

  GET #2, , movemode

  GET #2, , numlevels
  FOR l = 1 TO numlevels: GET #2, , levelscomplete(l): NEXT l
  GET #2, , curlevel
  LoadLevel curlevel
 
  GET #2, , player(0)
  UpdateClipPoints

  LoadItemsFromFile 2
  LoadSpritesFromFile 2
  LoadEnemiesFromFile 2
  LoadShotsFromFile 2
  FOR s = 1 TO 25
    GET #2, , n
    SetSwitch s, n
  NEXT s
  LoadLiftsFromFile 2

  ClearChangingTiles
  FOR y = 1 TO MapHeight
    FOR x = 1 TO MapWidth
      GET #2, , layer1&
      GET #2, , layer2&
      GET #2, , layer3&
      SetMap x, y, layer1&
      SetMapFG x, y, layer2&
      SetSwitchTag x, y, layer3&
      IF TileType2(layer2&) = 14 THEN AddChangingTile x, y
    NEXT x
  NEXT y
CLOSE 2

gamemode = ingame
gameplay = running: pausedingame = 0
menu = main: menuopt = 1

END SUB

SUB NewGame

mark& = TimerTicks(HiResTimer) + (1000 \ 5)

player(0).lives = 3
player(0).dead = 0
player(0).ammo = 5
player(0).score = 0
player(0).nextlifeat = 30000
player(0).drops = 0
player(0).ancientsrescued = 0

OPEN "levels.dat" FOR INPUT AS 1: INPUT #1, numlevels: CLOSE 1
FOR l = 1 TO numlevels: levelscomplete(l) = 0: NEXT l

curlevel = 2
DrawLoadingBox curlevel
LoadLevel curlevel
gameplay = running: pausedingame = 0
movemode = mapmode
gamemode = ingame

WHILE TimerTicks(HiResTimer) < mark&: WEND

END SUB

FUNCTION SavedGameTitle$ (slot)

file$ = "SAVE" + LTRIM$(RTRIM$(STR$(slot))) + ".CK7": f = FREEFILE

'--- Check for file existance ---
ON ERROR GOTO CheckFile
OPEN file$ FOR INPUT AS f: fs& = LOF(f): CLOSE f
ON ERROR GOTO ErrorHandler
IF fs& = 0 THEN EXIT FUNCTION

OPEN file$ FOR BINARY AS f
  GET #f, , e
  IF e <> enginever THEN ErrorHandlerSub 128
  FOR l = 1 TO 16: GET #f, , c: title$ = title$ + CHR$(c): NEXT l
CLOSE f

title$ = RTRIM$(title$)
SavedGameTitle$ = title$

END FUNCTION

SUB SaveGame (slot)

'.CK7 format:
'[2 bytes] engine version
'[32 bytes] save name
'[2 bytes] movement mode
'[? bytes] numlevels
'[? bytes] levelscomplete(1 to numlevels)
'[2 bytes] current level
'[? bytes] player(0) data
'[2 bytes] size of item stack
'[? bytes] items
'[2 bytes] size of sprite stack
'[? bytes] sprites
'[2 bytes] size of foe stack
'[? bytes] enemies
'[? bytes] 5 blaster shots
'[50 bytes] 25 switches
'[12x bytes] Map, MapFG, SwitchTag

DQBboxf drawpage, 127, 69 + slot * 12, 209, 77 + slot * 12, 157
DQBcopyLayer drawpage, video
savename$ = GetFile$(128, 70 + slot * 12, 15)
IF savename$ = "" THEN EXIT SUB

IF LEN(savename$) < 16 THEN savename$ = savename$ + SPACE$(16 - LEN(savename$))

file$ = "SAVE" + LTRIM$(RTRIM$(STR$(slot))) + ".CK7"

OPEN file$ FOR BINARY AS 2
  e = enginever: PUT #2, , e
  FOR l = 1 TO 16
    c = ASC(MID$(savename$, l, 1))
    PUT #2, , c
  NEXT l
 
  PUT #2, , movemode
 
  OPEN "levels.dat" FOR INPUT AS 3: INPUT #3, numlevels: CLOSE 3
  PUT #2, , numlevels
  FOR l = 1 TO numlevels: PUT #2, , levelscomplete(l): NEXT l
  PUT #2, , curlevel

  PUT #2, , player(0)

  WriteItemsToFile 2
  WriteSpritesToFile 2
  WriteEnemiesToFile 2
  WriteShotsToFile 2
  FOR s = 1 TO 25
    n = GetSwitch(s)
    PUT #2, , n
  NEXT s
  WriteLiftsToFile 2

  FOR y = 1 TO MapHeight
    FOR x = 1 TO MapWidth
      layer1& = Map&(x, y)
      layer2& = MapFG&(x, y)
      layer3& = SwitchTag&(x, y)
      PUT #2, , layer1&
      PUT #2, , layer2&
      PUT #2, , layer3&
    NEXT x
  NEXT y
CLOSE 2

menu = main: menuopt = 1
gamemode = ingame
gameplay = running: pausedingame = 0

END SUB

FUNCTION TryAgainMenu

PutSprite TryAgainTile&, 73, 57, drawpage

DQBprint drawpage, "You didn't make it past", 160 - 110 / 2, 67, 14
DQBprint drawpage, GetMapLocation$, 160 - DQBlen(GetMapLocation$) / 2, 77, 14
DQBprint drawpage, "Try Again", 160 - 46 / 2, 100, 14
DQBprint drawpage, "Exit to Shadowlands", 160 - 92 / 2, 114, 14
DQBcopyLayer drawpage, video

DO
  boxcol = (INT(TimerTicks(HiResTimer) / 60) MOD 2) * 99 + 52
  IF tryopt = 0 THEN
    DQBbox video, 85, 96, 235, 109, boxcol
    DQBbox video, 86, 97, 234, 108, boxcol
    DQBbox video, 85, 110, 235, 123, 240
    DQBbox video, 86, 111, 234, 122, 240
   ELSEIF tryopt = 1 THEN
    DQBbox video, 85, 96, 235, 109, 240
    DQBbox video, 86, 97, 234, 108, 240
    DQBbox video, 85, 110, 235, 123, boxcol
    DQBbox video, 86, 111, 234, 122, boxcol
  END IF
  IF DQBkey(KEYDOWN) AND mark& < TimerTicks(HiResTimer) THEN
    IF tryopt = 0 THEN tryopt = 1
    mark& = TimerTicks(HiResTimer) + (100 \ 5)
   ELSEIF DQBkey(KEYUP) AND mark& < TimerTicks(HiResTimer) THEN
    IF tryopt = 1 THEN tryopt = 0
    mark& = TimerTicks(HiResTimer) + (100 \ 5)
  END IF
LOOP UNTIL DQBkey(KEYENTER)
WHILE DQBkey(KEYENTER): WEND

TryAgainMenu = tryopt

END FUNCTION

SUB WinGame

DIM PAUSE AS SINGLE: PAUSE = 0!

WinGameScreen 3388, 22, 8, 2
WinGameScreen 3389, 6, 8, 1
WinGameScreen 3390, 6, 8, 1
WinGameScreen 3391, 6, 8, 1
WinGameScreen 3392, 6, 8, 1
WinGameScreen 3393, 6, 8, PAUSE
WinGameScreen 3394, 78, 30, 1
WinGameScreen 3395, 28, 30, PAUSE
WinGameScreen 3396, 6, 8, 4
WinGameScreen 3397, 102, 8, 2
WinGameScreen 3398, 8, 8, PAUSE
WinGameScreen 3399, 22, 8, .75
WinGameScreen 3400, 22, 8, .75
WinGameScreen 3399, 22, 8, .75
WinGameScreen 3400, 22, 8, PAUSE
WinGameScreen 3401, 6, 8, PAUSE
WinGameScreen 3402, 6, 8, PAUSE
WinGameScreen 3403, 6, 8, PAUSE
WinGameScreen 3404, 6, 8, 2
WinGameScreen 3405, 126, 8, .8
WinGameScreen 3406, 126, 8, .8
WinGameScreen 3405, 126, 8, .8
WinGameScreen 3406, 126, 8, PAUSE
WinGameScreen 3407, 6, 8, 1
WinGameScreen 3408, 6, 8, PAUSE
WinGameScreen 3409, 6, 8, PAUSE
WinGameScreen 3410, 6, 48, PAUSE
WinGameScreen 3411, 6, 101, PAUSE
WinGameScreen 3412, 86, 68, PAUSE
WinGameScreen 3413, 86, 88, 2
WinGameScreen 3414, 86, 88, .3
WinGameScreen 3413, 86, 88, PAUSE
WinGameScreen 3415, 86, 68, PAUSE

SetGameOver

END SUB

SUB WinGameScreen (t&, x, y, delay!)

'if delay = 0 then wait for a key

PutTile 3387, 0, 0, drawpage
PutTile t&, x, y, drawpage
DQBcopyLayer drawpage, video

IF delay! > 0! THEN
  mark& = TimerTicks&(HiResTimer)
  WHILE TimerTicks&(HiResTimer) < mark& + (delay! * 200&): WEND
 ELSE
  DO
    anmframe = (TimerTicks(HiResTimer) \ 75) MOD 2
    PutSprite 3385& + anmframe, 295, 185, video
  LOOP UNTIL DQBkey(KEYENTER) OR DQBkey(KEYSPACE) OR DQBkey(KEYALT) OR DQBkey(KEYCTRL)
  WHILE DQBkey(KEYENTER) OR DQBkey(KEYSPACE) OR DQBkey(KEYALT) OR DQBkey(KEYCTRL): WEND
END IF

END SUB


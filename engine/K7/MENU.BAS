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
DECLARE SUB DrawLoadingBox ()
'$STATIC

DECLARE SUB NewGame ()
DECLARE SUB SaveGame (slot)
DECLARE SUB LoadGame (slot)
DECLARE FUNCTION GetFile$ (x, y, c)
DECLARE FUNCTION SavedGameTitle$ (slot)

CONST menusysver = 1
CONST main = 1, options = 2, save = 3, load = 4

ON ERROR GOTO ErrorHandler

DIM SHARED menu, menutile&, selectorstartfrm&, selectorframes, menuopt
DIM SHARED menux, menuy, selectordelay, selectionpixels
DIM SHARED TitleScreenTile&
'============================================================================
ErrorHandler:
E = ERR
ErrorHandlerSub E
RESUME NEXT

CheckFile:
RESUME NEXT

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
  FOR slot = 1 TO 8
    text$ = SavedGameTitle$(slot)
    IF text$ = "" THEN text$ = "[ Empty Slot ]"
    DQBprint drawpage, text$, 128, 70 + slot * 12, 15
  NEXT slot
 ELSEIF menu = options THEN
  IF player(0).invincible THEN text$ = "ON" ELSE text$ = "OFF"
  DQBprint drawpage, "Invincibility: " + text$, 128, 82, 15
  IF dolog THEN text$ = "ON" ELSE text$ = "OFF"
  DQBprint drawpage, "Debug logging: " + text$, 128, 94, 15
  IF showdebughud THEN text$ = "ON" ELSE text$ = "OFF"
  DQBprint drawpage, "Show debug HUD: " + text$, 128, 106, 15
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

FUNCTION GetFile$ (x, y, c)

DQBremoveKeyboard

Inpt$ = "": length = 0: textx = x: texty = y
DQBget drawpage, textx, texty, textx + 80, texty + 8, VARSEG(scr(0)), VARPTR(scr(0))

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
  SELECT CASE menu       'number of options
   CASE main: max = 5    ' depending on the
   CASE save: max = 8    ' current menu
   CASE load: max = 8
   CASE options: max = 3
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
   CASE load: LoadGame menuopt
   CASE options
    SELECT CASE menuopt
     CASE 1: IF player(0).invincible THEN player(0).invincible = 0 ELSE player(0).invincible = 1
     CASE 2: IF dolog THEN dolog = 0 ELSE dolog = 1
     CASE 3: IF showdebughud THEN showdebughud = 0 ELSE showdebughud = 1
    END SELECT
  END SELECT
  menutimermark& = TimerTicks(HiResTimer) + (200 \ 5)
 '--- move up in menu tree ---
 CASE KEYESC
  IF menu <> main THEN
    menu = main: menuopt = 1
   ELSE
    IF player(0).action <> dying AND gameplay <> stopped THEN gamemode = ingame
  END IF
  WHILE DQBkey(KEYESC): WEND
  menutimermark& = TimerTicks(HiResTimer) + (200 \ 5)
END SELECT

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
CLOSE 1

menu = main
menuopt = 1

END SUB

SUB Intro

PutTile TitleScreenTile&, 0, 0, video
DO: LOOP UNTIL DQBkey(KEYCTRL) OR DQBkey(KEYSPACE) OR DQBkey(KEYENTER) OR DQBkey(KEYESC)
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
  GET #2, , E
  IF E <> enginever THEN ErrorHandlerSub 128
  FOR l = 1 TO 16: GET #2, , c: NEXT l
  GET #2, , curlevel
  LoadLevel
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

  FOR y = 1 TO MapHeight
    FOR x = 1 TO MapWidth
      GET #2, , layer2&
      GET #2, , layer3&
      SetMapFG x, y, layer2&
      SetSwitchTag x, y, layer3&
    NEXT x
  NEXT y
CLOSE 2

gamemode = ingame
gameplay = running
menu = main: menuopt = 1

END SUB

SUB NewGame

mark& = TimerTicks(HiResTimer) + (1500 \ 5)

player(0).lives = 3
player(0).ammo = 5
player(0).score = 0
player(0).nextlifeat = 30000
player(0).drops = 0
player(0).ancientsrescued = 0

curlevel = 2
DrawLoadingBox
LoadLevel
gameplay = running
gamemode = ingame

WHILE TimerTicks(HiResTimer) < mark&: WEND

END SUB

FUNCTION SavedGameTitle$ (slot)

file$ = "SAVE" + LTRIM$(RTRIM$(STR$(slot))) + ".CK7": f = FREEFILE

'--- Check for file existance ---
ON ERROR GOTO CheckFile
OPEN file$ FOR INPUT AS f: fs& = LOF(f): CLOSE f
IF fs& = 0 THEN EXIT FUNCTION
ON ERROR GOTO ErrorHandler

OPEN file$ FOR BINARY AS f
  GET #f, , E
  IF E <> enginever THEN ErrorHandlerSub 128
  FOR l = 1 TO 16: GET #f, , c: title$ = title$ + CHR$(c): NEXT l
CLOSE f

title$ = RTRIM$(title$)
SavedGameTitle$ = title$

END FUNCTION

SUB SaveGame (slot)

'.CK7 format:
'[2 bytes] engine version
'[32 bytes] save name
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

'DQBbox drawpage, 126, 68 + slot * 12, 210, 78 + slot * 12, 16
'DQBboxf drawpage, 127, 69 + slot * 12, 209, 77 + slot * 12, 31
DrawBox 126, 68 + slot * 12, 210, 78 + slot * 12, 31
DQBcopyLayer drawpage, video
savename$ = GetFile$(128, 70 + slot * 12, 98)
IF savename$ = "" THEN EXIT SUB

IF LEN(savename$) < 16 THEN savename$ = savename$ + SPACE$(16 - LEN(savename$))

file$ = "SAVE" + LTRIM$(RTRIM$(STR$(slot))) + ".CK7"

OPEN file$ FOR BINARY AS 2
  E = enginever: PUT #2, , E
  FOR l = 1 TO 16
    c = ASC(MID$(savename$, l, 1))
    PUT #2, , c
  NEXT l
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
      layer2& = MapFG&(x, y)
      layer3& = SwitchTag&(x, y)
      PUT #2, , layer2&
      PUT #2, , layer3&
    NEXT x
  NEXT y
CLOSE 2

menu = main: menuopt = 1
gamemode = ingame

END SUB


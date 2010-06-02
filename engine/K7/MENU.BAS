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
'$STATIC

CONST menusysver = 1
CONST main = 1, options = 2, save = 3, load = 4

ON ERROR GOTO ErrorHandler

DIM SHARED menu, menutile&, selectorstartfrm&, selectorframes, menuopt
DIM SHARED menux, menuy, selectordelay, selectionpixels
DIM SHARED TitleScreenTile&
'============================================================================
ErrorHandler:
e = ERR
ErrorHandlerSub e
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

'--- display animated selector ---
frame& = (INT(anmcounter / selectordelay) MOD selectorframes) + selectorstartfrm&
PutSprite frame&, menux, menuy + ((menuopt - 1) * selectionpixels), drawpage

END SUB

SUB HandleMenu (k)

'--- delay input ---
IF TimerTicks(HiResTimer) < menutimermark& THEN EXIT SUB

SELECT CASE k
 '--- move selector up ---
 CASE KEYUP
  IF menuopt > 1 THEN
    menuopt = menuopt - 1
    menutimermark& = TimerTicks(HiResTimer) + (100 \ 5)
  END IF
 '--- move selector down ---
 CASE KEYDOWN
  SELECT CASE menu       'number of options
   CASE main: max = 5    ' depending on the
   CASE save: max = 1    ' current menu
   CASE load: max = 1
   CASE options: max = 1
  END SELECT
  IF menuopt < max THEN
    menuopt = menuopt + 1
    menutimermark& = TimerTicks(HiResTimer) + (100 \ 5)
  END IF
 CASE KEYENTER
  SELECT CASE menu
   CASE main
    '--- main menu options ---
    SELECT CASE menuopt
     CASE 1: NewGame
     CASE 2: IF player(0).action <> dying THEN SaveGame
     CASE 3: LoadGame
     CASE 4  ': Options
     CASE 5: quitgame = 1
    END SELECT
    WHILE DQBkey(KEYENTER): WEND
   CASE save
    '--- save menu options ---
   CASE load
    '--- load menu options ---
   CASE options
    '--- options menu options ---
  END SELECT
  menutimermark& = TimerTicks(HiResTimer) + (100 \ 5)
 '--- move up in menu tree ---
 CASE KEYESC
  IF player(0).action <> dying THEN
    IF menu <> main THEN menu = main ELSE gamemode = ingame
    menutimermark& = TimerTicks(HiResTimer) + (200 \ 5)
  END IF
END SELECT

END SUB

SUB InitMenu

OPEN "engine.dat" FOR INPUT AS 1
  DO: INPUT #1, Text$
  LOOP UNTIL UCASE$(Text$) = "[MENU.DAT]"
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

PutTile TitleScreenTile&, 0, 0, VIDEO
DO: LOOP UNTIL DQBkey(KEYCTRL) OR DQBkey(KEYSPACE) OR DQBkey(KEYENTER) OR DQBkey(KEYESC)

END SUB

SUB LoadGame

OPEN "SAVE1.CK7" FOR BINARY AS 2
  GET #2, , e
  IF e <> enginever THEN ErrorHandlerSub 128
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

END SUB

SUB NewGame

player(0).lives = 3
player(0).ammo = 5
player(0).score = 0

curlevel = 1
LoadLevel

END SUB

SUB SaveGame

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

OPEN "SAVE1.CK7" FOR BINARY AS 1
  e = enginever: PUT #1, , e
  savename$ = "Kevin's savegame"
  FOR l = 1 TO 16
    c = ASC(MID$(savename$, l, 1))
    PUT #1, , c
  NEXT l
  PUT #1, , curlevel
  PUT #1, , player(0)

  WriteItemsToFile 1
  WriteSpritesToFile 1
  WriteEnemiesToFile 1
  WriteShotsToFile 1
  FOR s = 1 TO 25
    n = GetSwitch(s)
    PUT #1, , n
  NEXT s
  WriteLiftsToFile 1

  FOR y = 1 TO MapHeight
    FOR x = 1 TO MapWidth
      layer2& = MapFG&(x, y)
      layer3& = SwitchTag&(x, y)
      PUT #1, , layer2&
      PUT #1, , layer3&
    NEXT x
  NEXT y
CLOSE 1

SLEEP 1

END SUB


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
IF TIMER < menudelay! THEN EXIT SUB

SELECT CASE k
 '--- move selector up ---
 CASE keyup
  IF menuopt > 1 THEN menuopt = menuopt - 1: menudelay! = TIMER + .1
 '--- move selector down ---
 CASE keydown
  SELECT CASE menu       'number of options
   CASE main: max = 5    ' depending on the
   CASE save: max = 1    ' current menu
   CASE load: max = 1
   CASE options: max = 1
  END SELECT
  IF menuopt < max THEN menuopt = menuopt + 1: menudelay! = TIMER + .1
 CASE keyenter
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
    WHILE DQBkey(keyenter): WEND
   CASE save
    '--- save menu options ---
   CASE load
    '--- load menu options ---
   CASE options
    '--- options menu options ---
  END SELECT
  menudelay! = TIMER + .1
 '--- move up in menu tree ---
 CASE keyesc
  IF player(0).action <> dying THEN
    IF menu <> main THEN menu = main ELSE gamemode = ingame
    menudelay! = TIMER + .1
  END IF
END SELECT

END SUB

SUB InitMenu

OPEN "menu.dat" FOR INPUT AS 1
  INPUT #1, filever
  IF filever <> menusysver THEN ErrorHandlerSub 137

  INPUT #1, menutile&
  INPUT #1, selectorstartfrm&
  INPUT #1, selectorframes
  INPUT #1, selectordelay
  INPUT #1, menux
  INPUT #1, menuy
  INPUT #1, selectionpixels
CLOSE 1

menu = main
menuopt = 1

END SUB

SUB Intro

PutTile 75, 0, 0, video
DO: LOOP UNTIL DQBkey(keyctrl) OR DQBkey(keyspace) OR DQBkey(keyenter) OR DQBkey(keyesc)


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

  activeitemstack(0) = "": GET #2, , i
  FOR k = 1 TO i
    GET #2, , item(k)
    activeitemstack(0) = activeitemstack(0) + CHR$(k)
  NEXT k

  activespritestack(0) = ""
  unusedspritestack(0) = ""
  GET #2, , s
  FOR k = 1 TO s
    GET #2, , sprite(k)
    activespritestack(0) = activespritestack(0) + CHR$(k)
  NEXT k
  FOR k = LEN(activespritestack(0)) + 1 TO 100
    unusedspritestack(0) = unusedspritestack(0) + CHR$(k)
  NEXT k

  activefoestack(0) = "": GET #2, , e
  FOR k = 1 TO e
    GET #2, , enemy(k)
    activefoestack(0) = activefoestack(0) + CHR$(k)
  NEXT k

  FOR s = 1 TO 5: GET #2, , shot(s): NEXT s

  FOR s = 1 TO 25: GET #2, , switch(s): NEXT s

  FOR l = 1 TO numlifts: GET #2, , lift(l): NEXT l
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

  i = LEN(activeitemstack(0)): PUT #1, , i
  FOR i = 1 TO LEN(activeitemstack(0))
    k = ASC(MID$(activeitemstack(0), i, 1))
    PUT #1, , item(k)
  NEXT i
 
  s = LEN(activespritestack(0)): PUT #1, , s
  FOR s = 1 TO LEN(activespritestack(0))
    k = ASC(MID$(activespritestack(0), s, 1))
    PUT #1, , sprite(k)
  NEXT s

  e = LEN(activefoestack(0)): PUT #1, , e
  FOR e = 1 TO LEN(activefoestack(0))
    k = ASC(MID$(activefoestack(0), e, 1))
    PUT #1, , enemy(k)
  NEXT e

  FOR s = 1 TO 5: PUT #1, , shot(s): NEXT s

  FOR s = 1 TO 25: PUT #1, , switch(s): NEXT s

  FOR l = 1 TO numlifts: PUT #1, , lift(l): NEXT l
CLOSE 1

SLEEP 1

END SUB


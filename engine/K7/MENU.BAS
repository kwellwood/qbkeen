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

SELECT CASE menu
  CASE main: t& = menutile&
  CASE save: t& = menutile& + 1
  CASE load: t& = menutile& + 2
  CASE options: t& = menutile& + 3
END SELECT

PutSprite t&, 0, 0, drawpage

frame& = (INT(anmcounter / selectordelay) MOD selectorframes) + selectorstartfrm&
PutSprite frame&, menux, menuy + ((menuopt - 1) * selectionpixels), drawpage

END SUB

SUB HandleMenu (k)

IF TIMER < menudelay! THEN EXIT SUB

SELECT CASE k
 CASE keyup
  IF menuopt > 1 THEN menuopt = menuopt - 1: menudelay! = TIMER + .1
 CASE keydown
  SELECT CASE menu
   CASE main: max = 5
   CASE save: max = 1
   CASE load: max = 1
   CASE options: max = 1
  END SELECT
  IF menuopt < max THEN menuopt = menuopt + 1: menudelay! = TIMER + .1
 CASE keyenter
  SELECT CASE menu
   CASE main
    SELECT CASE menuopt
     CASE 1  'newgame
     CASE 2  'savegame
     CASE 3  'loadgame
     CASE 4  'options
     CASE 5: quitgame = 1
    END SELECT
   CASE save
   CASE load
   CASE options
  END SELECT
  menudelay! = TIMER + .1
 CASE keyesc
  IF player(0).action <> dying THEN
    IF menu <> main THEN menu = main ELSE gamemode = ingame
    menudelay! = TIMER + .2
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


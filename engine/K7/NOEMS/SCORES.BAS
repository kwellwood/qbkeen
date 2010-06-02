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
DebugLog "Error in scores module"
ErrorHandlerSub e
RESUME NEXT

REM $STATIC
SUB DrawNumber (digits, x, y, n&)

FOR d = digits TO 0 STEP -1
  digit = FIX(n& / 10 ^ d)
  IF digit AND d > 0 THEN
    PutTile Scoredigit& + digit, boardx + x + ((digits - 1 - d) * 8), boardy + y, drawpage
    n& = n& MOD 10 ^ d
    numberstarted = 1
   ELSEIF numberstarted THEN
    PutTile Scoredigit& + digit, boardx + x + ((digits - 1 - d) * 8), boardy + y, drawpage
    n& = n& MOD 10 ^ d
   ELSEIF d = 0 THEN
    PutTile Scoredigit& + digit, boardx + x + ((digits - 1 - d) * 8), boardy + y, drawpage
  END IF
NEXT d

END SUB

SUB DrawScoreboard

PutTile scoreboard&, boardx, boardy, drawpage

s& = player(0).score: l& = player(0).lives: a& = player(0).ammo
DrawNumber 9, 6, 4, s&
DrawNumber 2, 22, 20, l&
DrawNumber 2, 62, 20, a&

END SUB

SUB InitScoreboard

OPEN "scores.dat" FOR INPUT AS 1
  INPUT #1, scoreboard&
  INPUT #1, Scoredigit&
  INPUT #1, boardx
  INPUT #1, boardy
CLOSE 1

player(0).lives = 3
player(0).ammo = 5
player(0).score = 0

END SUB


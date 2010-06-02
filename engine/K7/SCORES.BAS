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
SUB DrawNumber (digits, x, y, n&)

'step through the score from left to right and
' display each digit with a correspoding pic of
' the digit in score font.

'digits = number of digits to display
'   x,y = location
'    n& = number to display

' "001530"   "001530"   "001530"
'    |           |       |

n2& = n&
FOR d = digits TO 0 STEP -1
  a& = 10 ^ d: digit = FIX(n& / a&)
  IF digit AND d > 0 THEN
    '- digit greater than zero found -
    PutTile Scoredigit& + digit, boardx + x + ((digits - 1 - d) * 8), boardy + y, drawpage
    n& = n& MOD 10 ^ d
    numberstarted = 1
   ELSEIF numberstarted THEN
    '- already found start of number -
    PutTile Scoredigit& + digit, boardx + x + ((digits - 1 - d) * 8), boardy + y, drawpage
    n& = n& MOD 10 ^ d
   ELSEIF d = 0 THEN
    '- hasnt found start yet -
    PutTile Scoredigit& + digit, boardx + x + ((digits - 1 - d) * 8), boardy + y, drawpage
  END IF
NEXT d

END SUB

SUB DrawScoreboard

PutTile scoreboard&, boardx, boardy, drawpage

s& = player(0).score
l& = player(0).lives
a& = player(0).ammo: IF a& > 99 THEN a& = 99
DrawNumber 9, 6, 4, s&
DrawNumber 2, 22, 20, l&
DrawNumber 2, 62, 20, a&

END SUB

SUB InitScoreboard

'OPEN "scores.dat" FOR INPUT AS 1
OPEN "engine.dat" FOR INPUT AS 1
  DO: INPUT #1, text$
  LOOP UNTIL UCASE$(text$) = "[SCORES.DAT]"
  INPUT #1, scoreboard&
  INPUT #1, Scoredigit&
  INPUT #1, boardx
  INPUT #1, boardy
CLOSE 1

END SUB


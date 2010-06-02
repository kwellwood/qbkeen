DEFINT A-Z
'$INCLUDE: 'engine.bi'
'$INCLUDE: 'directqb.bi'
'$INCLUDE: 'tiles.bi'
'$INCLUDE: 'scores.bi'
'$STATIC

ON ERROR GOTO ErrorHandler

DIM SHARED Scoreboard&, Scoredigit&, boardx, boardy
DIM SHARED loading&, loadx, loady
'============================================================================
ErrorHandler:
e = ERR
ErrorHandlerSub e
RESUME NEXT

SUB DrawLoadingBox

PutSprite loading&, loadx, loady, drawpage

OPEN "levels.dat" FOR INPUT AS 1
  INPUT #1, numlevels
  IF curlevel > numlevels OR curlevel < 0 THEN
    DebugLog "Level not in list:" + STR$(curlevel)
    ErrorHandlerSub 129
  END IF
  FOR l = 1 TO numlevels
    INPUT #1, mapfile$
    INPUT #1, mapname$
    IF l = curlevel THEN EXIT FOR
  NEXT l
CLOSE 1
IF DQBlen(mapname$) > 140 THEN
  totallen = DQBlen(mapname$)
  temp$ = mapname$: mapname$ = "": mapname2$ = ""
  WHILE DQBlen(mapname$ + LEFT$(temp$, INSTR(temp$, " "))) <= 144 AND INSTR(temp$, " ")
    mapname$ = mapname$ + LEFT$(temp$, INSTR(temp$, " "))
    temp$ = RIGHT$(temp$, LEN(temp$) - INSTR(temp$, " "))
  WEND
  mapname2$ = temp$
END IF
DQBprint drawpage, mapname$, 112, 78, 14
IF mapname2$ > "" THEN DQBprint drawpage, mapname2$, 120, 88, 14
IF ems THEN DQBcopyLayer drawpage, VIDEO

END SUB

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

PutTile Scoreboard&, boardx, boardy, drawpage

s& = player(0).score
l& = player(0).lives
a& = player(0).ammo: IF a& > 99 THEN a& = 99
DrawNumber 9, 6, 4, s&
DrawNumber 2, 22, 20, l&
DrawNumber 2, 62, 20, a&

END SUB

SUB InitScoreboard

OPEN "engine.dat" FOR INPUT AS 1
  DO: INPUT #1, Text$
  LOOP UNTIL UCASE$(Text$) = "[SCORES.DAT]"
  INPUT #1, Scoreboard&
  INPUT #1, Scoredigit&
  INPUT #1, boardx
  INPUT #1, boardy
  INPUT #1, loading&
  INPUT #1, loadx
  INPUT #1, loady
CLOSE 1

END SUB


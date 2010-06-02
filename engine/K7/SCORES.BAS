DEFINT A-Z
'$INCLUDE: 'engine.bi'
'$INCLUDE: 'directqb.bi'
'$INCLUDE: 'tiles.bi'
'$INCLUDE: 'scores.bi'
DECLARE SUB DrawScreen ()
'$STATIC

'--- Private Routines ---
DECLARE SUB DrawNumber (digits, x, y, n&)

ON ERROR GOTO ErrorHandler

DIM SHARED Scoreboard&, Scoredigit&, boardx, boardy
DIM SHARED loading&, loadx, loady
DIM SHARED dropdowntile&
'============================================================================
ErrorHandler:
e = ERR
ErrorHandlerSub e
RESUME NEXT

SUB DoDropdownStatus

IF showdropdownheight > -181 THEN
  showdropdownheight = showdropdownheight + 15
  gameplay = paused
END IF

IF showdropdownheight >= 0 THEN
  showdropdownheight = 0
  DrawScreen

  WHILE DQBkey(KEYENTER): WEND
  DO: LOOP UNTIL DQBkey(KEYCTRL) OR DQBkey(KEYSPACE) OR DQBkey(KEYENTER)
  WHILE DQBkey(KEYCTRL): WEND
  WHILE DQBkey(KEYSPACE): WEND
  WHILE DQBkey(KEYENTER): WEND
  showdropdownheight = -181
  gameplay = running
END IF

END SUB

SUB DrawDropdown (y)

PutSprite dropdowntile&, 0, y, drawpage

score& = player(0).score
nextlifeat& = player(0).nextlifeat
ammo& = player(0).ammo
drops& = player(0).drops
lives& = player(0).lives

DrawNumber 8, 72, 68 + y, score&
DrawNumber 7, 176, 68 + y, nextlifeat&
DrawNumber 3, 208, 108 + y, ammo&
DrawNumber 2, 216, 124 + y, drops&
DrawNumber 2, 120, 124 + y, lives&

IF player(0).keyred THEN PutSprite 1337, 119, 114 + y, drawpage
IF player(0).keyyel THEN PutSprite 1338, 127, 114 + y, drawpage
IF player(0).keyblu THEN PutSprite 1339, 135, 114 + y, drawpage
IF player(0).keygrn THEN PutSprite 1340, 143, 114 + y, drawpage
FOR a = 1 TO player(0).ancientsrescued
  PutSprite 1341, 79 + (a * 8 - 8), 96 + y, drawpage
NEXT a

titleline1$ = maplocation$
IF DQBlen(titleline1$) > 160 THEN
  totallen = DQBlen(title1line$)
  temp$ = titleline1$: titleline1$ = "": titleline2$ = ""
  WHILE DQBlen(titleline1$ + LEFT$(temp$, INSTR(temp$, " "))) <= 160 AND INSTR(temp$, " ")
    titleline1$ = titleline1$ + LEFT$(temp$, INSTR(temp$, " "))
    temp$ = RIGHT$(temp$, LEN(temp$) - INSTR(temp$, " "))
  WEND
  titleline2$ = temp$
END IF
IF titleline2$ = "" THEN line1y = 44 ELSE line1y = 40
DQBprint drawpage, titleline1$, 159 - DQBlen(titleline1$) / 2, line1y + y, 14
IF titleline2$ > "" THEN DQBprint drawpage, titleline2$, 159 - DQBlen(titleline2$) / 2, 49 + y, 14

DQBcopyLayer drawpage, video

END SUB

SUB DrawLoadingBox

PutSprite loading&, loadx, loady, drawpage

OPEN "levels.dat" FOR INPUT AS 1
  INPUT #1, numlevels
  IF curlevel > numlevels OR curlevel <= 0 THEN
    DebugLog "Level not in list:" + STR$(curlevel)
    ErrorHandlerSub 129
  END IF
  FOR l = 1 TO numlevels
    INPUT #1, temp1$
    INPUT #1, maplocation$   ' global variable, used later for drawdropdown()
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
DQBprint drawpage, mapname$, 182 - DQBlen(mapname$) / 2, 78, 14
IF mapname2$ > "" THEN DQBprint drawpage, mapname2$, 182 - DQBlen(mapname2$) / 2, 88, 14
IF ems THEN DQBcopyLayer drawpage, video

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
  INPUT #1, dropdowntile&
CLOSE 1

showdropdownheight = -181

END SUB


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
DIM SHARED dropdowntile&, AncientSpeakTile&, ancspeakx, ancspeaky
DIM SHARED KeenSpeakTile&, keenspeakx, keenspeaky
'============================================================================
ErrorHandler:
e = ERR
ErrorHandlerSub e
RESUME NEXT

SUB DoAncientRescued

gamemode = ingame
player(0).ancientsrescued = player(0).ancientsrescued + 1
IF player(0).ancientsrescued = totalancients THEN
  SetGameComplete
 ELSE
  SetLevelComplete
END IF

' Get the text to speak
OPEN "engine.dat" FOR INPUT AS 1
  DO: INPUT #1, temp$: LOOP UNTIL UCASE$(temp$) = "[ANCIENTS.DAT]"
  INPUT #1, ancientspeech$
  FOR a = 1 TO player(0).ancientsrescued
    INPUT #1, keenspeech$
  NEXT a
CLOSE 1

PutSprite AncientSpeakTile&, ancspeakx, ancspeaky, drawpage
speech$ = ancientspeech$: textline = 0
DO WHILE DQBlen(speech$) > 144
  textline$ = ""
  WHILE DQBlen(textline$ + LEFT$(speech$, INSTR(speech$, " "))) <= 144 AND INSTR(speech$, " ")
    textline$ = textline$ + LEFT$(speech$, INSTR(speech$, " "))
    speech$ = RIGHT$(speech$, LEN(speech$) - INSTR(speech$, " "))
  WEND
  DQBprint drawpage, textline$, 182 - DQBlen(textline$) / 2, 78 + textline * 10, 14
  textline = textline + 1
LOOP
DQBprint drawpage, speech$, 182 - DQBlen(speech$) / 2, 78 + textline * 10, 14
DQBcopyLayer drawpage, video
DO: LOOP UNTIL DQBkey(KEYENTER) OR DQBkey(KEYSPACE) OR DQBkey(KEYCTRL)
WHILE DQBkey(KEYENTER) OR DQBkey(KEYSPACE) OR DQBkey(KEYCTRL): WEND

PutSprite KeenSpeakTile&, keenspeakx, keenspeaky, drawpage
speech$ = keenspeech$: textline = 0
DO WHILE DQBlen(speech$) > 144
  textline$ = ""
  WHILE DQBlen(textline$ + LEFT$(speech$, INSTR(speech$, " "))) <= 144 AND INSTR(speech$, " ")
    textline$ = textline$ + LEFT$(speech$, INSTR(speech$, " "))
    speech$ = RIGHT$(speech$, LEN(speech$) - INSTR(speech$, " "))
  WEND
  DQBprint drawpage, textline$, 140 - DQBlen(textline$) / 2, 78 + textline * 10, 14
  textline = textline + 1
LOOP
DQBprint drawpage, speech$, 140 - DQBlen(speech$) / 2, 78 + textline * 10, 14
DQBcopyLayer drawpage, video
DO: LOOP UNTIL DQBkey(KEYENTER) OR DQBkey(KEYSPACE) OR DQBkey(KEYCTRL)
WHILE DQBkey(KEYENTER) OR DQBkey(KEYSPACE) OR DQBkey(KEYCTRL): WEND

PutSprite KeenSpeakTile& + 1, keenspeakx, keenspeaky, drawpage
DQBcopyLayer drawpage, video
DO: LOOP UNTIL DQBkey(KEYENTER) OR DQBkey(KEYSPACE) OR DQBkey(KEYCTRL)
WHILE DQBkey(KEYENTER) OR DQBkey(KEYSPACE) OR DQBkey(KEYCTRL): WEND

END SUB

SUB DoCantSwim

PutSprite KeenSpeakTile&, keenspeakx, keenspeaky, drawpage
speech$ = "I can't swim!": textline = 0
DO WHILE DQBlen(speech$) > 144
  textline$ = ""
  WHILE DQBlen(textline$ + LEFT$(speech$, INSTR(speech$, " "))) <= 144 AND INSTR(speech$, " ")
    textline$ = textline$ + LEFT$(speech$, INSTR(speech$, " "))
    speech$ = RIGHT$(speech$, LEN(speech$) - INSTR(speech$, " "))
  WEND
  DQBprint drawpage, textline$, 140 - DQBlen(textline$) / 2, 78 + textline * 10, 14
  textline = textline + 1
LOOP
DQBprint drawpage, speech$, 140 - DQBlen(speech$) / 2, 78 + textline * 10, 14
DQBcopyLayer drawpage, video
DO: LOOP UNTIL DQBkey(KEYENTER) OR DQBkey(KEYSPACE) OR DQBkey(KEYCTRL)
WHILE DQBkey(KEYENTER) OR DQBkey(KEYSPACE) OR DQBkey(KEYCTRL): WEND

END SUB

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

SUB DoGetScubaGear

IF player(0).scuba THEN EXIT SUB
player(0).scuba = 1

PutSprite KeenSpeakTile&, keenspeakx, keenspeaky, drawpage
speech$ = "Cool! I can breathe underwater now!": textline = 0
DO WHILE DQBlen(speech$) > 144
  textline$ = ""
  WHILE DQBlen(textline$ + LEFT$(speech$, INSTR(speech$, " "))) <= 144 AND INSTR(speech$, " ")
    textline$ = textline$ + LEFT$(speech$, INSTR(speech$, " "))
    speech$ = RIGHT$(speech$, LEN(speech$) - INSTR(speech$, " "))
  WEND
  DQBprint drawpage, textline$, 140 - DQBlen(textline$) / 2, 78 + textline * 10, 14
  textline = textline + 1
LOOP
DQBprint drawpage, speech$, 140 - DQBlen(speech$) / 2, 78 + textline * 10, 14
DQBcopyLayer drawpage, video
DO: LOOP UNTIL DQBkey(KEYENTER) OR DQBkey(KEYSPACE) OR DQBkey(KEYCTRL)
WHILE DQBkey(KEYENTER) OR DQBkey(KEYSPACE) OR DQBkey(KEYCTRL): WEND

PutSprite KeenSpeakTile& + 1, keenspeakx, keenspeaky, drawpage
DQBcopyLayer drawpage, video
DO: LOOP UNTIL DQBkey(KEYENTER) OR DQBkey(KEYSPACE) OR DQBkey(KEYCTRL)
WHILE DQBkey(KEYENTER) OR DQBkey(KEYSPACE) OR DQBkey(KEYCTRL): WEND

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

IF player(0).scuba THEN DQBprint drawpage, "Scuba Gear", 86, 145 + y, 14

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

SUB DrawLoadingBox (level)

PutSprite loading&, loadx, loady, drawpage

OPEN "levels.dat" FOR INPUT AS 1
  INPUT #1, temp
  FOR l = 1 TO level          ' maplocation$ is a global variable used
    IF EOF(1) THEN CLOSE 1: ErrorHandlerSub 123
    INPUT #1, temp$           '   later in drawdropdown()
    INPUT #1, maplocation$: INPUT #1, mapname$
    INPUT #1, temp: INPUT #1, temp: INPUT #1, temp
    FOR t = 1 TO temp
      INPUT #1, temp2: INPUT #1, temp2: INPUT #1, temp2: INPUT #1, temp2&
    NEXT t
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

FUNCTION GetMapLocation$

GetMapLocation$ = maplocation$

END FUNCTION

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
  INPUT #1, AncientSpeakTile&
  INPUT #1, ancspeakx
  INPUT #1, ancspeaky
  INPUT #1, KeenSpeakTile&
  INPUT #1, keenspeakx
  INPUT #1, keenspeaky
CLOSE 1

showdropdownheight = -181

END SUB


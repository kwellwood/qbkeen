ON ERROR GOTO help

DIM scr(400)
SCREEN 13: CLS

INPUT "start:", start
IF start < 0 THEN END
INPUT "finish:", finish
IF finish < 0 THEN END

OPEN "deleted.out" FOR APPEND AS 1
OPEN "list.out" FOR APPEND AS 3

FOR f = start TO finish
  file$ = "MAP-" + STRING$(3 - LEN(LTRIM$(STR$(f))), "0") + LTRIM$(STR$(f)) + ".QBI"
  keepthis = 0
  OPEN file$ FOR BINARY AS 2: l& = LOF(2): CLOSE 2
  IF l& > 0 THEN
    DEF SEG = VARSEG(scr(0))
    BLOAD file$, VARPTR(scr(0))
    DEF SEG
    PUT (0, 0), scr(0), PSET
    FOR y = 0 TO 15
      FOR x = 0 TO 15
        IF POINT(x, y) <> 7 THEN keepthis = 1
      NEXT x
    NEXT y
   
    IF keepthis = 0 THEN
      PRINT #1, "deleting " + file$
      PRINT #3, "BLANK.ART   , 99"
      KILL file$
     ELSEIF keepthis = 1 THEN
      PRINT #3, file$ + " , 0 , 0 , 0"
    END IF
   ELSEIF l& = 0 THEN
    PRINT #1, "skipping " + file$
    KILL file$
  END IF
NEXT f

CLOSE 3
CLOSE 1

END
help:
RESUME NEXT


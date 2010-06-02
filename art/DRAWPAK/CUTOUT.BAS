DEFINT A-Z
'$DYNAMIC
ON ERROR GOTO quit

DIM scr(32004)

SCREEN 13: CLS
INPUT "file:", file$
INPUT "prefix:", prefix$
IF LEN(prefix$) > 5 THEN prefix$ = LEFT$(prefix$, 5)
INPUT "curtile:", curtile

DEF SEG = VARSEG(scr(0))
 BLOAD file$, VARPTR(scr(0))
DEF SEG

PUT (0, 0), scr(0), PSET
backgroundcolor = POINT(319, 199)

OPEN "LIST.OUT" FOR APPEND AS 1

FOR y = 0 TO 10
  FOR x = 0 TO 17
    savetile = 0

    FOR ty = y * 17 TO y * 17 + 15
      FOR tx = x * 17 TO x * 17 + 15
        IF POINT(tx, ty) <> backgroundcolor THEN savetile = 1
      NEXT tx
    NEXT ty

    IF savetile = 1 THEN
      GET (x * 17, y * 17)-(x * 17 + 15, y * 17 + 15), scr(0)
      LINE (x * 17, y * 17)-(x * 17 + 15, y * 17 + 15), 4, BF
      DEF SEG = VARSEG(scr(0))
      file$ = prefix$ + STRING$(3 - LEN(LTRIM$(STR$(curtile))), "0") + LTRIM$(STR$(curtile)) + ".ART"
      BSAVE file$, VARPTR(scr(0)), 262
      DEF SEG
      PRINT #1, file$ + " , 0 , 0 , 0"
     ELSEIF savetile = 0 THEN
      PRINT #1, "NO_FILE"
    END IF
 
    curtile = curtile + 1
  NEXT x
NEXT y

CLOSE 1

END
quit:
END
RESUME NEXT


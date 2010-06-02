'$DYNAMIC
DEFINT A-Z
DECLARE SUB ShowFile (f$)
ON ERROR GOTO ErrorHandler

OPEN COMMAND$ FOR INPUT AS 2
DO
  INPUT #2, file$
  INPUT #2, size
  OPEN file$ FOR INPUT AS 1
  realsize = LOF(1): CLOSE 1
  IF realsize <> size THEN   'ShowFile file$
    PRINT "ERROR: " + file$ + " - View? [Y/N]"
    DO: a$ = "": WHILE a$ = "": a$ = INKEY$: WEND
    LOOP UNTIL LCASE$(a$) = "y" OR LCASE$(a$) = "n"
    IF LCASE$(a$) = "y" THEN ShowFile file$
  END IF
LOOP UNTIL EOF(2)
CLOSE 2

ErrorHandler:
CLOSE 2: END
RESUME NEXT

REM $STATIC
DEFSNG A-Z
SUB ShowFile (f$)

PRINT "============= " + f$ + " ============="
OPEN f$ FOR INPUT AS 1
  DO
    LINE INPUT #1, a$
    PRINT a$
    l = l + 1
    IF l > 23 THEN a$ = "": WHILE a$ = "": a$ = INKEY$: WEND: l = 0
  LOOP UNTIL EOF(1)
CLOSE 1
PRINT "============================" + STRING$(LEN(f$), "=")
PRINT " * PRESS A KEY *"
a$ = "": WHILE a$ = "": a$ = INKEY$: WEND

END SUB


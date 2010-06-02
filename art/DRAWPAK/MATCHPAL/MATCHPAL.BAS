DEFINT A-Z
'$DYNAMIC

ON ERROR GOTO errorhandler

TYPE hues
  red AS INTEGER
  grn AS INTEGER
  blu AS INTEGER
END TYPE

DECLARE SUB sethues (HUE() AS ANY, SC, EC)
DIM MyPal(255) AS hues
DIM SyraPal(255) AS hues
DIM index(255)            ' index(syra)=my
DIM rindex(255)           ' index(my)=syra
DIM scr(32001)

start:
INPUT "In picture: ", inpic$
IF LCASE$(inpic$) = "quit" OR inpic$ = "" THEN END
inpal$ = "keen.pal"
outpic$ = inpic$
'INPUT "In palette: ", inpal$
'INPUT "Out picture: ", outpic$

DEF SEG = VARSEG(MyPal(0))
BLOAD "engine.pal", 0
DEF SEG = VARSEG(SyraPal(0))
BLOAD inpal$, 0
DEF SEG = VARSEG(scr(0))
BLOAD inpic$, 0
DEF SEG

FOR MyCol = 0 TO 255
  'PRINT "picking match for my color:"; MyCol;
  matched = 0
  FOR SyraCol = 0 TO 255
    IF SyraPal(MyCol).red = MyPal(SyraCol).red THEN
      IF SyraPal(MyCol).grn = MyPal(SyraCol).grn THEN
        IF SyraPal(MyCol).blu = MyPal(SyraCol).blu THEN
          'PRINT ":exact match."
          index(MyCol) = SyraCol
          matched = 1
        END IF
      END IF
    END IF
  NEXT SyraCol
  IF matched = 0 THEN
    avgdist = 1000: mc = 0
    FOR SyraCol = 0 TO 255
     
      IF SyraPal(MyCol).red = MyPal(SyraCol).red THEN d1 = 0
      IF SyraPal(MyCol).red > MyPal(SyraCol).red THEN d1 = SyraPal(MyCol).red - MyPal(SyraCol).red
      IF SyraPal(MyCol).red < MyPal(SyraCol).red THEN d1 = MyPal(SyraCol).red - SyraPal(MyCol).red
     
      IF SyraPal(MyCol).grn = MyPal(SyraCol).grn THEN d2 = 0
      IF SyraPal(MyCol).grn > MyPal(SyraCol).grn THEN d2 = SyraPal(MyCol).grn - MyPal(SyraCol).grn
      IF SyraPal(MyCol).grn < MyPal(SyraCol).grn THEN d2 = MyPal(SyraCol).grn - SyraPal(MyCol).grn

      IF SyraPal(MyCol).blu = MyPal(SyraCol).blu THEN d3 = 0
      IF SyraPal(MyCol).blu > MyPal(SyraCol).blu THEN d3 = SyraPal(MyCol).blu - MyPal(SyraCol).blu
      IF SyraPal(MyCol).blu < MyPal(SyraCol).blu THEN d3 = MyPal(SyraCol).blu - SyraPal(MyCol).blu

      ad = d1 + d2 + d3
      IF ad < avgdist THEN mc = SyraCol: avgdist = ad
   
    NEXT SyraCol
    'PRINT ":average match."
    matched = 1: index(MyCol) = mc
  END IF
NEXT MyCol

SCREEN 13: CLS
sethues MyPal(), 0, 255
PUT (0, 0), scr, PSET
'a$ = "": WHILE a$ = "": a$ = INKEY$: WEND
FOR y = 0 TO 199
  FOR x = 0 TO 319
    PSET (x, y), index(POINT(x, y))
  NEXT x
NEXT y
GET (0, 0)-(319, 199), scr(0)
DEF SEG = VARSEG(scr(0))
BSAVE outpic$, 0, 64004
DEF SEG
'SCREEN 0: WIDTH 80, 25
GOTO start

errorhandler:
END
RESUME NEXT

REM $STATIC
SUB OldDifCheck
     
      'IF SyraPal(MyCol).red > MyPal(SyraCol).red THEN     'get red distance
      '  d1 = SyraPal(MyCol).red - MyPal(SyraCol).red
      ' ELSE
      '  IF SyraPal(MyCol).red = MyPal(SyraCol).red THEN
      '    d1 = 0
      '   ELSE
      '    d1 = MyPal(SyraCol).red - SyraPal(MyCol).red
      '  END IF
      'END IF
      'IF SyraPal(MyCol).grn > MyPal(SyraCol).grn THEN     'get grn distance
      '  d2 = SyraPal(MyCol).grn - MyPal(SyraCol).grn
      ' ELSE
      '  IF SyraPal(MyCol).grn = MyPal(SyraCol).grn THEN
      '    d2 = 0
      '   ELSE
      '    d2 = MyPal(SyraCol).grn - SyraPal(MyCol).grn
      '  END IF
      'END IF                                    'get blu distance
      'IF SyraPal(MyCol).blu > MyPal(SyraCol).blu THEN
      '  d3 = SyraPal(MyCol).blu - MyPal(SyraCol).blu
      ' ELSE
      '  IF SyraPal(MyCol).blu = MyPal(SyraCol).blu THEN
      '    d3 = 0
      '   ELSE
      '    d3 = MyPal(SyraCol).blu - SyraPal(MyCol).blu
      '  END IF
      'END IF

END SUB

SUB sethues (HUE() AS hues, SC, EC)

 OUT &H3C8, SC

 FOR I = SC TO EC
   OUT &H3C9, HUE(I).red: OUT &H3C9, HUE(I).grn: OUT &H3C9, HUE(I).blu
 NEXT

END SUB


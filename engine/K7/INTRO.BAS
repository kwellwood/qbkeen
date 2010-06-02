DECLARE SUB DrawLight (x%, y%, intensity%)
DEFINT A-Z
'$DYNAMIC
'$INCLUDE: 'directqb.bi'
COMMON SHARED maxlightintensity, size, definition

'-------------------------------------------------------------------------
maxlightintensity = 56    ' 56
size = 40                 ' 30
focus = 5                 '  7
'-------------------------------------------------------------------------

DIM SHARED SpotLight(size, size) AS INTEGER, sy(2), ay(2), scr(32004)
DIM pal AS STRING * 768

a = DQBinit(1, 0, 0)
IF a THEN PRINT "no ems": END
DQBinitVGA

' Initializes the spotlight array
FOR x = 0 TO size
  FOR y = 0 TO size
    SpotLight(x, y) = maxlightintensity - (SQR(((x - size \ 2) ^ 2) + ((y - size \ 2) ^ 2)) * focus)
  NEXT y
NEXT x

' Initializes palette
'FOR c = 0 TO 63: DQBsetCol c, 0, c, 0: NEXT c                'black to green
'FOR c = 64 TO 127: DQBsetCol c, c - 64, 63, c - 64: NEXT c   'green to white
FOR c = 0 TO 63: DQBsetCol c, 0, 0, c: NEXT c                 'black to blue
FOR c = 64 TO 127: DQBsetCol c, c - 64, c - 64, 63: NEXT c    'blue to white
FOR c = 128 TO 255: DQBsetCol c, 0, 0, 0: NEXT c              'all blackz
DQBgetPal pal

' Initializes background image
'a = DQBloadImage(1, 0, 0, "intro2.bmp", pal, 320, 200)
'IF a THEN SLEEP
'dqbget 1, 0, 0, 319, 199, VARSEG(scr(0)), VARPTR(scr(0))
'dqbclearlayer 1
DEF SEG = VARSEG(scr(0))
BLOAD "intro.qbi", VARPTR(scr(0))
DEF SEG

light1intensity = 100
light1intensity2 = 100
light2intensity = 0
light2intensity2 = 0

' Animates the spotlights
FOR t = -60 TO 280 STEP 2
 
  'light one
  x = -40 + (t * 1.2) - COS(t / 8) * 2
  y = 21 + SIN(t / 8) * 5
  DrawLight x, y, light1intensity
  IF t > 90 THEN light1intensity = light1intensity - 5

  'light one, seconday
  x = -80 + (t * 1.2) + COS(t / 8) * 2
  y = 21 - SIN(t / 8) * 5
  DrawLight x, y, light1intensity2
  IF t > 110 THEN light1intensity2 = light1intensity2 - 5

  'light two
  x = -35 + (t * 1.4) + COS(t / 6) * 2
  y = 94 + SIN(t / 6) * 4
  DrawLight x, y, light2intensity
  IF t > 60 THEN light2intensity = light2intensity + 8

  'light two, secondary
  x = -75 + (t * 1.4) - COS(t / 6) * 2
  y = 94 - SIN(t / 6) * 4
  DrawLight x, y, light2intensity2
  IF t > 90 THEN light2intensity2 = light2intensity2 + 8

  DO: LOOP WHILE TIMER < t! + .02
  DQBcopyLayer 1, 0
  DQBclearLayer 1
NEXT t

FOR c = 0 TO 127: DQBsetCol c, 63, 63, 63: NEXT c
DQBput 0, 0, 0, VARSEG(scr(0)), VARPTR(scr(0))
DQBfadeIn pal
SLEEP 2
DQBfadeTo 0, 0, 0

dqbinittext
dqbclose
END

REM $STATIC
SUB DrawLight (x, y, intensity)

IF intensity < 0 THEN intensity = 0
IF intensity > 100 THEN intensity = 100

' Draws a spotlight at the given coordinates
addr& = (y * 320&) + x
FOR yy = 0 TO size
  FOR xx = 0 TO size
    IF x + xx > 0 AND x + xx < 319 THEN
      DEF SEG = VARSEG(scr(0))
      col = INT((PEEK(addr& + xx) + SpotLight(xx, yy)) * (intensity / 100))
      IF col < 0 THEN col = 0
      IF col > 127 THEN col = 127
      DQBpset 1, x + xx, y + yy, col
    END IF
  NEXT xx
  addr& = addr& + 320
NEXT yy

END SUB


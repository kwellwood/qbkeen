'----------------------------------------------------------------------------
' DIRECTQB.BI
'   Include file for the DirectQB library version 1.61
'   by Angelo Mottola - Enhanced Creations 1998-99
'
' This file contains constants and function declarations used by the library
' Always include this file into your own programs!
'
' Include file created on 10-19-2002 by the DirectQB Library Manager v1.2
' Run DQBMAN again to modify your DirectQB module settings
'
' þ Read DIRECTQB.DOC for detailed informations on how to use the library
'----------------------------------------------------------------------------

'$DYNAMIC
DEFINT A-Z

' Procedures from MAIN.OBJ:
DECLARE FUNCTION DQBinit% (BYVAL NumLayers%, BYVAL NumSounds%, BYVAL MemSize%)
'DECLARE FUNCTION DQBver% ()
'DECLARE FUNCTION DQBid$ ()
'DECLARE FUNCTION DQBmapLayer% (BYVAL Layer%)
DECLARE SUB DQBclose ()
DECLARE SUB DQBpeek (BYVAL DataSeg%, BYVAL DataOff%, BYVAL Offset&, BYVAL Length%)
'DECLARE SUB DQBpoke (BYVAL DataSeg%, BYVAL DataOff%, BYVAL Offset&, BYVAL Length%)
'DECLARE SUB DQBsort (BYVAL ArraySeg%, BYVAL ArrayOff%, BYVAL NumRecords%, BYVAL RecordLen%, BYVAL IndexOff%)
DECLARE FUNCTION DQBangle% (BYVAL x1%, BYVAL y1%, BYVAL x2%, BYVAL y2%)
DECLARE SUB DQBinitVGA ()
DECLARE SUB DQBinitText ()
'DECLARE FUNCTION DQBsetBaseLayer% (BYVAL Layer%)
DECLARE SUB DQBcopyLayer (BYVAL SourceLayer%, BYVAL DestLayer%)
DECLARE SUB DQBclearLayer (BYVAL Layer%)
DECLARE SUB DQBwait (BYVAL Times%)
'DECLARE SUB DQBsetFrameRate (BYVAL FPS%)
'DECLARE FUNCTION DQBframeReady% ()
'DECLARE FUNCTION DQBerror$ ()

' Procedures from DRAW.OBJ:
'DECLARE SUB DQBcopyTransLayer (BYVAL SourceLayer%, BYVAL DestLayer%)
'DECLARE SUB DQBcopyHitLayer (BYVAL SourceLayer%, BYVAL DestLayer%, BYVAL Col%)
DECLARE SUB DQBpset (BYVAL Layer%, BYVAL x%, BYVAL y%, BYVAL Col%)
DECLARE FUNCTION DQBpoint% (BYVAL Layer%, BYVAL x%, BYVAL y%)
DECLARE SUB DQBline (BYVAL Layer%, BYVAL x1%, BYVAL y1%, BYVAL x2%, BYVAL y2%, BYVAL Col%)
'DECLARE SUB DQBgline (BYVAL Layer%, BYVAL x1%, BYVAL y1%, BYVAL x2%, BYVAL y2%, BYVAL Col1%, BYVAL Col2%)
'DECLARE SUB DQBellipse (BYVAL Layer%, BYVAL x%, BYVAL y%, BYVAL rx%, BYVAL ry%, BYVAL Col%)
DECLARE SUB DQBbox (BYVAL Layer%, BYVAL x1%, BYVAL y1%, BYVAL x2%, BYVAL y2%, BYVAL Col%)
DECLARE SUB DQBboxf (BYVAL Layer%, BYVAL x1%, BYVAL y1%, BYVAL x2%, BYVAL y2%, BYVAL Col%)
'DECLARE SUB DQBpaint (BYVAL Layer%, BYVAL x%, BYVAL y%, BYVAL Col%)
'DECLARE SUB DQBscroll (BYVAL Layer%, BYVAL dx%, BYVAL dy%)
'DECLARE SUB DQBscrollArea (BYVAL Layer%, BYVAL x1%, BYVAL y1%, BYVAL x2%, BYVAL y2%, BYVAL Direction%)
DECLARE SUB DQBsetTransPut ()
DECLARE SUB DQBsetSolidPut ()
DECLARE SUB DQBget (BYVAL Layer%, BYVAL x1%, BYVAL y1%, BYVAL x2%, BYVAL y2%, BYVAL BufSeg%, BYVAL BufOff%)
DECLARE SUB DQBput (BYVAL Layer%, BYVAL x%, BYVAL y%, BYVAL BufSeg%, BYVAL BufOff%)

' Procedures from IMAGE.OBJ:
DECLARE FUNCTION DQBloadImage% (Layer%, x%, y%, FileName$, Pal$, imgWidth%, imgHeight%)
DECLARE FUNCTION DQBsaveImage% (Layer%, x1%, y1%, x2%, y2%, FileName$, Pal$, Format%)
DECLARE FUNCTION DQBplayFLI% (FileName$, BufLayer%, KeyStop%, LoopFlag%)
DECLARE FUNCTION DQBopenFLI% (FileName$, Frames%, Speed%)
DECLARE SUB DQBplayFLIstep (BYVAL Layer%)
DECLARE SUB DQBcloseFLI ()

' Procedures from SPRITE.OBJ:
'DECLARE FUNCTION DQBsize% (BYVAL x1%, BYVAL y1%, BYVAL x2%, BYVAL y2%)
'DECLARE SUB DQBsetClipBox (BYVAL x1%, BYVAL y1%, BYVAL x2%, BYVAL y2%)
DECLARE SUB DQBfPut (BYVAL Layer%, BYVAL x%, BYVAL y%, BYVAL BufSeg%, BYVAL BufOff%)
'DECLARE SUB DQBsPut (BYVAL Layer%, BYVAL x%, BYVAL y%, BYVAL BufSeg%, BYVAL BufOff%, BYVAL NewWidth%, BYVAL NewHeight%)
'DECLARE SUB DQBrPut (BYVAL Layer%, BYVAL x%, BYVAL y%, BYVAL BufSeg%, BYVAL BufOff%, BYVAL Angle%, BYVAL Zoom%)
'DECLARE SUB DQBxPut (BYVAL SourceLayer%, BYVAL x1%, BYVAL y1%, BYVAL x2%, BYVAL y2%, BYVAL DestLayer%, BYVAL x%, BYVAL y%)
'DECLARE SUB DQBmPut (BYVAL Layer%, BYVAL x%, BYVAL y%, BYVAL BufSeg%, BYVAL BufOff%, BYVAL Flip%)
'DECLARE SUB DQBhPut (BYVAL Layer%, BYVAL x%, BYVAL y%, BYVAL BufSeg%, BYVAL BufOff%, BYVAL Col%)
'DECLARE SUB DQBtPut (BYVAL Layer%, BYVAL x%, BYVAL y%, BYVAL BufSeg%, BYVAL BufOff%, BYVAL BitMode%)
'DECLARE SUB DQBpPut (BYVAL Layer%, BYVAL x%, BYVAL y%, BYVAL BufSeg%, BYVAL BufOff%, BYVAL Pattern%)
'DECLARE SUB DQBputOver (BYVAL BackSeg%, BYVAL BackOff%, BYVAL x%, BYVAL y%, BYVAL BufSeg%, BYVAL BufOff%)
'DECLARE SUB DQBsetCollideMethod (BYVAL Method%)
'DECLARE FUNCTION DQBcollide% (BYVAL x1%, BYVAL y1%, BYVAL Seg1%, BYVAL Off1%, BYVAL x2%, BYVAL y2%, BYVAL Seg2%, BYVAL Off2%)
'DECLARE FUNCTION DQBcollideOnLayer% (BYVAL Layer%, BYVAL x%, BYVAL y%, BYVAL SpriteSeg%, BYVAL SpriteOff%)

' Procedures from PALETTE.OBJ:
DECLARE SUB DQBsetCol (BYVAL ColorIndex%, BYVAL Red%, BYVAL Green%, BYVAL Blue%)
DECLARE SUB DQBgetCol (BYVAL ColorIndex%, Red%, Green%, Blue%)
DECLARE FUNCTION DQBfindCol% (BYVAL Red%, BYVAL Green%, BYVAL Blue%)
DECLARE FUNCTION DQBfindPalCol% (Pal$, Red%, Green%, Blue%)
DECLARE SUB DQBsetPal (Pal$)
DECLARE SUB DQBgetPal (Pal$)
DECLARE SUB DQBfadeIn (Pal$)
DECLARE SUB DQBfadeStepIn (Pal$)
DECLARE SUB DQBfadeTo (BYVAL Red%, BYVAL Green%, BYVAL Blue%)
DECLARE SUB DQBfadeStepTo (BYVAL Red%, BYVAL Green%, BYVAL Blue%)
DECLARE SUB DQBpalOff ()
DECLARE SUB DQBpalRotate (BYVAL FirstCol%, BYVAL LastCol%, BYVAL RotDir%)

' Procedures from FONT.OBJ:
DECLARE SUB DQBprint (Layer%, Text$, x%, y%, Col%)
'DECLARE SUB DQBprints (Layer%, Text$, x%, y%, Col%, Style%)
DECLARE FUNCTION DQBlen% (Text$)
'DECLARE SUB DQBsetBIOSfont ()
DECLARE FUNCTION DQBloadFont% (FileName$)
DECLARE SUB DQBsetFont (Font$)
DECLARE SUB DQBsetTextStyle (BYVAL Style%)
DECLARE SUB DQBsetTextBackCol (BYVAL Col%)
'DECLARE SUB DQBsetTextSpacing (BYVAL Spacing%)
'DECLARE SUB DQBsetTextBMap (BYVAL BMap%)
'DECLARE SUB DQBsetFontTexture (BYVAL TextSeg%, BYVAL TextOff%)

' Procedures from KEYBOARD.OBJ:
DECLARE SUB DQBinstallKeyboard ()
DECLARE SUB DQBremoveKeyboard ()
DECLARE FUNCTION DQBkey% (BYVAL ScanCode%)
DECLARE FUNCTION DQBreadKey% ()
DECLARE SUB DQBwaitKey (BYVAL ScanCode%)
'DECLARE FUNCTION DQBasc% (BYVAL ScanCode%, BYVAL ShiftFlag%)
'DECLARE FUNCTION DQBinkey$ ()

' Library constants:
CONST VIDEO = 0
CONST KEYANY = -1, KEYESC = 1, KEYENTER = 28, KEYSPACE = 57
CONST KEYUP = 72, KEYDOWN = 80, KEYLEFT = 75, KEYRIGHT = 77
CONST KEYCTRL = 29, KEYALT = 56
CONST FORWARD = 0, BACKWARD = 1
CONST AUTO = -1, ONCE = 0, LOOPED = 1
CONST NONE = 0, SOLID = &H1


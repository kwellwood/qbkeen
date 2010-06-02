'$DYNAMIC
DEFINT A-Z

' Procedures from MAIN.OBJ:
DECLARE FUNCTION DQBinit% (BYVAL NumLayers%, BYVAL NumSounds%, BYVAL MemSize%)
'DECLARE FUNCTION DQBmapLayer% (BYVAL Layer%)
DECLARE SUB DQBclose ()
'DECLARE SUB DQBpeek (BYVAL DataSeg%, BYVAL DataOff%, BYVAL Offset&, BYVAL Length%)
'DECLARE SUB DQBpoke (BYVAL DataSeg%, BYVAL DataOff%, BYVAL Offset&, BYVAL Length%)
'DECLARE SUB DQBsort (BYVAL ArraySeg%, BYVAL ArrayOff%, BYVAL NumRecords%, BYVAL RecordLen%, BYVAL IndexOff%)
'DECLARE FUNCTION DQBangle% (BYVAL x1%, BYVAL y1%, BYVAL x2%, BYVAL y2%)
DECLARE SUB DQBinitVGA ()
DECLARE SUB DQBinitText ()
DECLARE FUNCTION DQBsetBaseLayer% (BYVAL Layer%)
DECLARE SUB DQBcopyLayer (BYVAL SourceLayer%, BYVAL DestLayer%)
DECLARE SUB DQBclearLayer (BYVAL Layer%)
DECLARE SUB DQBwait (BYVAL Times%)
DECLARE SUB DQBsetFrameRate (BYVAL FPS%)
DECLARE FUNCTION DQBframeReady% ()
'DECLARE FUNCTION DQBerror$ ()

' Procedures from DRAW.OBJ:
DECLARE SUB DQBcopyTransLayer (BYVAL SourceLayer%, BYVAL DestLayer%)
'DECLARE SUB DQBcopyHitLayer (BYVAL SourceLayer%, BYVAL DestLayer%, BYVAL Col%)
DECLARE SUB DQBpset (BYVAL Layer%, BYVAL x%, BYVAL y%, BYVAL Col%)
DECLARE SUB DQBline (BYVAL Layer%, BYVAL x1%, BYVAL y1%, BYVAL x2%, BYVAL y2%, BYVAL Col%)
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
'DECLARE FUNCTION DQBplayFLI% (FileName$, BufLayer%, KeyStop%, LoopFlag%)
'DECLARE FUNCTION DQBopenFLI% (FileName$, Frames%, Speed%)
'DECLARE SUB DQBplayFLIstep (BYVAL Layer%)
'DECLARE SUB DQBcloseFLI ()

' Procedures from SPRITE.OBJ:
DECLARE SUB DQBfPut (BYVAL Layer%, BYVAL x%, BYVAL y%, BYVAL BufSeg%, BYVAL BufOff%)
'DECLARE SUB DQBsPut (BYVAL Layer%, BYVAL x%, BYVAL y%, BYVAL BufSeg%, BYVAL BufOff%, BYVAL NewWidth%, BYVAL NewHeight%)
'DECLARE SUB DQBrPut (BYVAL Layer%, BYVAL x%, BYVAL y%, BYVAL BufSeg%, BYVAL BufOff%, BYVAL Angle%, BYVAL Zoom%)
'DECLARE SUB DQBxPut (BYVAL SourceLayer%, BYVAL x1%, BYVAL y1%, BYVAL x2%, BYVAL y2%, BYVAL DestLayer%, BYVAL x%, BYVAL y%)
'DECLARE SUB DQBmPut (BYVAL Layer%, BYVAL x%, BYVAL y%, BYVAL BufSeg%, BYVAL BufOff%, BYVAL Flip%)
'DECLARE SUB DQBhPut (BYVAL Layer%, BYVAL x%, BYVAL y%, BYVAL BufSeg%, BYVAL BufOff%, BYVAL Col%)
'DECLARE SUB DQBtPut (BYVAL Layer%, BYVAL x%, BYVAL y%, BYVAL BufSeg%, BYVAL BufOff%, BYVAL BitMode%)
'DECLARE SUB DQBpPut (BYVAL Layer%, BYVAL x%, BYVAL y%, BYVAL BufSeg%, BYVAL BufOff%, BYVAL Pattern%)
'DECLARE SUB DQBputOver (BYVAL BackSeg%, BYVAL BackOff%, BYVAL x%, BYVAL y%, BYVAL BufSeg%, BYVAL BufOff%)

' Procedures from PALETTE.OBJ:
'DECLARE SUB DQBsetCol (BYVAL ColorIndex%, BYVAL Red%, BYVAL Green%, BYVAL Blue%)
'DECLARE SUB DQBgetCol (BYVAL ColorIndex%, Red%, Green%, Blue%)
'DECLARE FUNCTION DQBfindCol% (BYVAL Red%, BYVAL Green%, BYVAL Blue%)
'DECLARE FUNCTION DQBfindPalCol% (Pal$, Red%, Green%, Blue%)
'DECLARE SUB DQBsetPal (Pal$)
'DECLARE SUB DQBgetPal (Pal$)
'DECLARE SUB DQBfadeIn (Pal$)
'DECLARE SUB DQBfadeStepIn (Pal$)
DECLARE SUB DQBfadeTo (BYVAL Red%, BYVAL Green%, BYVAL Blue%)
'DECLARE SUB DQBfadeStepTo (BYVAL Red%, BYVAL Green%, BYVAL Blue%)
'DECLARE SUB DQBpalOff ()
'DECLARE SUB DQBpalRotate (BYVAL FirstCol%, BYVAL LastCol%, BYVAL RotDir%)

' Procedures from FONT.OBJ:
DECLARE SUB DQBprint (Layer%, Text$, x%, y%, Col%)
'DECLARE SUB DQBprints (Layer%, Text$, x%, y%, Col%, Style%)
DECLARE FUNCTION DQBlen% (Text$)
'DECLARE SUB DQBsetBIOSfont ()
DECLARE FUNCTION DQBloadFont% (FileName$)
'DECLARE SUB DQBsetFont (Font$)
'DECLARE SUB DQBsetTextStyle (BYVAL Style%)
'DECLARE SUB DQBsetTextBackCol (BYVAL Col%)
'DECLARE SUB DQBsetTextSpacing (BYVAL Spacing%)
'DECLARE SUB DQBsetTextBMap (BYVAL BMap%)
'DECLARE SUB DQBsetFontTexture (BYVAL TextSeg%, BYVAL TextOff%)

' Procedures from BLENDING.OBJ:
DECLARE SUB DQBfilterBox (BYVAL Layer%, BYVAL x1%, BYVAL y1%, BYVAL x2%, BYVAL y2%, BYVAL Col%, BYVAL BMap%)
'DECLARE SUB DQBbPut (BYVAL Layer%, BYVAL x%, BYVAL y%, BYVAL BufSeg%, BYVAL BufOff%, BYVAL BMap%)
'DECLARE SUB DQBcopyBlendLayer (BYVAL SourceLayer%, BYVAL DestLayer%, BYVAL BMap%)
DECLARE FUNCTION DQBcreateBMap% (BYVAL BMap%, BYVAL FirstCol%, BYVAL LastCol%)
DECLARE FUNCTION DQBloadBMap% (BMap%, FileName$)
'DECLARE FUNCTION DQBsaveBMap% (BMap%, FileName$)
'DECLARE SUB DQBsetBMap (BYVAL BMap%, BYVAL ForeCol%, BYVAL BackCol%, BYVAL NewCol%)
'DECLARE FUNCTION DQBgetBMap% (BYVAL BMap%, BYVAL ForeCol%, BYVAL BackCol%)

' Procedures from KEYBOARD.OBJ:
DECLARE SUB DQBinstallKeyboard ()
DECLARE SUB DQBremoveKeyboard ()
DECLARE FUNCTION DQBkey% (BYVAL ScanCode%)
DECLARE FUNCTION DQBreadKey% ()
DECLARE SUB DQBwaitKey (BYVAL ScanCode%)
DECLARE FUNCTION DQBasc% (BYVAL ScanCode%, BYVAL ShiftFlag%)
DECLARE FUNCTION DQBinkey$ ()

' Procedures from MOUSE.OBJ:
'DECLARE FUNCTION DQBmouseDetected% ()
'DECLARE FUNCTION DQBmouseX% ()
'DECLARE FUNCTION DQBmouseY% ()
'DECLARE FUNCTION DQBmouseLB% ()
'DECLARE FUNCTION DQBmouseRB% ()
'DECLARE SUB DQBsetMousePos (BYVAL x%, BYVAL y%)
'DECLARE SUB DQBmouseShow ()
'DECLARE SUB DQBmouseHide ()
'DECLARE SUB DQBsetMouseRange (BYVAL x1%, BYVAL y1%, BYVAL x2%, BYVAL y2%)
'DECLARE SUB DQBsetMouseShape (hotX%, hotY%, Shape$)
'DECLARE SUB DQBsetMouseSpeed (BYVAL HorSpeed%, BYVAL VerSpeed%)
'DECLARE SUB DQBresetMouse ()

' Procedures from SOUND.OBJ:
DECLARE FUNCTION DQBinstallSB% (BYVAL VolActive%, BYVAL Channels%, BYVAL Freq%, BYVAL BaseAddr%, BYVAL IRQ%, BYVAL DMA%)
DECLARE FUNCTION DQBloadSound% (Slot%, FileName$)
DECLARE FUNCTION DQBinUse% (BYVAL Voice%)
DECLARE SUB DQBplaySound (BYVAL SoundNum%, BYVAL Voice%, BYVAL Freq%, BYVAL LoopFlag%)
DECLARE SUB DQBsetVoiceVol (BYVAL Voice%, BYVAL NewVol%)
DECLARE SUB DQBpauseSound ()
DECLARE SUB DQBresumeSound ()
DECLARE SUB DQBstopVoice (BYVAL Voice%)
DECLARE SUB DQBremoveSB ()
DECLARE SUB DQBsetVolume (BYVAL Volume%)

' Procedures from DATAFILE.OBJ:
DECLARE FUNCTION DQBopenDataFile (FileName$, Password$)
DECLARE FUNCTION DQBunpackFont (PacketID%, Font$)
DECLARE FUNCTION DQBunpackImage (BYVAL PacketID%, BYVAL Layer%, BYVAL x%, BYVAL y%)
DECLARE FUNCTION DQBunpackSprite (BYVAL PacketID%, BYVAL SpriteSeg%, BYVAL SpriteOff%)
DECLARE FUNCTION DQBunpackSound (BYVAL PacketID%, BYVAL Slot%)
DECLARE FUNCTION DQBunpackPal (PacketID%, Pal$)
DECLARE FUNCTION DQBunpackBMap (BYVAL PacketID%, BYVAL BMap%)
DECLARE FUNCTION DQBunpackCursor (PacketID%, Cursor$)
DECLARE FUNCTION DQBunpackUser (BYVAL PacketID%, BYVAL DataSeg%, BYVAL DataOff%)
DECLARE SUB DQBcloseDataFile ()

' Library constants:
CONST VIDEO = 0
CONST FORWARD = 0, BACKWARD = 1
CONST CENTERED = &H8000, NONE = 0, SOLID = &H1, BOLD = &H2, ITALIC = &H4
CONST UNDERLINED = &H8, BLENDED = &H10, TEXTURED = &H20
CONST KEYANY = -1, KEYESC = 1, KEYENTER = 28, KEYSPACE = 57
CONST KEYUP = 72, KEYDOWN = 80, KEYLEFT = 75, KEYRIGHT = 77, KEYCTRL = 29
CONST UP = 0, DOWN = 1, LEFT = 2, RIGHT = 3
CONST AUTO = -1, ONCE = 0, LOOPED = 1


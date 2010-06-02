'$DYNAMIC
DEFINT A-Z

' Procedures from MAIN.OBJ:
DECLARE FUNCTION DQBinit% (BYVAL NumLayers%, BYVAL NumSounds%, BYVAL MemSize%)
DECLARE SUB DQBclose ()
DECLARE FUNCTION DQBangle% (BYVAL x1%, BYVAL y1%, BYVAL x2%, BYVAL y2%)
DECLARE SUB DQBinitVGA ()
DECLARE SUB DQBinitText ()
DECLARE SUB DQBcopyLayer (BYVAL SourceLayer%, BYVAL DestLayer%)
DECLARE SUB DQBwait (BYVAL Times%)
DECLARE SUB DQBsetFrameRate (BYVAL FPS%)
DECLARE FUNCTION DQBframeReady% ()

' Procedures from DRAW.OBJ:
DECLARE SUB DQBpset (BYVAL Layer%, BYVAL x%, BYVAL y%, BYVAL Col%)
DECLARE SUB DQBline (BYVAL Layer%, BYVAL x1%, BYVAL y1%, BYVAL x2%, BYVAL y2%, BYVAL Col%)
DECLARE SUB DQBboxf (BYVAL Layer%, BYVAL x1%, BYVAL y1%, BYVAL x2%, BYVAL y2%, BYVAL Col%)
DECLARE SUB DQBsetTransPut ()
DECLARE SUB DQBsetSolidPut ()
DECLARE SUB DQBput (BYVAL Layer%, BYVAL x%, BYVAL y%, BYVAL BufSeg%, BYVAL BufOff%)

' Procedures from FONT.OBJ:
DECLARE SUB DQBprint (Layer%, Text$, x%, y%, Col%)
DECLARE FUNCTION DQBlen% (Text$)
DECLARE FUNCTION DQBloadFont% (FileName$)

' Procedures from KEYBOARD.OBJ:
DECLARE SUB DQBinstallKeyboard ()
DECLARE SUB DQBremoveKeyboard ()
DECLARE FUNCTION DQBkey% (BYVAL ScanCode%)

' Library constants:
CONST VIDEO = 0
CONST KEYANY = -1, KEYESC = 1, KEYENTER = 28, KEYSPACE = 57
CONST KEYUP = 72, KEYDOWN = 80, KEYLEFT = 75, KEYRIGHT = 77
CONST KEYCTRL = 29, KEYALT = 56


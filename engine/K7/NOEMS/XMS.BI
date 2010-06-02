'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%[ LIBCALLS.H ]%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'--------------------------------[ FUNCTIONS ]-------------------------------
DECLARE FUNCTION BiosGetKeyW$ ()
DECLARE FUNCTION BiosMInit% ()
DECLARE FUNCTION BiosMLButton% ()
DECLARE FUNCTION BiosMRButton% ()
DECLARE FUNCTION BiosMWhereX% ()
DECLARE FUNCTION BiosMWhereY% ()
DECLARE FUNCTION BiosXLFree& ()
DECLARE FUNCTION BiosXTFree& ()
DECLARE FUNCTION WHICHCPU% ()
DECLARE FUNCTION WHICHMOUSE% ()
'------------------------------[ SUB ROUTINES ]------------------------------
DECLARE SUB BiosMHide ()
DECLARE SUB BiosMShow ()
DECLARE SUB BiosXClose (BYVAL handle%)
DECLARE SUB BiosXOpen (KBytes&, handle%, ErrCode%)
DECLARE SUB BiosXRead (BYVAL handle%, Posn&, bytes&, BYVAL DSeg%, BYVAL DOfs%)
DECLARE SUB BiosXWrite (BYVAL handle%, Posn&, bytes&, BYVAL DSeg%, BYVAL DOfs%)


DEFINT A-Z
'$DYNAMIC

DECLARE SUB BiosXClose (BYVAL handle%)
DECLARE SUB BiosXOpen (KBytes&, handle%, ErrCode%)
DECLARE SUB BiosXRead (BYVAL handle%, Posn&, bytes&, BYVAL DSeg%, BYVAL DOfs%)
DECLARE SUB BiosXWrite (BYVAL handle%, Posn&, bytes&, BYVAL DSeg%, BYVAL DOfs%)


DEFINT A-Z
'$DYNAMIC
DECLARE FUNCTION XMSError% ()
DECLARE FUNCTION WhichXError% ()
DECLARE FUNCTION GetXMS% (handle%)
DECLARE SUB InitXMS (there%, memsize%)
DECLARE SUB FreeXMS (handle%)
DECLARE SUB XSetElement (handle%, array AS ANY, elementSize%, element%)
DECLARE SUB XGetElement (handle%, array AS ANY, elementSize%, element%)


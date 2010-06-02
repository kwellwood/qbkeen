DEFINT A-Z
'$DYNAMIC

CONST maxsounds = 48
COMMON SHARED soundset$

DECLARE SUB InitSound ()
DECLARE SUB LoadMusic (file$)
DECLARE SUB LoadSounds ()
DECLARE SUB PlayMusic (slot)
DECLARE SUB PlaySound (slot)
DECLARE SUB ShutdownSound ()


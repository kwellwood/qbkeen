DEFINT A-Z
'$DYNAMIC

CONST maxsounds = 48
COMMON SHARED maxchannels, soundset$, channel, SoundEnabled

DECLARE SUB InitSound ()
DECLARE SUB LoadMusic (file$)
DECLARE SUB LoadSounds ()
DECLARE SUB PlayMusic (Slot)
DECLARE SUB PlaySound (Slot)
DECLARE SUB ShutdownSound ()


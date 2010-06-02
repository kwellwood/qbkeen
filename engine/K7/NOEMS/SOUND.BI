DEFINT A-Z
'$DYNAMIC

CONST maxsounds = 48
COMMON SHARED maxchannels, soundset$, channel, SoundEnabled

DECLARE SUB InitSound ()
DECLARE SUB LoadSounds ()
DECLARE SUB PlaySound (slot)


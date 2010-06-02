DEFINT A-Z
'$DYNAMIC

'$INCLUDE: 'engine.bi'
'$INCLUDE: 'directqb.bi'
'$INCLUDE: 'xms.bi'
'$INCLUDE: 'paklib.bi'
'$INCLUDE: 'plugins.bi'

ON ERROR GOTO ErrorHandler

'============================================================================
ErrorHandler:
e = ERR
ErrorHandlerSub e
RESUME NEXT

REM $STATIC
SUB InitSound

IF SoundEnabled THEN
  a = DQBinstallSB(false, maxchannels, 22050, auto, auto, auto)
  IF a THEN ErrorHandlerSub 139 + a
END IF

channel = 1

IF SoundEnabled THEN LoadSounds

END SUB

SUB LoadSounds

OPEN soundset$ FOR INPUT AS 1
  INPUT #1, numsounds
  IF numsounds > maxsounds THEN DebugLog "WARNING: Too many sounds:" + STR$(numsounds): numsounds = maxsounds
  
  FOR s = 1 TO numsounds
    INPUT #1, soundfile$
    a = DQBloadSound(s, soundfile$)
    IF a THEN ErrorHandlerSub 154 + a
  NEXT s
CLOSE 1

END SUB

SUB PlaySound (slot)

IF SoundEnabled = 0 THEN EXIT SUB

DQBplaySound slot, channel, 22050, once

channel = channel + 1
IF channel > maxchannels THEN channel = 1

END SUB


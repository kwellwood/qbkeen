DEFINT A-Z
'$DYNAMIC

'$INCLUDE: 'engine.bi'
'$INCLUDE: 'directqb.bi'
'$INCLUDE: 'xms.bi'
'$INCLUDE: 'paklib.bi'
'$INCLUDE: 'dextern.bi'
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
  a = DS4QB.Init(HIGHQUALITY, DEFAULT)
  IF a THEN ErrorHandlerSub 139 - a    ' error codes are negative
END IF

channel = 1

IF SoundEnabled THEN LoadSounds

END SUB

SUB LoadMusic (file$)

DS4QB.StopMusic 1
DS4QB.LoadMusic 1, ".\MUSIC\" + file$, mus.looping OR mus.surround
DS4QB.SetMusicAttr 1, 30, CURRENT
PlayMusic 1

END SUB

SUB LoadSounds

OPEN soundset$ FOR INPUT AS 1
  INPUT #1, numsounds
  IF numsounds > maxsounds THEN debuglog "WARNING: Too many sounds:" + STR$(numsounds): numsounds = maxsounds

  FOR s = 1 TO numsounds
    INPUT #1, soundfile$
    DS4QB.LoadSound s, soundfile$, DEFAULT
  NEXT s
CLOSE 1

END SUB

SUB PlayMusic (Slot)

DS4QB.PlayMusic Slot

END SUB

SUB PlaySound (Slot)

IF SoundEnabled = 0 THEN EXIT SUB

DS4QB.PlaySound Slot

END SUB

SUB ShutdownSound

DS4QB.Close

END SUB


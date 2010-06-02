DEFINT A-Z
'$INCLUDE: 'engine.bi'
'$INCLUDE: 'dextern.bi'
'$INCLUDE: 'sound.bi'
'$STATIC

DECLARE SUB ErrorHandlerSub (e)

CONST maxsounds = 48

ON ERROR GOTO ErrorHandler

DIM SHARED soundsys, soundset$
'============================================================================
ErrorHandler:
e = ERR
ErrorHandlerSub e
RESUME NEXT

SUB EndMusic

IF soundsys THEN DS4QB.StopMusic 1

END SUB

SUB InitSound

IF soundsys THEN
  a = DS4QB.Init(CURRENT, DEFAULT)
  IF a THEN ErrorHandlerSub 139 - a    ' error codes are negative

  LoadSounds
END IF

END SUB

SUB LoadMusic (file$)

IF soundsys THEN
  DS4QB.StopMusic 1
  DS4QB.LoadMusic 1, ".\MUSIC\" + file$, mus.looping OR mus.surround
  DS4QB.SetMusicAttr 1, 75, CURRENT
  PlayMusic 1
END IF

END SUB

SUB LoadSounds

IF soundsys THEN
  OPEN "engine.dat" FOR INPUT AS 1
  DO: INPUT #1, Text$
  LOOP UNTIL UCASE$(Text$) = "[" + UCASE$(soundset$) + "]"
   
    INPUT #1, NumSounds
    IF NumSounds > maxsounds THEN DebugLog "WARNING: Too many sounds:" + STR$(NumSounds): NumSounds = maxsounds

    FOR s = 1 TO NumSounds
      INPUT #1, soundfile$
      DS4QB.LoadSound s, soundfile$, DEFAULT
    NEXT s
  CLOSE 1
END IF

END SUB

SUB PlayMusic (slot)

DS4QB.PlayMusic slot

END SUB

SUB PlaySound (slot)

'IF soundsys THEN DS4QB.AddSound slot, CURRENT, CURRENT, CURRENT, CURRENT
IF soundsys THEN DS4QB.PlaySound slot

END SUB

SUB PlaySoundBuffer

'IF soundsys THEN DS4QB.PlaySounds

END SUB

SUB SetSoundSet (file$)

soundset$ = file$

END SUB

SUB SetSoundSys (state)

soundsys = state

END SUB

SUB ShutdownSound

IF soundsys THEN DS4QB.Close

END SUB


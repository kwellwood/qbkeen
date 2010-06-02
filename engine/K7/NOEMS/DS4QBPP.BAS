DEFINT A-Z
'$INCLUDE: 'DS4QBPP.BI'
'$INCLUDE: 'DEXTERN.BI'

DIM SHARED ErrNum, OS, xSound, xMusic
DIM SHARED MusType(512), MusRows(512)

REM $DYNAMIC
FUNCTION Combine& (Order AS LONG, Row AS LONG)
 ' I wish QB had pointers!

 DIM NewLong AS LONG

 DEF SEG = VARSEG(LoWord)
  LB1 = PEEK(VARPTR(Order))
  LB2 = PEEK(VARPTR(Order) + 1)
 DEF SEG = VARSEG(LoWord)
  HB1 = PEEK(VARPTR(Row))
  HB2 = PEEK(VARPTR(Row) + 1)
 DEF SEG = VARSEG(NewLong)
  POKE (VARPTR(NewLong)), LB1
  POKE (VARPTR(NewLong) + 1), LB2
  POKE (VARPTR(NewLong) + 2), HB1
  POKE (VARPTR(NewLong) + 3), HB2
 DEF SEG

 Combine& = NewLong

END FUNCTION

SUB CrashFix
 Handle = FREEFILE
 OPEN "SOUNDSYS.CFG" FOR BINARY AS #Handle
  GET #Handle, , OS
  GET #Handle, , xSound
  GET #Handle, , xMusic
  GET #Handle, , tmpSoundQuality&
 CLOSE #Handle
 DS4QB.Close
END SUB

SUB DeleteFiles
 IF FileExsist(OUTFILE) THEN KILL OUTFILE
 IF FileExsist(INFILE) THEN KILL INFILE
 IF FileExsist(SENDCONFIRM) THEN KILL SENDCONFIRM
 IF FileExsist(RECEIVECONFIRM) THEN KILL RECEIVECONFIRM
 IF FileExsist("START.EXE") THEN SHELL "DEL START.EXE >NUL"
 IF FileExsist("BASS.DLL") THEN SHELL "DEL BASS.DLL >NUL"
 IF FileExsist("DS4QBXX.EXE") THEN SHELL "DEL DS4QBXX.EXE >NUL"
END SUB

SUB DS4QB.Close
 DIM Temp AS CHUNKxCMDxCLOSE

 Temp.ID = CMD.CLOSE
 
 't# = TIMER: WHILE TIMER - t# < 1: WEND

 Handle = ReadySend
  PUT #Handle, 1, Temp
 StopSend Handle
 SendMessage
 'WaitConfirm

 t# = TIMER: WHILE TIMER - t# < 1: WEND

 DeleteFiles
END SUB

SUB DS4QB.DeleteMusic (Slot AS INTEGER)
 DIM Temp AS CHUNKxCMDxDELETEMUSIC

 Temp.ID = CMD.DELETEMUSIC
 Temp.Slot = Slot

 Handle = ReadySend%
  PUT #Handle, 1, Temp
 StopSend Handle
 SendMessage
 WaitConfirm
END SUB

SUB DS4QB.DeleteSound (Slot AS INTEGER)
 IF xSound = DEACTIVE THEN EXIT SUB

 DIM Temp AS CHUNKxCMDxDELETESND

 Temp.ID = CMD.DELETESND
 Temp.Slot = Slot

 Handle = ReadySend%
  PUT #Handle, 1, Temp
 StopSend Handle
 SendMessage
 WaitConfirm
END SUB

FUNCTION DS4QB.GetMusicLength& (Slot AS INTEGER)
 IF xMusic = DEACTIVE THEN EXIT FUNCTION

 DIM Temp AS CHUNKxCMDxGETMUSICLENGTH
 DIM IN4  AS STRING * 4

 Temp.ID = CMD.GETMUSICLENGTH
 Temp.Slot = Slot

 Handle = ReadySend%
  PUT #Handle, 1, Temp
 StopSend Handle
 SendMessage
 WaitConfirm

 Handle = ReadyReceive%
  GET #Handle, 65, Lent&
 StopSend Handle

 DS4QB.GetMusicLength& = Lent&
END FUNCTION

FUNCTION DS4QB.GetMusicPosition& (Slot AS INTEGER)
 IF xMusic = DEACTIVE THEN EXIT FUNCTION

 DIM Temp AS CHUNKxCMDxGETMUSICPOSITION

 Temp.ID = CMD.GETMUSICPOSITION
 Temp.Slot = Slot

 Handle = ReadySend%
  PUT #Handle, 1, Temp
 StopSend Handle
 SendMessage
 WaitConfirm

 Handle = ReadyReceive%
  GET #Handle, 65, Lent&
 StopSend Handle

 DS4QB.GetMusicPosition& = Lent&
END FUNCTION

FUNCTION DS4QB.GetOS
 DS4QB.GetOS = OS
END FUNCTION

FUNCTION DS4QB.Init (SoundQuality AS LONG, Flags AS LONG)

 IF FileExsist("SOUNDSYS.CFG") = 0 THEN DS4QB.Init = -3: EXIT FUNCTION
 IF FileExsist("SOUNDSYS.DAT") = 0 THEN DS4QB.Init = -1: EXIT FUNCTION

 Handle = FREEFILE
 OPEN "SOUNDSYS.CFG" FOR BINARY AS #Handle
  GET #Handle, , OS
  GET #Handle, , xSound
  GET #Handle, , xMusic
  GET #Handle, , tmpSoundQuality&
 CLOSE #Handle

 Unpack

 OUT 0, 0: OUT 0, 0

 SHELL "START.EXE DS4QBXX.EXE"

 DIM Temp AS CHUNKxCMDxINITIALIZE

 Temp.ID = 0
 Temp.Quality = SoundQuality
 Temp.Flags = Flags

 IF Temp.Quality = CURRENT THEN
   Temp.Quality = tmpSoundQuality&
  ELSEIF Temp.Quality = DEFAULT THEN
   Temp.Quality = MEDIUMQUALITY
 END IF

 IF Temp.Flags = CURRENT OR Temp.Flags = DEFAULT THEN Temp.Flags = NULL

 Temp.Flags = Temp.Flags OR 16 ' Flags + disable sync (for speed)

 Handle = ReadySend
  PUT #Handle, 1, Temp
 CLOSE #Handle

 SendMessage

 StartTime# = TIMER
 IF OS = WIN9X THEN
   WHILE (INP(0))
    IF TIMER - StartTime# > 11 THEN
     DeleteFiles
     DS4QB.Init = -2
     EXIT FUNCTION
    END IF
   WEND
  ELSEIF OS = WINNT THEN
   WHILE FileExsist(SENDCONFIRM)
    IF TIMER - StartTime# > 11 THEN
     DeleteFiles
     DS4QB.Init = -2
     EXIT FUNCTION
    END IF
   WEND
 END IF

 DS4QB.Init = 0
END FUNCTION

SUB DS4QB.LoadMusic (Slot AS INTEGER, FileName AS STRING, Flags AS LONG)
 DIM Temp AS CHUNKxCMDxLOADMUSIC

 Temp.ID = CMD.LOADMUSIC
 Temp.Slot = Slot
 Temp.FileName = FileName + CHR$(0)
 Temp.Flags = Flags

 IF Temp.Flags = DEFAULT THEN Temp.Flags = MUS.LOOPING

 IF RIGHT$(UCASE$(FileName), 3) = "MP3" THEN
   MusType(Slot) = 1
   IF Temp.Flags <> MUS.LOOPING AND (Temp.Flags AND MUS.LOOPING) THEN
     Temp.Flags = MUS.LOOPING
    ELSEIF Temp.Flags = MUS.LOOPING THEN
    ELSE
     Temp.Flags = NULL
   END IF
  ELSE
   MusType(Slot) = 2
 END IF

 Temp.MusicType = MusType(Slot)

 Handle = ReadySend%
  PUT #Handle, 1, Temp
 StopSend Handle
 SendMessage
 WaitConfirm
END SUB

SUB DS4QB.LoadSound (Slot AS INTEGER, FileName AS STRING, Flags AS LONG)
 DIM Temp AS CHUNKxCMDxLOADSND

 Temp.ID = CMD.LOADSND
 Temp.Slot = Slot
 Temp.FileName = FileName + CHR$(0)
 Temp.Flags = Flags

 IF Temp.Flags = DEFAULT THEN Temp.Flags = NULL

 Temp.Flags = Temp.Flags OR 16

 Handle = ReadySend%
  PUT #Handle, 1, Temp
 StopSend Handle
 SendMessage
 WaitConfirm
END SUB

SUB DS4QB.MusicFadeIn (FStep AS INTEGER, Slot AS INTEGER, ObjVol AS INTEGER, CPos AS INTEGER)
 STATIC Time AS DOUBLE

 IF CPos < 0 THEN CPos = 0

 FStep2 = FStep: IF FStep = DEFAULT THEN FStep2 = 5
 ObjVol2 = ObjVol: IF ObjVol = DEFAULT THEN ObjVol2 = 50

 IF CPos THEN
   IF TIMER - Time > .3 THEN
    CPos = CPos - FStep2
    DS4QB.SetMusicAttr Slot, ObjVol2 - CPos, CURRENT
    Time = TIMER
   END IF
  ELSE
   DS4QB.SetMusicAttr Slot, 0, CURRENT
   DS4QB.PlayMusic Slot
   CPos = ObjVol2
   Time = TIMER
 END IF

 IF CPos = 0 AND Time THEN
  DS4QB.SetMusicAttr Slot, ObjVol2, CURRENT
  Time = 0
 END IF
END SUB

SUB DS4QB.MusicFadeOut (FStep AS INTEGER, Slot AS INTEGER, ObjVol AS INTEGER, CPos AS INTEGER)
 STATIC Time AS DOUBLE

 IF CPos < 0 THEN CPos = 0

 FStep2 = FStep: IF FStep = DEFAULT THEN FStep2 = 5
 ObjVol2 = ObjVol: IF ObjVol = DEFAULT THEN ObjVol2 = 50

 IF CPos THEN
   IF TIMER - Time > .3 THEN
    CPos = CPos - FStep2
    DS4QB.SetMusicAttr Slot, CPos, CURRENT
    Time = TIMER
   END IF
  ELSE
   CPos = ObjVol2
   Time = TIMER
 END IF

 IF CPos = 0 AND Time THEN
  DS4QB.StopMusic Slot
  Time = 0
 END IF
END SUB

SUB DS4QB.MusicFadeSwitch (FStep AS INTEGER, StartSlot AS INTEGER, ObjVol AS INTEGER, EndSlot AS INTEGER, CPos AS INTEGER)
 STATIC Time AS DOUBLE

 IF CPos < 0 THEN CPos = 0

 FStep2 = FStep: IF FStep = DEFAULT THEN FStep2 = 5
 ObjVol2 = ObjVol: IF ObjVol = DEFAULT THEN ObjVol2 = 50

 IF CPos THEN
   IF TIMER - Time > .3 THEN
    CPos = CPos - FStep2
    DS4QB.SetMusicAttr EndSlot, ObjVol2 - CPos, CURRENT
    DS4QB.SetMusicAttr StartSlot, CPos, CURRENT
    Time = TIMER
   END IF
  ELSE
   DS4QB.SetMusicAttr EndSlot, 0, CURRENT
   DS4QB.PlayMusic EndSlot
   CPos = ObjVol2
   Time = TIMER
 END IF

 IF CPos = 0 AND Time THEN
  DS4QB.StopMusic StartSlot
  DS4QB.SetMusicAttr EndSlot, ObjVol2, CURRENT
  Time = 0
 END IF
END SUB

SUB DS4QB.PauseMusic (Slot AS INTEGER)
 IF xMusic = DEACTIVE THEN EXIT SUB

 DIM Temp AS CHUNKxCMDxPAUSEMUSIC

 Temp.ID = CMD.PAUSEMUSIC
 Temp.Slot = Slot

 Handle = ReadySend%
  PUT #Handle, 1, Temp
 StopSend Handle
 SendMessage
 WaitConfirm
END SUB

SUB DS4QB.PlayMusic (Slot AS INTEGER)
 IF xMusic = DEACTIVE THEN EXIT SUB

 DIM Temp AS CHUNKxCMDxPLAYMUSIC

 Temp.ID = CMD.PLAYMUSIC
 Temp.Slot = Slot

 Handle = ReadySend%
  PUT #Handle, 1, Temp
 StopSend Handle
 SendMessage
 WaitConfirm
END SUB

SUB DS4QB.PlaySound (Slot AS INTEGER)
 DS4QB.PlaySoundEx Slot, CURRENT, CURRENT, CURRENT, CURRENT
END SUB

SUB DS4QB.PlaySoundEx (Slot AS INTEGER, Freq AS LONG, Volume AS INTEGER, Pan AS INTEGER, Looping AS INTEGER)
 IF xSound = DEACTIVE THEN EXIT SUB

 DIM Temp AS CHUNKxCMDxPLAYSND

 Temp.ID = CMD.PLAYSND
 Temp.Slot = Slot
 Temp.Freq = Freq
 Temp.Volume = Volume
 Temp.Pan = Pan
 Temp.Looping = Looping

 IF Temp.Freq <> CURRENT THEN
   IF Temp.Freq <> DEFAULT THEN
     IF Temp.Freq > 100000 THEN Temp.Freq = 100000
     IF Temp.Freq < 100 THEN Temp.Freq = 100
    ELSE
     Temp.Freq = &HFFFFFE
   END IF
  ELSE
   Temp.Freq = &HFFFFFF
 END IF

 IF Temp.Volume <> CURRENT THEN
  IF Temp.Volume <> DEFAULT THEN
    IF Temp.Volume > 100 THEN Temp.Volume = 100
    IF Temp.Volume < 0 THEN Temp.Volume = 0
   ELSE
    Temp.Volume = 50
  END IF
 END IF

 IF Temp.Pan <> CURRENT THEN
  IF Temp.Pan <> DEFAULT THEN
    IF Temp.Pan > 100 THEN Temp.Pan = 100
    IF Temp.Pan < -100 THEN Temp.Pan = -100
    Temp.Pan = Temp.Pan + 100
   ELSE
    Temp.Pan = 100
  END IF
 END IF

 IF Temp.Looping = DEFAULT THEN Temp.Looping = 0

 Handle = FREEFILE
 OPEN OUTFILE FOR BINARY AS #Handle
  PUT #Handle, 1, Temp
 StopSend Handle
 SendMessage
END SUB

SUB DS4QB.ResumeMusic (Slot AS INTEGER)
 IF xMusic = DEACTIVE THEN EXIT SUB

 DIM Temp AS CHUNKxCMDxRESUMEMUSIC

 Temp.ID = CMD.RESUMEMUSIC
 Temp.Slot = Slot

 Handle = ReadySend%
  PUT #Handle, 1, Temp
 StopSend Handle
 SendMessage
 WaitConfirm
END SUB

SUB DS4QB.SetGlobalVolumes (SoundVol AS INTEGER, MusicVol AS INTEGER)
 DIM Temp AS CHUNKxCMDxSETGLOBALVOLUMES

 Temp.ID = CMD.SETGLOBALVOLUMES
 Temp.SoundVolume = SoundVol
 Temp.MusicVolume = MusicVol

 IF Temp.SoundVolume <> CURRENT THEN
   IF Temp.SoundVolume > 100 THEN Temp.SoundVolume = 100
   IF Temp.SoundVolume < 0 THEN Temp.SoundVolume = 0
 END IF

 IF Temp.MusicVolume <> CURRENT THEN
   IF Temp.MusicVolume > 100 THEN Temp.MusicVolume = 100
   IF Temp.MusicVolume < 0 THEN Temp.MusicVolume = 0
 END IF

 Handle = ReadySend%
  PUT #Handle, 1, Temp
 StopSend Handle
 SendMessage
 WaitConfirm
END SUB

SUB DS4QB.SetMasterVolume (Volume AS INTEGER)
 DIM Temp AS CHUNKxCMDxSETVOLUME

 Temp.ID = CMD.SETVOLUME
 Temp.Volume = Volume

 IF Temp.Volume <> CURRENT THEN
   IF Temp.Volume > 100 THEN Temp.Volume = 100
   IF Temp.Volume < 0 THEN Temp.Volume = 0
 END IF

 Handle = ReadySend%
  PUT #Handle, 1, Temp
 StopSend Handle
 SendMessage
 WaitConfirm
END SUB

SUB DS4QB.SetMusic (Switch)
 xMusic = ABS(SGN(Switch))
END SUB

SUB DS4QB.SetMusicAttr (Slot AS INTEGER, Volume AS INTEGER, Pan AS INTEGER)
 DIM Temp AS CHUNKxCMDxSETMUSICATTR

 Temp.ID = CMD.SETMUSICATTR
 Temp.Slot = Slot
 Temp.Amp = Volume
 Temp.Pan = Pan

 IF Temp.Amp <> CURRENT THEN
  IF Temp.Amp = DEFAULT THEN Temp.Amp = 50
  IF Temp.Amp > 100 THEN Temp.Amp = 100
  IF Temp.Amp < 0 THEN Temp.Amp = 0
 END IF

 IF Temp.Pan <> CURRENT THEN
  IF Temp.Pan = DEFAULT THEN Temp.Pan = 50
  IF Temp.Pan > 100 THEN Temp.Pan = 100
  IF Temp.Pan < 0 THEN Temp.Pan = 0
 END IF

 Handle = ReadySend%
  PUT #Handle, 1, Temp
 StopSend Handle
 SendMessage
 WaitConfirm
END SUB

SUB DS4QB.SetMusicPosition (Slot AS INTEGER, Position AS LONG)
 DIM Temp AS CHUNKxCMDxSETMUSICPOSITION

 Temp.ID = CMD.SETMUSICPOSITION
 Temp.Slot = Slot
 Temp.Position = Position

 Handle = ReadySend%
  PUT #Handle, 1, Temp
 StopSend Handle
 SendMessage
 WaitConfirm
END SUB

SUB DS4QB.SetSound (Switch AS INTEGER)
 xSound = ABS(SGN(Switch))
END SUB

SUB DS4QB.SetSoundAttr (Slot AS INTEGER, Freq AS LONG, Volume AS INTEGER, Pan AS INTEGER, Looping AS INTEGER, Flags AS LONG)
 DIM Temp AS CHUNKxCMDxSETSNDATTR

 Temp.ID = CMD.SETSNDATTR
 Temp.Slot = Slot
 Temp.Freq = Freq
 Temp.Volume = Volume
 Temp.Pan = Pan
 Temp.Looping = Looping
 Temp.Flags = Flags

 IF Temp.Flags = DEFAULT THEN Temp.Flags = NULL

 IF Temp.Looping = DEFAULT THEN Temp.Looping = DEACTIVE

 IF Temp.Freq <> CURRENT THEN
  IF Temp.Freq <> DEFAULT THEN
    IF Temp.Freq > 100000 THEN Temp.Freq = 100000
    IF Temp.Freq < 100 THEN Temp.Freq = 100
   ELSE
    Temp.Freq = &HFFFFFE
  END IF
 END IF

 IF Temp.Volume <> CURRENT THEN
  IF Temp.Volume = DEFAULT THEN Temp.Volume = 50
  IF Temp.Volume > 100 THEN Temp.Volume = 100
  IF Temp.Volume < 0 THEN Temp.Volume = 0
 END IF

 IF Temp.Pan <> CURRENT THEN
  IF Temp.Pan = DEFAULT THEN Temp.Pan = 0
  IF Temp.Pan > 100 THEN Temp.Pan = 100
  IF Temp.Pan < -100 THEN Temp.Pan = -100
  Temp.Pan = Temp.Pan + 100
 END IF

 Handle = ReadySend%
  PUT #Handle, 1, Temp
 StopSend Handle
 SendMessage
 WaitConfirm
END SUB

SUB DS4QB.StopMusic (Slot AS INTEGER)
 IF xMusic = DEACTIVE THEN EXIT SUB

 DIM Temp AS CHUNKxCMDxSTOPMUSIC

 Temp.ID = CMD.STOPMUSIC
 Temp.Slot = Slot

 Handle = ReadySend%
  PUT #Handle, 1, Temp
 StopSend Handle
 SendMessage
 WaitConfirm
END SUB

SUB DS4QB.StopSound (Slot AS INTEGER)
 DIM Temp AS CHUNKxCMDxSTOPSND

 Temp.ID = CMD.STOPSND
 Temp.Slot = Slot

 Handle = ReadySend%
  PUT #Handle, 1, Temp
 StopSend Handle
 SendMessage
 WaitConfirm
END SUB

FUNCTION FileExsist% (FileName$)
 DIM InRegs AS RegTypeX, OutRegs AS RegTypeX

 FileToSet$ = FileName$ + CHR$(0)

 InRegs.Ax = &H4300
 InRegs.Ds = VARSEG(FileToSet$)
 InRegs.Dx = SADD(FileToSet$)
 CALL INTERRUPTX(&H21, InRegs, OutRegs)

 IF (OutRegs.Flags AND 1) <> 0 THEN EXIT FUNCTION
 FileExsist% = -1
END FUNCTION

FUNCTION GetOrder& (Whole AS LONG)
 DEF SEG = VARSEG(Whole)
  B1 = PEEK(VARPTR(Whole))
  B2 = PEEK(VARPTR(Whole) + 1)
 GetOrder& = B1 + (B2 * 256)
END FUNCTION

FUNCTION GetRow& (Whole AS LONG)
 DEF SEG = VARSEG(Whole)
  B1 = PEEK(VARPTR(Whole) + 2)
  B2 = PEEK(VARPTR(Whole) + 3)
 GetRow& = B1 + (B2 * 256)
END FUNCTION

FUNCTION ReadyReceive
 Handle = FREEFILE
 OPEN INFILE FOR BINARY AS #Handle
  ReadyReceive = Handle
END FUNCTION

FUNCTION ReadySend%
 DO
  ErrNum = 0
  Handle = FREEFILE
  OPEN OUTFILE FOR BINARY AS #Handle
 LOOP UNTIL ErrNum = 0
  ReadySend% = Handle
END FUNCTION

SUB SendMessage
 IF OS = WIN9X THEN
   OUT 0, 255: OUT 0, 255
  ELSEIF OS = WINNT THEN
   BSAVE SENDCONFIRM, 1024, 1
 END IF
END SUB

SUB StopReceive (Handle AS INTEGER)
 CLOSE Handle
END SUB

SUB StopSend (Handle AS INTEGER)
 CLOSE #Handle
END SUB

SUB Unpack
 DIM LenS(2) AS LONG, file(2) AS STRING
 DIM BigBuff AS STRING * 256, SmallBuff AS STRING * 4, MiniBuff AS STRING * 1

 file(0) = "DS4QBXX.EXE"
 file(1) = "BASS.DLL"
 file(2) = "START.EXE"

 ReadHandle = FREEFILE
 OPEN "SOUNDSYS.DAT" FOR BINARY AS ReadHandle
  FOR i = 0 TO 2
   GET #ReadHandle, , LenS(i)
  NEXT
  FOR i = 0 TO 2
   l& = LenS(i)
   WriteHandle = FREEFILE
   OPEN file(i) FOR BINARY AS #WriteHandle
    DO
     GET #ReadHandle, , BigBuff
     PUT #WriteHandle, , BigBuff
     l& = l& - 256
    LOOP UNTIL l& < 256
    IF l& > 4 THEN
     DO
      GET #ReadHandle, , SmallBuff
      PUT #WriteHandle, , SmallBuff
      l& = l& - 4
     LOOP UNTIL l& < 4
    END IF
    IF l& >= 1 THEN
     DO
      GET #ReadHandle, , MiniBuff
      PUT #WriteHandle, , MiniBuff
      l& = l& - 1
     LOOP UNTIL l& = 0
    END IF
   CLOSE #WriteHandle
  NEXT
 CLOSE #ReadHandle
END SUB

SUB WaitConfirm
 IF OS = WIN9X THEN
   WHILE INP(0): WEND
  ELSEIF OS = WINNT THEN
   WHILE FileExsist(SENDCONFIRM): WEND
 END IF
END SUB


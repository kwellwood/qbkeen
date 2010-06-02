'============================================================================
'           PAK Library - By Kevin Wellwood of HomeSoft Productions
'
'============================================================================
DEFINT A-Z
'$DYNAMIC
'$INCLUDE: 'engine.bi'
'$INCLUDE: 'directqb.bi'
'$INCLUDE: 'xms.bi'
'$INCLUDE: 'paklib.bi'
'$INCLUDE: 'plugins.bi'

ON ERROR GOTO ErrorHandler

'----------------------------------------------------------------------------
ErrorHandler:
ErrorHandlerSub 0
RESUME NEXT

REM $STATIC
SUB ClosePAKLib

IF PakInitState THEN
  FClose PakHandle
  BiosXClose PakHeadHandle
  PakInitState = 0
END IF

END SUB

FUNCTION InitPAKLib

IF PakInitState = 0 THEN
  BiosXOpen 50, PakHeadHandle, ErrCode
  IF ErrCode = 0 THEN PakInitState = 1
  InitPAKLib = ErrCode
 ELSE InitPAKLib = 0
END IF

END FUNCTION

FUNCTION LoadFromPAK (filename$, array)

IF PakInitState <> 2 THEN
  LoadFromPAK = 2
  EXIT FUNCTION
END IF

' **** FIND FILE # ****
FOR f& = 1 TO numfiles&
  IF RTRIM$(filename$) = RTRIM$(PAKFilename$(f&)) THEN filenum& = f&: EXIT FOR
NEXT f&
IF filenum& = 0 THEN LoadFromPAK = 1: EXIT FUNCTION

' ***** LOAD FILE *****

  FSeek PakHandle, PAKFileOffset&(filenum&), 0
  SELECT CASE array
   CASE scrbuf
    FGet PakHandle, VARSEG(scr(0)), VARPTR(scr(0)), PAKFileLength&(filenum&)
  END SELECT


END FUNCTION

FUNCTION MountPAK (filename$)

IF PakInitState = 0 THEN
  MountPAK = 2
  EXIT FUNCTION
END IF
IF PakInitState = 2 THEN FClose PakHandle  ' close previous pak

pakname$ = filename$
xmspakpos& = 0

Exist filename$, ErrCode
IF ErrCode <> -1 THEN
  MountPAK = 1
  EXIT FUNCTION
END IF

PakHandle = FOpen(filename$, 0)
  FGet1 PakHandle, pakver                          ' check for correct
  IF pakver <> 2 THEN MountPAK = 3: EXIT FUNCTION  ' pak version
  FGet4 PakHandle, numfiles&
  REDIM pakfname(numfiles&) AS STRING * 12
  FOR f& = 1 TO numfiles&
    ' *** FILENAME ***
    temp$ = ""
    FOR n = 1 TO 12
      FGet1 PakHandle, c
      temp$ = temp$ + CHR$(c)
      'curbit(0) = c
      'BiosXWrite PakHeadHandle, xmspakpos&, 2, VARSEG(curbit(0)), VARPTR(curbit(0))
      xmspakpos& = xmspakpos& + 2
    NEXT n
    pakfname(f&) = temp$
    ' **** LENGTH ****
    FGet4 PakHandle, c&
    curbitl&(0) = c&
    BiosXWrite PakHeadHandle, xmspakpos&, 4, VARSEG(curbitl&(0)), VARPTR(curbitl&(0))
    xmspakpos& = xmspakpos& + 4
    ' **** OFFSET ****
    FGet4 PakHandle, c&
    curbitl&(0) = c&
    BiosXWrite PakHeadHandle, xmspakpos&, 4, VARSEG(curbitl&(0)), VARPTR(curbitl&(0))
    xmspakpos& = xmspakpos& + 4
  NEXT f&
'FClose PakHandle  ' don't close it
PakInitState = 2

END FUNCTION

FUNCTION PAKFileLength& (filenum&)
                                 ' \/ size of filename to skip
xmspakpos& = (filenum& - 1) * 32 + 24
BiosXRead PakHeadHandle, xmspakpos&, 4, VARSEG(curbitl&(0)), VARPTR(curbitl&(0))
PAKFileLength = curbitl&(0)

END FUNCTION

FUNCTION PAKFilename$ (filenum&)

xmspakpos& = (filenum& - 1) * 32
PAKFilename$ = pakfname(filenum&)

'FOR c = 1 TO 12
'  BiosXRead PakHeadHandle, xmspakpos&, 2, VARSEG(curbit(0)), VARPTR(curbit(0))
'  filename$ = filename$ + CHR$(curbit(0))
'  xmspakpos& = xmspakpos& + 2
'NEXT c
'PAKFilename$ = filename$

END FUNCTION

FUNCTION PAKFileOffset& (filenum&)
                                 ' \/ size of filename to skip
xmspakpos& = (filenum& - 1) * 32 + 28
BiosXRead PakHeadHandle, xmspakpos&, 4, VARSEG(curbitl&(0)), VARPTR(curbitl&(0))
PAKFileOffset = curbitl&(0)

END FUNCTION

FUNCTION PAKFileSize& (filename$)

IF PakInitState <> 2 THEN
  PAKFileSize& = -2
  EXIT FUNCTION
END IF

' **** FIND FILE # ****
FOR f& = 1 TO numfiles&
  IF RTRIM$(filename$) = RTRIM$(PAKFilename$(f&)) THEN filenum& = f&: EXIT FOR
NEXT f&
IF filenum& = 0 THEN PAKFileSize& = -1: EXIT FUNCTION

l& = PAKFileLength&(filenum&)
PAKFileSize& = l&

END FUNCTION


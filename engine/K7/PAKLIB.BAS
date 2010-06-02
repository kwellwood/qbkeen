DEFINT A-Z
'$INCLUDE: 'engine.bi'
'$INCLUDE: 'xms.bi'
'$INCLUDE: 'paklib.bi'
'$STATIC

ON ERROR GOTO ErrorHandler

DIM SHARED pakfname(0) AS STRING * 12
DIM SHARED PakHandle, PakHeadHandle, pakname$, numfiles&, PakInitState
'============================================================================
ErrorHandler:
e = ERR
ErrorHandlerSub e
RESUME NEXT

SUB ClosePAKLib

IF PakInitState THEN
  FClose PakHandle
  BiosXClose PakHeadHandle
  PakInitState = 0
END IF

END SUB

FUNCTION InitPAKLib

IF PakInitState = 0 THEN
  BiosXOpen 64, PakHeadHandle, ErrCode
  IF ErrCode = 0 THEN PakInitState = 1
  InitPAKLib = ErrCode
 ELSE InitPAKLib = 0
END IF

END FUNCTION

FUNCTION LoadFromPAK (filename$, aSEG, aPTR)

IF PakInitState <> 2 THEN
  LoadFromPAK = 2
  EXIT FUNCTION
END IF

' **** FIND FILE # ****
filename$ = UCASE$(filename$)
low& = 1: high& = numfiles&: mid& = (low& + high&) / 2
WHILE low& <= high& AND RTRIM$(PAKFilename$(mid&)) <> filename$
  IF RTRIM$(PAKFilename$(mid&)) < filename$ THEN low& = mid& + 1 ELSE high& = mid& - 1
  mid& = (low& + high&) / 2
WEND
IF low& > high& THEN
  LoadFromPAK = 1: EXIT FUNCTION
 ELSE
  filenum& = mid&
END IF

' ***** LOAD FILE *****
FSeek PakHandle, PAKFileOffset&(filenum&), 0
FGet PakHandle, aSEG, aPTR, PAKFileLength&(filenum&)

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
  FOR f& = 1 TO numfiles&
    ' *** FILENAME ***
    temp$ = ""
    FOR n = 1 TO 12
      FGet1 PakHandle, c
      temp$ = temp$ + CHR$(c)
    NEXT n
    pakfname(0) = temp$
    BiosXWrite PakHeadHandle, xmspakpos&, 12, VARSEG(pakfname(0)), VARPTR(pakfname(0))
    xmspakpos& = xmspakpos& + 12
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
PakInitState = 2

END FUNCTION

FUNCTION PAKFileLength& (filenum&)
                                 ' \/ size of filename to skip
xmspakpos& = (filenum& - 1) * 20 + 12
BiosXRead PakHeadHandle, xmspakpos&, 4, VARSEG(curbitl&(0)), VARPTR(curbitl&(0))
PAKFileLength = curbitl&(0)

END FUNCTION

FUNCTION PAKFilename$ (filenum&)

xmspakpos& = (filenum& - 1) * 20
BiosXRead PakHeadHandle, xmspakpos&, 12, VARSEG(pakfname(0)), VARPTR(pakfname(0))
PAKFilename$ = pakfname(0)

END FUNCTION

FUNCTION PAKFileOffset& (filenum&)
                                
                                 ' \/ size of filename+filesize to skip
xmspakpos& = (filenum& - 1) * 20 + 16
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


DEFINT A-Z
'$DYNAMIC
'=======================[ ASM ROUTINE DEFINITIONS ]==========================
DECLARE SUB Exist (filename$, oops)
DECLARE SUB FClose (handle)
DECLARE SUB FGet1 (handle, n)
DECLARE SUB FGet2 (handle, n)
DECLARE SUB FGet4 (handle, n&)
DECLARE SUB FGet (handle, aSEG, aPTR, bytes&)
DECLARE SUB FSeek (handle, bytes&, seekmode)
DECLARE SUB KillFile (file$, oops)

DECLARE FUNCTION FOpen (f$, mode)
'===================[ PAK MODULE'S ROUTINE DEFINITIONS ]=====================
DECLARE SUB ClosePAKLib ()

DECLARE FUNCTION InitPAKLib ()
DECLARE FUNCTION LoadFromPAK (filename$, aSEG, aPTR)
DECLARE FUNCTION MountPAK (filename$)
DECLARE FUNCTION PAKFileLength& (filenum&)
DECLARE FUNCTION PAKFilename$ (filenum&)
DECLARE FUNCTION PAKFileOffset& (filenum&)
DECLARE FUNCTION PAKFileSize& (filename$)


DEFINT A-Z
'$DYNAMIC

COMMON SHARED StartTile&

DECLARE SUB CreatePulldown ()
DECLARE SUB DrawBox (x1, y1, x2, y2)
DECLARE SUB DrawBox2 (x1, y1, x2, y2)
DECLARE SUB DrawMenu ()
DECLARE SUB EditPulldown ()
DECLARE SUB EnemyPulldown ()
DECLARE SUB FilePulldown ()
DECLARE SUB HandleMenuInput (mx, my, mb)
DECLARE SUB ItemPulldown ()
DECLARE SUB MatrixPulldown ()
DECLARE SUB MenuEditMusic ()
DECLARE SUB MenuEditReplace ()
DECLARE SUB MenuFileNewMap ()
DECLARE SUB MenuFileSaveMap ()
DECLARE SUB MenuFileLoadMap ()
DECLARE SUB SelectTile ()
DECLARE FUNCTION InArea (x, y, x1, y1, x2, y2)
DECLARE FUNCTION GetFile$ (x, y)
DECLARE FUNCTION GetNumber$ (x, y)


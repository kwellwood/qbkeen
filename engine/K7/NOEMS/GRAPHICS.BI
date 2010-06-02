DEFINT A-Z
'$DYNAMIC

COMMON SHARED ArtHandle, ArtOffSetHandle, ArtLengthHandle
COMMON SHARED xmspos&

DECLARE SUB LoadArtFile (t&, f$)
DECLARE SUB PutSprite (t&, x, y, p)
DECLARE SUB PutTile (t&, x, y, p)


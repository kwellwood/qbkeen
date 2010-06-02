DEFINT A-Z
'$DYNAMIC

COMMON SHARED ArtHandle, ArtOffSetHandle, ArtLengthHandle
COMMON SHARED xmspos&

DECLARE SUB LoadArtFile (t&, f$)
DECLARE SUB PutMask (t&, x, y, p)
DECLARE SUB PutSprite (t&, x, y, p)
DECLARE SUB PutSpriteS (t&, x, y, x1, y1, p)
DECLARE SUB PutTile (t&, x, y, p)
DECLARE SUB PutTileS (t&, x, y, x1, y1, p)
DECLARE FUNCTION TileXSize (t&)
DECLARE FUNCTION TileYSize (t&)


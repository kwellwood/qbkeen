DEFINT A-Z
'$DYNAMIC

DECLARE SUB ClearItems ()
DECLARE SUB ClearSprites ()
DECLARE SUB DoItems ()
DECLARE SUB DoSprites ()
DECLARE SUB DrawItems ()
DECLARE SUB DrawSprites ()
DECLARE SUB InitItems ()
DECLARE SUB LoadItems (f)
DECLARE SUB LoadItemsFromFile (f)
DECLARE SUB LoadSpritesFromFile (f)
DECLARE SUB MoveSprite (s, x, y)
DECLARE SUB WriteItemsToFile (f)
DECLARE SUB WriteSpritesToFile (f)
DECLARE FUNCTION ActiveItems ()
DECLARE FUNCTION ActiveSprites ()
DECLARE FUNCTION AddSprite (x, y, frame&, eframe&, delay, xsize, ysize, deadly, repeat, lifespan)
DECLARE FUNCTION TouchItem (i)
DECLARE FUNCTION TouchSprite (s)


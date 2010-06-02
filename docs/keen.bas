DECLARE FUNCTION KeenIsLimit! (lx!, ly!, ld!)


CONST TRUE = -1, FALSE = 0

'
' Parameters:  lx and ly are the coordinates of the point you want to check
'              ld is the direction of Keen
'
'
FUNCTION KeenIsLimit (lx, ly, ld)

 tx = FIX(lx / 16)     ' tile coordinates to read the limit from the array
 ty = FIX(ly / 16)     ' where you save the limit

 px = (16 * tx)        ' absolute coordinates of the upper-left corner
 py = (16 * ty)        ' of the limit (size is always 16x16)

 sx = (lx - px)        ' special lengths
 sy = (ly - py)        '

 lim = FALSE           ' return value

'
' P (px|py)
' þ - - - - - - - - - - - - - - - +  *
' |                             / |  |
' |                           / . |  |
' |                         / . . |  |
' |                       / . . . |  |
' |                     / . . . . |  sy
' |                   / . . . . . |  |
' |                 / . . . . . . |  |
' |               / . . . . . . . |  |
' |             / . . . . . . . . |  |
' |           / . . . . þ . . . . |  *
' |         / . . . . L (lx|ly) . | 
' |       / . . . . . . . . . . . |   L is the point we want to check
' |     / . . . . . . . . . . . . |
' |   / . . . . . . . . . . . . . | 
' | / . . . . . . . . . . . . . . | 
' + - - - - - - - - - - - - - - - + 
'                               
' *-------- sx ---------*
'
' If you also want to check other limits that are not so slope
' you need to change sy (don't ask how, I haven't tried it out)
'


 ' the tile must be in the range of the map
 ' change it into your minimum and maximum values

   IF tx >= 0 AND tx < 200 AND ty >= 0 AND ty < 150 THEN


     SELECT CASE LevelLimit(tx, ty)      ' LevelLimit is your array
                                         ' where you save the limits

       '
       '  +-----+
       '  |     |
       '  |     |
       '  +-----+
       '
         CASE 1
                 IF lx >= px AND lx < (px + 16) AND ly >= py AND ly < (py + 16) THEN
                  lim = TRUE
                 END IF

       '
       '  +     +
       '      / |
       '    /   |
       '  +-----+
       '
         CASE 2
                 IF lx >= (px + 1) AND lx < (px + 16) AND ly >= (py + 17 - sy) AND ly < (py + 16) THEN
                   lim = TRUE
                 END IF

       '
       '  +     +
       '  | \
       '  |   \
       '  +-----+
       '
         CASE 3
                 IF lx >= px AND lx < (px + 16) AND ly >= (py + s) AND ly < (py + 16) THEN
                   lim = TRUE
                 END IF

       '
       '  +-----+
       '    \   |
       '      \ |
       '  +     +
       '
         CASE 4:
                 IF lx >= px AND lx < (px + 16) AND ly >= py AND ly < (py + s) THEN
                   lim = TRUE
                 END IF

       '
       '  +-----+
       '  |   /
       '  | /
       '  +     +
       '
         CASE 5:
                 IF lx >= px AND lx < (px + 15) AND ly >= py AND ly < (py + 16 - s) THEN
                   lim = TRUE
                 END IF


       ' You need to change the CASE values into yours.
       ' You better define sx and sy after a CASE value
       ' instead of declaring it above.
       '
       ' Here you should add the other sloped tiles I haven't
       '

     END SELECT

   END IF


     KeenIsLimit = lim


END FUNCTION


DEFINT A-Z
'$INCLUDE: 'engine.bi'
'$INCLUDE: 'tiles.bi'
'$INCLUDE: 'player.bi'
'$INCLUDE: 'render.bi'
'$INCLUDE: 'sound.bi'
'$INCLUDE: 'items.bi'
'$STATIC

CONST red = 1, blue = 2, green = 3, yellow = 4

TYPE itemclass
 x AS INTEGER
 y AS INTEGER
 sframe AS LONG
 frames AS INTEGER
 delay AS INTEGER
 id AS INTEGER
 xsize AS INTEGER
 ysize AS INTEGER
 scored AS INTEGER
END TYPE

TYPE spriteclass
 x AS INTEGER
 y AS INTEGER
 frame AS LONG
 sframe AS LONG
 eframe AS LONG
 delay AS INTEGER     ' ticks per frame
 ticks AS INTEGER     ' set to delay and decrease for next frame
 xsize AS INTEGER
 ysize AS INTEGER
 deadly AS INTEGER    ' kill player if touched
 repeat AS INTEGER    ' dont kill sprite, loop animation
 lifespan AS INTEGER  ' keep a looping sprite alive for only a time
END TYPE

TYPE itemtypeclass
 sframe AS LONG
 frames AS INTEGER
 delay AS INTEGER
 points AS INTEGER
 lifedrop AS INTEGER
 gemkey AS INTEGER
 xsize AS INTEGER
 ysize AS INTEGER
 pxsize AS INTEGER
 pysize AS INTEGER
 ammo AS INTEGER
 psframe AS LONG
 pframes AS LONG
 pdelay AS INTEGER
END TYPE

ON ERROR GOTO ErrorHandler

DIM SHARED numitems, numitemtypes
DIM SHARED item(1 TO 255) AS itemclass, bonus(1 TO 13) AS itemtypeclass
DIM SHARED activeitemstack AS STRING, activespritestack AS STRING
DIM SHARED sprite(1 TO 100) AS spriteclass, unusedspritestack AS STRING

'activeitemstack = "list of active items to handle"
'                  "31246890"
'activespritestack = "list of active passive sprites to handle"
'                    "1375"
'unusedspritestack = "list of inactive passive sprites for later use"
'                    "246890"
'============================================================================
ErrorHandler:
e = ERR
ErrorHandlerSub e
RESUME NEXT

FUNCTION ActiveItems

ActiveItems = LEN(activeitemstack)

END FUNCTION

FUNCTION ActiveSprites

ActiveSprites = LEN(activespritestack)

END FUNCTION

FUNCTION AddSprite (x, y, frame&, eframe&, delay, xsize, ysize, deadly, repeat, lifespan)

'--- exit if no more empty sprite slots ---
IF LEN(unusedspritestack) = 0 THEN EXIT FUNCTION

'--- balance the stacks ---
s = ASC(LEFT$(unusedspritestack, 1))
unusedspritestack = RIGHT$(unusedspritestack, LEN(unusedspritestack) - 1)
activespritestack = activespritestack + CHR$(s)

'--- fill in sprite object ---
sprite(s).x = x
sprite(s).y = y
sprite(s).frame = frame&
sprite(s).sframe = sprite(s).frame
sprite(s).eframe = eframe&
sprite(s).delay = delay
sprite(s).ticks = sprite(s).delay
sprite(s).xsize = xsize
sprite(s).ysize = ysize
sprite(s).deadly = deadly
sprite(s).repeat = repeat
sprite(s).lifespan = lifespan

AddSprite = s  'set to slot in sprites so another
               'function can access it later

END FUNCTION

SUB ClearItems

activeitemstack = ""

END SUB

SUB ClearSprites

activespritestack = ""   'clear sprite stack
unusedspritestack = ""   'clear unused sprite stack
FOR s = 1 TO 100            'fill unused sprite stack
  sprite(s).deadly = 0
  sprite(s).repeat = 0
  sprite(s).lifespan = -1
  sprite(s).delay = 0: sprite(s).ticks = 0
  sprite(s).x = 0: sprite(s).y = 0
  sprite(s).xsize = 0: sprite(s).ysize = 0
  sprite(s).frame = 0: sprite(s).sframe = 0: sprite(s).eframe = 0
  unusedspritestack = unusedspritestack + CHR$(s)
NEXT s

END SUB

SUB DoItems

FOR k = 1 TO LEN(activeitemstack)
  IF k > LEN(activeitemstack) THEN EXIT FOR
  i = ASC(MID$(activeitemstack, k, 1))

  IF TouchItem(i) THEN
    '--- setup bonus sprite ---
    startframe& = bonus(item(i).id).psframe
    endframe& = startframe& + bonus(item(i).id).pframes - 1
    framedelay = bonus(item(i).id).pdelay
    xsize = bonus(item(i).id).pxsize
    ysize = bonus(item(i).id).pysize
   
    '--- award bonus' value ---
    IF bonus(item(i).id).points THEN
      player(0).score = player(0).score + bonus(item(i).id).points
      IF player(0).score >= player(0).nextlifeat THEN
        player(0).nextlifeat = player(0).nextlifeat * 2
        player(0).lives = player(0).lives + 1
        '-- overwrite points anm with blue 1up --
        startframe& = 631
        endframe& = 637
        framedelay = 3
        xsize = 12
        ysize = 16
      END IF
      PlaySound 13
    END IF
    IF bonus(item(i).id).ammo THEN
      player(0).ammo = player(0).ammo + bonus(item(i).id).ammo
      PlaySound 15
    END IF
    IF bonus(item(i).id).lifedrop THEN
      IF bonus(item(i).id).lifedrop = 100 THEN    '100 drops- extra life
        player(0).lives = player(0).lives + 1
       ELSE                                       'a single drop
        player(0).drops = player(0).drops + bonus(item(i).id).lifedrop
        IF player(0).drops > 99 THEN              'collected 100 drops?
          player(0).drops = 0
          player(0).lives = player(0).lives + 1
          '-- overwrite lifedrop anm with blue 1up --
          startframe& = 631
          endframe& = 637
          framedelay = 3
          xsize = 12
          ysize = 16
        END IF
      END IF
      PlaySound 14
    END IF
    IF bonus(item(i).id).gemkey THEN
      SELECT CASE bonus(item(i).id).gemkey
       CASE red: player(0).keyred = 1
       CASE blue: player(0).keyblu = 1
       CASE green: player(0).keygrn = 1
       CASE yellow: player(0).keyyel = 1
      END SELECT
      PlaySound 16
    END IF

    '--- remove from active item stack ---
    activeitemstack = LEFT$(activeitemstack, k - 1) + RIGHT$(activeitemstack, LEN(activeitemstack) - k)
   
    x = item(i).x: y = item(i).y - (bonus(item(i).id).pysize / 2)
    a = AddSprite(x, y, startframe&, endframe&, framedelay, xsize, ysize, 0, 0, -1)

    k = k - 1
  END IF
NEXT k

END SUB

SUB DoSprites

FOR k = 1 TO LEN(activespritestack)
  IF k > LEN(activespritestack) THEN EXIT FOR
  s = ASC(MID$(activespritestack, k, 1))

  '-- if this sprite is deadly --
  IF sprite(s).deadly AND TouchSprite(s) THEN KillPlayer
 
  '-- do animation --
  sprite(s).ticks = sprite(s).ticks - 1    ' advance animation ticks
  IF sprite(s).ticks = 0 THEN              '  next frame
    sprite(s).frame = sprite(s).frame + 1
    sprite(s).ticks = sprite(s).delay
  END IF

  IF sprite(s).repeat = 0 THEN
    '--- animation done and no repeat ---
    IF sprite(s).frame > sprite(s).eframe THEN
      '--- remove from active sprite stack ---
      activespritestack = LEFT$(activespritestack, k - 1) + RIGHT$(activespritestack, LEN(activespritestack) - k)
      unusedspritestack = unusedspritestack + CHR$(s)
      k = k - 1
    END IF
   ELSE
    '--- loop the repeating sprite ---
    IF sprite(s).frame > sprite(s).eframe THEN
      sprite(s).frame = sprite(s).sframe
    END IF
    '--- check lifespan ---
    IF sprite(s).lifespan = 0 THEN
      '--- remove from active sprite stack ---
      activespritestack = LEFT$(activespritestack, k - 1) + RIGHT$(activespritestack, LEN(activespritestack) - k)
      unusedspritestack = unusedspritestack + CHR$(s)
      k = k - 1
     ELSE
      '--- decrease lifespan if its used ---
      IF sprite(s).lifespan > 0 THEN sprite(s).lifespan = sprite(s).lifespan - 1
    END IF
  END IF
NEXT k

END SUB

SUB DrawItems

FOR k = 1 TO LEN(activeitemstack)
  i = ASC(MID$(activeitemstack, k, 1))
 
  '--- if item is on screen ---
  x1 = item(i).x - (item(i).xsize / 2)
  y1 = item(i).y - (item(i).ysize / 2)
  x2 = item(i).x + (item(i).xsize / 2)
  y2 = item(i).y + (item(i).ysize / 2)
  IF OnCamera(x1, y1, x2, y2) THEN
    
    '--- draw item ---
    x = item(i).x - CameraOrigX - (item(i).xsize / 2)
    y = item(i).y - CameraOrigY - (item(i).ysize / 2)
    frame& = item(i).sframe + (INT(anmcounter / item(i).delay) MOD item(i).frames)
    PutSprite frame&, x, y, drawpage
  END IF
NEXT k

END SUB

SUB DrawSprites

FOR k = 1 TO LEN(activespritestack)
  s = ASC(MID$(activespritestack, k, 1))

  '--- if sprite is on screen ---
  x1 = sprite(s).x - (sprite(s).xsize / 2)
  y1 = sprite(s).y - (sprite(s).ysize / 2)
  x2 = sprite(s).x + (sprite(s).xsize / 2)
  y2 = sprite(s).y + (sprite(s).ysize / 2)
  IF OnCamera(x1, y1, x2, y2) THEN

    '--- draw sprite ---
    x = sprite(s).x - CameraOrigX - (sprite(s).xsize / 2)
    y = sprite(s).y - CameraOrigY - (sprite(s).ysize / 2)
    PutSprite sprite(s).frame, x, y, drawpage
  END IF
NEXT k

END SUB

SUB InitItems

OPEN "engine.dat" FOR INPUT AS 1
  DO: INPUT #1, Text$
  LOOP UNTIL UCASE$(Text$) = "[ITEMS.DAT]"
  INPUT #1, numitemtypes
  FOR i = 1 TO numitemtypes
    INPUT #1, bonus(i).sframe
    INPUT #1, bonus(i).frames
    INPUT #1, bonus(i).delay
    INPUT #1, bonus(i).psframe
    INPUT #1, bonus(i).pframes
    INPUT #1, bonus(i).pdelay
    INPUT #1, bonus(i).xsize
    INPUT #1, bonus(i).ysize
    INPUT #1, bonus(i).pxsize
    INPUT #1, bonus(i).pysize
    INPUT #1, bonus(i).points
    INPUT #1, bonus(i).ammo
    INPUT #1, bonus(i).lifedrop
    INPUT #1, bonus(i).gemkey
  NEXT i
CLOSE 1

ClearItems
ClearSprites

END SUB

SUB LoadItems (f)

GET #f, , numitems
IF numitems > 255 THEN DebugLog "WARNING: Items in map:" + STR$(numitems): numitems = 255

FOR i = 1 TO numitems
  GET #f, , item(i).x
  GET #f, , item(i).y
  GET #f, , item(i).id
  item(i).sframe = bonus(item(i).id).sframe
  item(i).frames = bonus(item(i).id).frames
  item(i).delay = bonus(item(i).id).delay
  item(i).xsize = bonus(item(i).id).xsize
  item(i).ysize = bonus(item(i).id).ysize
  item(i).scored = 0
  activeitemstack = activeitemstack + CHR$(i)
NEXT i

END SUB

SUB LoadItemsFromFile (f)

activeitemstack = "": GET #f, , i
FOR k = 1 TO i
  GET #f, , item(k)
  activeitemstack = activeitemstack + CHR$(k)
NEXT k

END SUB

SUB LoadSpritesFromFile (f)

activespritestack = ""
unusedspritestack = ""

GET #f, , s
FOR k = 1 TO s
  GET #f, , sprite(k)
  activespritestack = activespritestack + CHR$(k)
NEXT k

FOR k = LEN(activespritestack) + 1 TO 100
  unusedspritestack = unusedspritestack + CHR$(k)
NEXT k

END SUB

SUB MoveSprite (s, x, y)

sprite(s).x = sprite(s).x + x
sprite(s).y = sprite(s).y + y

END SUB

FUNCTION TouchItem (i)

'x1,y1---x2,y1    x1,y1---x2,y1
'  |       |        |       |
'  |   P   |        |   I   |
'  |       |        |       |
'  |       |        |       |
'x1,y2---x2,y2    x1,y2---x2,y2

'--- corners of objects ---
px1 = player(0).x - (player(0).txsize / 2): py1 = player(0).y - (player(0).tysize / 2)
px2 = player(0).x + (player(0).txsize / 2): py2 = player(0).y + (player(0).tysize / 2)
ix1 = item(i).x - (item(i).xsize / 2): iy1 = item(i).y - (item(i).ysize / 2)
ix2 = item(i).x + (item(i).xsize / 2): iy2 = item(i).y + (item(i).ysize / 2)

'--- collision test ---
IF ix1 >= px1 AND ix1 <= px2 AND iy1 >= py1 AND iy1 <= py2 THEN TouchItem = 1
IF ix2 >= px1 AND ix2 <= px2 AND iy1 >= py1 AND iy1 <= py2 THEN TouchItem = 1
IF ix1 >= px1 AND ix1 <= px2 AND iy2 >= py1 AND iy2 <= py2 THEN TouchItem = 1
IF ix2 >= px1 AND ix2 <= px2 AND iy2 >= py1 AND iy2 <= py2 THEN TouchItem = 1
IF px1 >= ix1 AND px1 <= ix2 AND py1 >= iy1 AND py1 <= iy2 THEN TouchItem = 1
IF px2 >= ix1 AND px2 <= ix2 AND py1 >= iy1 AND py1 <= iy2 THEN TouchItem = 1
IF px1 >= ix1 AND px1 <= ix2 AND py2 >= iy1 AND py2 <= iy2 THEN TouchItem = 1
IF px2 >= ix1 AND px2 <= ix2 AND py2 >= iy1 AND py2 <= iy2 THEN TouchItem = 1


END FUNCTION

FUNCTION TouchSprite (s)

'x1,y1---x2,y1    x1,y1---x2,y1
'  |       |        |       |
'  |   P   |        |   S   |
'  |       |        |       |
'  |       |        |       |
'x1,y2---x2,y2    x1,y2---x2,y2

'--- corners of objects ---
px1 = player(0).x - (player(0).txsize / 4): py1 = player(0).y - (player(0).tysize / 2)
px2 = player(0).x + (player(0).txsize / 4): py2 = player(0).y + (player(0).tysize / 2)
sx1 = sprite(s).x - (sprite(s).xsize / 2): sy1 = sprite(s).y - (sprite(s).ysize / 2)
sx2 = sprite(s).x + (sprite(s).xsize / 2): sy2 = sprite(s).y + (sprite(s).ysize / 2)

'--- collision test ---
IF sx1 >= px1 AND sx1 <= px2 AND sy1 >= py1 AND sy1 <= py2 THEN TouchSprite = 1
IF sx2 >= px1 AND sx2 <= px2 AND sy1 >= py1 AND sy1 <= py2 THEN TouchSprite = 1
IF sx1 >= px1 AND sx1 <= px2 AND sy2 >= py1 AND sy2 <= py2 THEN TouchSprite = 1
IF sx2 >= px1 AND sx2 <= px2 AND sy2 >= py1 AND sy2 <= py2 THEN TouchSprite = 1
IF px1 >= sx1 AND px2 <= sx2 AND py1 >= sy1 AND py1 <= sy2 THEN TouchSprite = 1
IF px2 >= sx1 AND px2 <= sx2 AND py1 >= sy1 AND py1 <= sy2 THEN TouchSprite = 1
IF px1 >= sx1 AND px1 <= sx2 AND py2 >= sy1 AND py2 <= sy2 THEN TouchSprite = 1
IF px2 >= sx1 AND px2 <= sx2 AND py2 >= sy1 AND py2 <= sy2 THEN TouchSprite = 1

END FUNCTION

SUB WriteItemsToFile (f)

i = LEN(activeitemstack): PUT #f, , i
FOR i = 1 TO LEN(activeitemstack)
  k = ASC(MID$(activeitemstack, i, 1))
  PUT #f, , item(k)
NEXT i

END SUB

SUB WriteSpritesToFile (f)

s = LEN(activespritestack): PUT #f, , s
FOR s = 1 TO LEN(activespritestack)
  k = ASC(MID$(activespritestack, s, 1))
  PUT #f, , sprite(k)
NEXT s

END SUB


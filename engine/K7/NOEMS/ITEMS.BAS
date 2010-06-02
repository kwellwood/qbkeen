DEFINT A-Z
'$DYNAMIC

'$INCLUDE: 'engine.bi'
'$INCLUDE: 'directqb.bi'
'$INCLUDE: 'xms.bi'
'$INCLUDE: 'paklib.bi'
'$INCLUDE: 'plugins.bi'

ON ERROR GOTO ErrorHandler

'============================================================================
ErrorHandler:
e = ERR
ErrorHandlerSub e
RESUME NEXT

REM $STATIC
SUB ClearSprites

activespritestack(0) = ""  'clear sprite stack
unusedspritestack(0) = ""  'clear unused sprite stack
FOR s = 1 TO 100           'fill unused sprite stack
  sprite(s).deadly = 0
  sprite(s).ticks = 0
  sprite(s).repeat = 0
  unusedspritestack(0) = unusedspritestack(0) + CHR$(s)
NEXT s

END SUB

SUB DoItems

FOR k = 1 TO LEN(activeitemstack(0))
  IF k > LEN(activeitemstack(0)) THEN EXIT FOR
  i = ASC(MID$(activeitemstack(0), k, 1))

  IF TouchItem(i) THEN
    '--- award bonus' value ---
    IF bonus(item(i).id).points THEN
      player(0).score = player(0).score + bonus(item(i).id).points
      PlaySound 13
    END IF
    IF bonus(item(i).id).ammo THEN
      player(0).ammo = player(0).ammo + bonus(item(i).id).ammo
      PlaySound 15
    END IF
    IF bonus(item(i).id).lifedrop THEN
      player(0).drops = player(0).drops + bonus(item(i).id).lifedrop
      PlaySound 14
      IF player(0).drops > 99 THEN
        player(0).drops = 0
        player(0).lives = player(0).lives + 1
        oneup = 1
       ELSE oneup = 0
      END IF
    END IF
    '--- remove from active item stack ---
    activeitemstack(0) = LEFT$(activeitemstack(0), k - 1) + RIGHT$(activeitemstack(0), LEN(activeitemstack(0)) - k)
   
    '--- add point marker to sprite stack ---
    IF LEN(unusedspritestack(0)) THEN
      s = ASC(LEFT$(unusedspritestack(0), 1))
      unusedspritestack(0) = RIGHT$(unusedspritestack(0), LEN(unusedspritestack(0)) - 1)
      activespritestack(0) = activespritestack(0) + CHR$(s)
      sprite(s).x = item(i).x: sprite(s).y = item(i).y - (bonus(item(i).id).pysize / 2)
      sprite(s).frame = bonus(item(i).id).psframe
      sprite(s).eframe = bonus(item(i).id).psframe + bonus(item(i).id).pframes - 1
      sprite(s).delay = bonus(item(i).id).pdelay
      sprite(s).ticks = sprite(s).delay
      sprite(s).xsize = bonus(item(i).id).pxsize
      sprite(s).ysize = bonus(item(i).id).pysize
    END IF
   
    k = k - 1
    collectItem = 0
  END IF
NEXT k

END SUB

SUB DoSprites

FOR k = 1 TO LEN(activespritestack(0))
  IF k > LEN(activespritestack(0)) THEN EXIT FOR
  s = ASC(MID$(activespritestack(0), k, 1))
  
  '-- if this sprite is deadly --
  IF sprite(s).deadly AND TouchSprite(s) THEN KillPlayer
 
  '-- do animation --
  sprite(s).ticks = sprite(s).ticks - 1    ' advance animation ticks
  IF sprite(s).ticks = 0 THEN              '  next frame
    sprite(s).frame = sprite(s).frame + 1
    sprite(s).ticks = sprite(s).delay
  END IF

  '-- animation done: kill or loop --
  IF sprite(s).frame > sprite(s).eframe THEN
    IF sprite(s).repeat = 0 THEN
      '--- remove from active sprite stack ---
      activespritestack(0) = LEFT$(activespritestack(0), k - 1) + RIGHT$(activespritestack(0), LEN(activespritestack(0)) - k)
      unusedspritestack(0) = unusedspritestack(0) + CHR$(s)
      k = k - 1
     ELSE
      sprite(s).frame = sprite(s).sframe
    END IF
  END IF
NEXT k

END SUB

SUB DrawItems

FOR k = 1 TO LEN(activeitemstack(0))
  i = ASC(MID$(activeitemstack(0), k, 1))
 
  IF item(i).x + (item(i).xsize / 2) >= camera(0).vx1 AND item(i).x - (item(i).xsize / 2) <= camera(0).vx2 THEN
    IF item(i).y + (item(i).ysize / 2) >= camera(0).vy1 AND item(i).y - (item(i).ysize / 2) <= camera(0).vy2 THEN
    
      x = item(i).x - camera(0).vx1 - (item(i).xsize / 2)
      y = item(i).y - camera(0).vy1 - (item(i).ysize / 2)

      frame& = item(i).sframe + (INT(anmcounter / item(i).delay) MOD item(i).frames)
      PutSprite frame&, x, y, drawpage
    END IF
  END IF
NEXT k

END SUB

SUB DrawSprites

FOR k = 1 TO LEN(activespritestack(0))
  s = ASC(MID$(activespritestack(0), k, 1))

  IF sprite(s).x + (sprite(s).xsize / 2) >= camera(0).vx1 AND sprite(s).x - (sprite(s).xsize / 2) <= camera(0).vx2 THEN
    IF sprite(s).y + (sprite(s).ysize / 2) >= camera(0).vy1 AND sprite(s).y - (sprite(s).ysize / 2) <= camera(0).vy2 THEN
   
      x = sprite(s).x - camera(0).vx1 - (sprite(s).xsize / 2)
      y = sprite(s).y - camera(0).vy1 - (sprite(s).ysize / 2)

      'frame& = item(i).sframe + (INT(anmcounter / item(i).delay) MOD item(i).frames)
      PutSprite sprite(s).frame, x, y, drawpage
    END IF
  END IF
NEXT k

END SUB

SUB InitItems

OPEN "items.dat" FOR INPUT AS 1
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

activeitemstack(0) = ""
activespritestack(0) = ""
unusedspritestack(0) = ""
FOR s = 1 TO 100: unusedspritestack(0) = unusedspritestack(0) + CHR$(s): NEXT s

END SUB

FUNCTION TouchItem (i)

px1 = player(0).x - (player(0).txsize / 2): py1 = player(0).y - (player(0).tysize / 2)
px2 = player(0).x + (player(0).txsize / 2): py2 = player(0).y + (player(0).tysize / 2)
ix1 = item(i).x - (item(i).xsize / 2): iy1 = item(i).y - (item(i).ysize / 2)
ix2 = item(i).x + (item(i).xsize / 2): iy2 = item(i).y + (item(i).ysize / 2)

IF ix1 >= px1 AND ix1 <= px2 AND iy1 >= py1 AND iy1 <= py2 THEN TouchItem = 1
IF ix2 >= px1 AND ix2 <= px2 AND iy1 >= py1 AND iy1 <= py2 THEN TouchItem = 1
IF ix1 >= px1 AND ix1 <= px2 AND iy2 >= py1 AND iy2 <= py2 THEN TouchItem = 1
IF ix2 >= px1 AND ix2 <= px2 AND iy2 >= py1 AND iy2 <= py2 THEN TouchItem = 1

END FUNCTION

FUNCTION TouchSprite (s)

px1 = player(0).x - (player(0).txsize / 4): py1 = player(0).y - (player(0).tysize / 2)
px2 = player(0).x + (player(0).txsize / 4): py2 = player(0).y + (player(0).tysize / 2)
sx1 = sprite(s).x - (sprite(s).xsize / 2): sy1 = sprite(s).y - (sprite(s).ysize / 2)
sx2 = sprite(s).x + (sprite(s).xsize / 2): sy2 = sprite(s).y + (sprite(s).ysize / 2)

'--- is player touching this sprite? ---
IF sx1 >= px1 AND sx1 <= px2 AND sy1 >= py1 AND sy1 <= py2 THEN TouchSprite = 1
IF sx2 >= px1 AND sx2 <= px2 AND sy1 >= py1 AND sy1 <= py2 THEN TouchSprite = 1
IF sx1 >= px1 AND sx1 <= px2 AND sy2 >= py1 AND sy2 <= py2 THEN TouchSprite = 1
IF sx2 >= px1 AND sx2 <= px2 AND sy2 >= py1 AND sy2 <= py2 THEN TouchSprite = 1

END FUNCTION


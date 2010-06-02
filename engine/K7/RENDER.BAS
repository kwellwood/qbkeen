DEFINT A-Z
'$INCLUDE: 'engine.bi'
'$INCLUDE: 'directqb.bi'
'$INCLUDE: 'timer.bi'
'$INCLUDE: 'tiles.bi'
'$INCLUDE: 'map.bi'
'$INCLUDE: 'player.bi'
'$INCLUDE: 'items.bi'
'$INCLUDE: 'enemies.bi'
'$INCLUDE: 'weapons.bi'
'$INCLUDE: 'lifts.bi'
'$INCLUDE: 'scores.bi'
'$INCLUDE: 'switches.bi'
'$INCLUDE: 'menu.bi'
'$INCLUDE: 'render.bi'
'$STATIC

TYPE camtype
 x AS INTEGER
 y AS INTEGER
 vx1 AS INTEGER
 vy1 AS INTEGER
 vx2 AS INTEGER
 vy2 AS INTEGER
END TYPE

DECLARE SUB DrawDebugHUD ()
DECLARE SUB DrawObjects ()

ON ERROR GOTO ErrorHandler

DIM SHARED camera(0) AS camtype
'============================================================================
ErrorHandler:
e = ERR
ErrorHandlerSub e
RESUME NEXT

FUNCTION CameraOrigX

CameraOrigX = camera(0).vx1

END FUNCTION

FUNCTION CameraOrigY

CameraOrigY = camera(0).vy1

END FUNCTION

FUNCTION CameraX

CameraX = camera(0).x

END FUNCTION

FUNCTION CameraY

CameraY = camera(0).y

END FUNCTION

SUB DoCamera

'-- dont track player while dying --
IF player(0).action = dying THEN EXIT SUB
IF player(0).dead THEN EXIT SUB

'-- loose tracking box --
IF player(0).x - camera(0).x > 50 THEN camera(0).x = INT(player(0).x - 50)
IF player(0).x - camera(0).x < -50 THEN camera(0).x = INT(player(0).x + 50)
IF player(0).y - camera(0).y > 35 THEN camera(0).y = INT(player(0).y - 35)
IF player(0).y - camera(0).y < -35 THEN camera(0).y = INT(player(0).y + 35)

'-- set upper left of camera --
camera(0).vx1 = camera(0).x - 160: camera(0).vy1 = camera(0).y - 100
camera(0).vx2 = camera(0).vx1 + 319: camera(0).vy2 = camera(0).vy1 + 199
IF camera(0).vx1 < 0 THEN camera(0).vx1 = 0
IF camera(0).vy1 < 0 THEN camera(0).vy1 = 0

'-- set lower right of camera --
camera(0).vx2 = camera(0).vx1 + 319
camera(0).vy2 = camera(0).vy1 + 199
IF camera(0).vx2 > (ts * MapWidth) - 1 THEN camera(0).vx2 = (ts * MapWidth) - 1
IF camera(0).vy2 > (ts * MapHeight) - 1 THEN camera(0).vy2 = (ts * MapHeight) - 1

'-- reset upper left with lower right of camera --
camera(0).vx1 = camera(0).vx2 - 319
camera(0).vy1 = camera(0).vy2 - 199

END SUB

SUB DrawBox (x1, y1, x2, y2, c)

DQBbox DrawPage, x1, y1, x2, y2, 16
IF c THEN
  DQBboxf DrawPage, x1 + 1, y1 + 1, x2 - 1, y2 - 1, c
 'ELSE
 ' DQBfilterBox DrawPage, x1 + 1, y1 + 1, x2 - 1, y2 - 1, 144, 1
END IF

END SUB

SUB DrawDebugHUD


DQBsetTextStyle SOLID
DQBsetTextBackCol 148

'-- Camera and stack information --
DQBprint DrawPage, "Active items:" + STR$(ActiveItems), 225, 2, 15
DQBprint DrawPage, "Active sprites:" + STR$(ActiveSprites), 225, 10, 15
DQBprint DrawPage, "Active enemies:" + STR$(ActiveEnemies), 225, 18, 15
DQBprint DrawPage, "Active shots:" + STR$(ActiveShots), 225, 26, 15
DQBprint DrawPage, "Changing tiles:" + STR$(NumChangingTiles), 225, 34, 15

'-- animation ticker --
DQBprint DrawPage, "FrameTimer:" + STR$(CSElapsedTicks(0)), 228, 184, 15
DQBprint DrawPage, "AnmCounter:" + STR$(anmcounter), 228, 192, 15

'-- Clip points of player --
DQBpset DrawPage, player(0).x - camera(0).vx1, player(0).y - camera(0).vy1, 144
FOR cp = 1 TO 10
  DQBpset DrawPage, INT(clippoint(cp).x - camera(0).vx1), INT(clippoint(cp).y - camera(0).vy1), 15
NEXT cp

'-- Player(0) data structure --
SELECT CASE player(0).action
 CASE moving: act$ = "moving"
 CASE shooting: act$ = "shooting"
 CASE switching: act$ = "switching"
 CASE dying: act$ = "dying"
 CASE teleporting: act$ = "teleporting"
 CASE climbing: act$ = "climbing"
 CASE pogo: act$ = "pogo"
 CASE hanging: act$ = "hanging"
 CASE hangclimb: act$ = "hangclimbing"
 CASE idle: act$ = "idle"
 CASE swimming: act$ = "swimming"
 CASE ELSE: act$ = "undefined"
END SELECT

IF player(0).onball THEN
  on$ = "ball(" + LTRIM$(STR$(player(0).onball)) + ")"
 ELSEIF player(0).onlift THEN
  on$ = "lift(" + LTRIM$(STR$(player(0).onlift)) + ")"
 ELSEIF player(0).onslope THEN
  on$ = "slope"
 ELSEIF player(0).onground THEN
  on$ = "ground"
END IF

xv! = INT(player(0).xv * 100) / 100: yv! = INT(player(0).yv * 100) / 100

DQBprint DrawPage, "Player.x,y:" + STR$(INT(player(0).x)) + "," + STR$(INT(player(0).y)), 2, 2, 15
DQBprint DrawPage, "Player.xv,yv:" + STR$(xv!) + "," + STR$(yv!), 2, 10, 15
DQBprint DrawPage, "Player.action: " + act$, 2, 18, 15
DQBprint DrawPage, "Player.actiontime:" + STR$(player(0).actiontime), 2, 26, 15
DQBprint DrawPage, "Player.changeaction:" + STR$(player(0).changeaction), 2, 34, 15
DQBprint DrawPage, "Player.on: " + on$, 2, 42, 15
DQBprint DrawPage, "Player.canjump:" + STR$(player(0).canjump), 2, 50, 15
DQBprint DrawPage, "Player.frozen:" + STR$(player(0).frozen), 2, 58, 15
DQBprint DrawPage, "Player.idletime:" + STR$(player(0).idletime), 2, 66, 15


DQBsetTextStyle NONE

END SUB

SUB DrawObjects

DrawShots
DrawItems
DrawLifts
IF player(0).action <> dying AND gameplay <> stopped THEN DrawPlayer
DrawEnemies
DrawSprites

END SUB

SUB DrawScreen

IF ems THEN DQBboxf DrawPage, 0, 0, 319, 199, 14

'=======[ Translate Camera Area ]=======
minx = INT((camera(0).vx1 / ts) + 1): subx = camera(0).vx1 MOD ts
miny = INT((camera(0).vy1 / ts) + 1): suby = camera(0).vy1 MOD ts
maxx = INT((camera(0).vx2 / ts) + 1)
maxy = INT((camera(0).vy2 / ts) + 1)

'========[ Draw Tiles ]========
FOR y = miny TO maxy
  FOR x = minx TO maxx
    px = (x - minx) * ts - subx
    py = (y - miny) * ts - suby

    t& = Map&(x, y)
    t2& = MapFG&(x, y)
    IF t& THEN
      al = AnmLength(t&)
      IF t2& THEN al2 = AnmLength(t2&)
      IF al > 0 THEN
        ad = AnmDelay(t&)
        t& = (INT(anmcounter / ad) MOD al) + t&
      END IF
     
      '----- switches plugin -----
      IF TileType(t&) = 4 THEN t& = t& + GetSwitch(INT(SwitchTag&(x, y)))
      '---------------------------
     
      IF t& > 0 THEN PutSprite t&, px, py, DrawPage
     
      '\/ overlay the foreground
      t2type2 = TileType2(t2&)                 ' used to reduce xms calls
      IF t2& AND (t2type2 = 1 OR t2type2 = 14) THEN
        IF al2 > 0 AND t2type2 <> 14 THEN
          ad2 = AnmDelay(t2&)
          t2& = (INT(anmcounter / ad2) MOD al2) + t2&
        END IF
        PutSprite t2&, px, py, DrawPage
      END IF
    END IF
  NEXT x
NEXT y

'---[ Draw Sprites Classes ]---
DrawObjects
IF ems = 0 THEN DQBwait 1

'========[ DRAW FOREGROUND ]========
FOR y = miny TO maxy
  FOR x = minx TO maxx
    px = (x - minx) * ts - subx
    py = (y - miny) * ts - suby

    t2& = MapFG&(x, y)
    t2type2 = TileType2(t2&)    '\/ exit level     \/ enter level   \/ changingtile (overlayed)
    IF t2& AND t2type2 <> 1 AND t2type2 <> 10 AND t2type2 <> 12 AND t2type2 <> 14 THEN
      al = AnmLength(t2&)
      IF al THEN
        ad = AnmDelay(t2&)
        t2& = (INT(anmcounter / ad) MOD al) + t2&
      END IF
      PutSprite t2&, px, py, DrawPage
    END IF
  NEXT x
NEXT y

'-- draw player on top if dead --
IF player(0).action = dying THEN DrawPlayer

'---[ Draw HUD Information ]---
IF (ems OR DQBkey(61)) AND gameplay <> stopped THEN DrawScoreboard
IF gameplay = paused THEN
  PutTile 88&, 128, 80, DrawPage
  DQBprint DrawPage, "Paused", 145, 96, 14
END IF
IF showdropdownheight > -180 THEN DrawDropdown showdropdownheight
IF showdebughud THEN DrawDebugHUD
IF gamemode = inmenu THEN DrawMenu

IF ems THEN DQBcopyLayer DrawPage, video

END SUB

SUB FocusCamera

'-- center camera on player --
camera(0).x = player(0).x
camera(0).y = player(0).y

END SUB

SUB MoveCamera (x, y)

camera(0).x = camera(0).x + x
camera(0).y = camera(0).y + y

END SUB

FUNCTION OnCamera (x1, y1, x2, y2)

IF x2 >= camera(0).vx1 AND x1 <= camera(0).vx2 THEN
  IF y2 >= camera(0).vy1 AND y1 <= camera(0).vy2 THEN
    OnCamera = 1
  END IF
END IF

END FUNCTION


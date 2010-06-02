DEFINT A-Z
'$DYNAMIC

'$INCLUDE: 'engine.bi'
'$INCLUDE: 'directqb.bi'
'$INCLUDE: 'xms.bi'
'$INCLUDE: 'paklib.bi'
'$INCLUDE: 'plugins.bi'

ON ERROR GOTO ErrorHandler

DIM SHARED camera(0) AS camtype
'============================================================================
ErrorHandler:
e = ERR
ErrorHandlerSub e
RESUME NEXT

REM $STATIC
SUB DoCamera

'-- dont track player while dying --
IF player(0).action = dying THEN EXIT SUB

'-- loose tracking box --
IF player(0).x - camera(0).x > 60 THEN camera(0).x = player(0).x - 60
IF player(0).x - camera(0).x < -60 THEN camera(0).x = player(0).x + 60
IF player(0).y - camera(0).y > 40 THEN camera(0).y = player(0).y - 40
IF player(0).y - camera(0).y < -40 THEN camera(0).y = player(0).y + 40

'-- set upper left of camera --
camera(0).vx1 = camera(0).x - 160: camera(0).vy1 = camera(0).y - 100
camera(0).vx2 = camera(0).vx1 + 319: camera(0).vy2 = camera(0).vy1 + 199
IF camera(0).vx1 < 0 THEN camera(0).vx1 = 0
IF camera(0).vy1 < 0 THEN camera(0).vy1 = 0

'-- set lower right of camera --
camera(0).vx2 = camera(0).vx1 + 319
camera(0).vy2 = camera(0).vy1 + 199
IF camera(0).vx2 > (ts * mapxsize) - 1 THEN camera(0).vx2 = (ts * mapxsize) - 1
IF camera(0).vy2 > (ts * mapysize) - 1 THEN camera(0).vy2 = (ts * mapysize) - 1

'-- reset upper left with lower right of camera --
camera(0).vx1 = camera(0).vx2 - 319
camera(0).vy1 = camera(0).vy2 - 199

END SUB

SUB DrawHUD

'-- Camera and stack information --
DQBprint drawpage, "Camera(0).v1: (" + STR$(camera(0).vx1) + "," + STR$(camera(0).vy1) + ")", 200, 0, 15
DQBprint drawpage, "Camera(0).v2: (" + STR$(camera(0).vx2) + "," + STR$(camera(0).vy2) + ")", 200, 10, 15
DQBline drawpage, 198, 19, 318, 19, 15
DQBprint drawpage, "ActiveItemStack(0):" + STR$(LEN(activeitemstack(0))), 200, 22, 15
DQBprint drawpage, "ActiveSpriteStack(0):" + STR$(LEN(activespritestack(0))), 200, 32, 15
totalshots = 0: FOR s = 1 TO 5: totalshots = totalshots + shot(s).active: NEXT s
DQBprint drawpage, "ActiveShots:" + STR$(totalshots), 200, 42, 15
DQBprint drawpage, "ActiveFoeStack(0):" + STR$(LEN(activefoestack(0))), 200, 52, 15
DQBline drawpage, 198, 60, 318, 60, 15

'-- animation ticker --
DQBprint drawpage, "TIMER:" + STR$(TIMER), 1, 172, 15
DQBprint drawpage, "menudelay:" + STR$(menudelay!), 1, 182, 15
DQBprint drawpage, "anmcounter:" + STR$(anmcounter), 1, 192, 15

END SUB

SUB DrawObjects

DrawShots
DrawItems
DrawLifts
IF player(0).action <> dead THEN DrawPlayer
DrawEnemies
DrawSprites

END SUB

SUB DrawPlayerHUD

'-- Clip points of player --
DQBpset drawpage, player(0).x - camera(0).vx1, player(0).y - camera(0).vy1, 144
FOR cp = 1 TO 10
  DQBpset drawpage, ClipPoint(cp).x - camera(0).vx1, ClipPoint(cp).y - camera(0).vy1, 15
NEXT cp

'-- Player(0) data structure --
SELECT CASE player(0).action
 CASE moving: act$ = "move"
 CASE shooting: act$ = "shoot"
 CASE switching: act$ = "switch"
 CASE dying: act$ = "die"
 CASE teleporting: act$ = "teleport"
 CASE climbing: act$ = "climb"
 CASE pogo: act$ = "pogo"
 CASE hanging: act$ = "hanging"
 CASE hangclimb: act$ = "hangclimb"
 CASE idle: act$ = "idle"
 CASE ELSE: act$ = "undefined"
END SELECT

DQBprint drawpage, "Player(0).x,y:" + STR$(INT(player(0).x)) + "," + STR$(INT(player(0).y)), 2, 2, 15
DQBprint drawpage, "Player(0).xv:" + STR$(player(0).xv), 2, 12, 15
DQBprint drawpage, "Player(0).yv:" + STR$(player(0).yv), 2, 22, 15
DQBprint drawpage, "Player(0).action: " + act$, 2, 32, 15
DQBprint drawpage, "Player(0).actiontime:" + STR$(player(0).actiontime), 2, 42, 15
DQBprint drawpage, "Player(0).frame:" + STR$(player(0).frame), 2, 52, 15
DQBprint drawpage, "Player(0).onground:" + STR$(player(0).onground), 2, 62, 15
DQBprint drawpage, "Player(0).onslope:" + STR$(player(0).onslope), 2, 72, 15
DQBprint drawpage, "Player(0).canjump:" + STR$(player(0).canjump), 2, 82, 15
DQBprint drawpage, "Player(0).shooting:" + STR$(player(0).shooting), 2, 92, 15
DQBprint drawpage, "Player(0).reload:" + STR$(player(0).reload), 2, 102, 15
DQBprint drawpage, "Player(0).frozen:" + STR$(player(0).frozen), 2, 112, 15
DQBprint drawpage, "Player(0).usingportal:" + STR$(player(0).usingportal), 2, 122, 15
DQBprint drawpage, "Player(0).changeaction:" + STR$(player(0).changeaction), 2, 132, 15
DQBprint drawpage, "Player(0).holdingjump:" + STR$(player(0).holdingjump), 2, 142, 15
DQBprint drawpage, "Player(0).stoppedjump:" + STR$(player(0).stoppedjump), 2, 152, 15
DQBprint drawpage, "Player(0).onlift:" + STR$(player(0).onlift), 2, 162, 15
DQBprint drawpage, "Player(0).idletime:" + STR$(player(0).idletime), 2, 172, 15

END SUB

SUB DrawScreen

IF ems THEN dqbboxf drawpage, 0, 0, 319, 199, 14

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
      IF TileType(t&) = 4 THEN t& = t& + switch(SwitchTag(x, y))
      '---------------------------
     
      PutSprite t&, px, py, drawpage  '\/ overlay the foreground
      IF t2& AND TileType2(t2&) = 1 THEN
        IF al2 > 0 THEN
          ad2 = AnmDelay(t2&)
          t2& = (INT(anmcounter / ad2) MOD al2) + t2&
        END IF
        PutSprite t2&, px, py, drawpage
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
    IF t2& AND TileType2(t2&) <> 1 AND TileType2(t2&) <> 10 THEN
      al = AnmLength(t2&)
      IF al THEN
        ad = AnmDelay(t2&)
        t2& = (INT(anmcounter / ad) MOD al) + t2&
      END IF
      PutSprite t2&, px, py, drawpage
    END IF
  NEXT x
NEXT y

IF player(0).action = dead THEN DrawPlayer

'---[ Draw HUD Information ]---
IF ems OR DQBkey(61) THEN DrawScoreboard
IF DQBkey(59) THEN DrawHUD
IF DQBkey(60) THEN DrawPlayerHUD
IF gamemode = inmenu THEN DrawMenu

IF ems THEN DQBcopyLayer drawpage, video

END SUB

SUB FocusCamera

'-- center camera on player --
camera(0).x = player(0).x
camera(0).y = player(0).y

END SUB


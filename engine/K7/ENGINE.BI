DEFINT A-Z

CONST inmenu = 1, ingame = 2
CONST running = 1, paused = 2, stopped = 3
CONST jumpmode = 0, mapmode = 1
CONST up = 0, down = 1, left = 2, right = 3
CONST upleft = 4, downleft = 5, upright = 6, downright = 7
CONST FrameTimer = 0, AnmTimer = 1, HiResTimer = 2

COMMON SHARED anmcounter, menutimermark&
COMMON SHARED maxfps, ts, gamemode, movemode, gameplay, curlevel, ems, dolog
COMMON SHARED quitgame, showdebughud, showdropdownheight, maplocation$
COMMON SHARED pausedingame, totalancients
COMMON SHARED drawpage, menupage

DECLARE SUB DebugLog (t$)
DECLARE SUB ErrorHandlerSub (e)
DECLARE SUB FadeInPalette ()
DECLARE SUB FadeInPaletteStep ()
DECLARE SUB IncreaseIdleTime ()
DECLARE SUB LoadLevel (level)
DECLARE SUB StartLevel (level)
DECLARE SUB SetGameComplete ()
DECLARE SUB SetGameOver ()
DECLARE SUB SetLevelComplete ()
DECLARE SUB SetPalette ()
DECLARE FUNCTION TimerTicked (tmr)
DECLARE FUNCTION TimerTicks& (tmr)

TYPE coordinate
 x AS SINGLE
 y AS SINGLE
END TYPE

TYPE enemytype
  id AS INTEGER
  x AS SINGLE
  y AS SINGLE
  xv AS SINGLE
  yv AS SINGLE
  xdir AS INTEGER
  onground AS INTEGER
  onslope AS INTEGER
  action AS INTEGER
  actiontime AS INTEGER
  frame AS LONG
  xsize AS INTEGER
  ysize AS INTEGER
  txsize AS INTEGER
  tysize AS INTEGER
  status AS INTEGER
  statustime AS INTEGER
  xmax AS INTEGER
  ymax AS INTEGER
  starsprite AS INTEGER   ' slot of stars sprite if dead
END TYPE

TYPE globalvars        ' used to return multiple
 x AS SINGLE           '   values from a function
 y AS SINGLE           '   routine
 xv AS SINGLE
 yv AS SINGLE
 onground AS INTEGER
 onslope AS INTEGER
END TYPE

TYPE intcoordinate
 x AS INTEGER
 y AS INTEGER
END TYPE

TYPE playertype
 x AS SINGLE
 y AS SINGLE
 mapx AS SINGLE
 mapy AS SINGLE
 xv AS SINGLE
 yv AS SINGLE
 xdir AS INTEGER
 mapxdir AS INTEGER
 xmax AS SINGLE
 ymax AS SINGLE
 sframe AS LONG
 eframe AS LONG
 frame AS LONG
 delay AS INTEGER
 xsize AS INTEGER
 ysize AS INTEGER
 txsize AS INTEGER
 tysize AS INTEGER
 onground AS INTEGER
 onslope AS INTEGER     ' player is standing on an incline
 adelay AS INTEGER
 canjump AS INTEGER
 jumpheight AS SINGLE
 score AS LONG
 nextlifeat AS LONG
 ammo  AS INTEGER
 drops AS INTEGER
 keyred AS INTEGER
 keyblu AS INTEGER
 keygrn AS INTEGER
 keyyel AS INTEGER
 lives AS INTEGER
 reload AS INTEGER        ' time to wait for reload
 shooting AS INTEGER      ' time to display shooting frame
 shootingframe AS LONG    ' shooting frame to show
 aim AS INTEGER           ' aiming to shoot up or down
 action AS INTEGER        ' moving, shooting, climbing, flipping switch, pogo
 actiontime AS INTEGER    ' time left to complete action
 frozen AS INTEGER        ' cant move left or right
 usingportal AS INTEGER   ' if walking into a portal find destination x,y
 changeaction AS INTEGER  ' so cant switch between actions too fast
 holdingjump AS INTEGER   ' player is actively jumping up
 stoppedjump AS INTEGER   ' no longer holding the jump button
 onlift AS INTEGER        ' lift currently standing on
 onball AS INTEGER        ' bouncing ball currently standing on
 idletime AS INTEGER      ' frames player hasnt pressed a key
 invincible AS INTEGER
 dead AS INTEGER          ' finished dying sequence
 ancientsrescued AS INTEGER
 scuba AS INTEGER
END TYPE

COMMON SHARED scr()
COMMON SHARED player() AS playertype, ClipPoint() AS coordinate
COMMON SHARED enemy() AS enemytype, activefoestack AS STRING
COMMON SHARED eframe() AS LONG, efsize() AS intcoordinate
COMMON SHARED EClipPoint() AS coordinate
COMMON SHARED global() AS globalvars
COMMON SHARED levelscomplete()


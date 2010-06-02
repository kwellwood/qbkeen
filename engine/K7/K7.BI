DEFINT A-Z
'$DYNAMIC
'$INCLUDE: 'player.bi'
'$INCLUDE: 'tiles.bi'
'$INCLUDE: 'map.bi'
'$INCLUDE: 'render.bi'
'$INCLUDE: 'menu.bi'
'$INCLUDE: 'scores.bi'
'$INCLUDE: 'items.bi'
'$INCLUDE: 'sound.bi'
'$INCLUDE: 'weapons.bi'
'$INCLUDE: 'switches.bi'
'$INCLUDE: 'enemies.bi'
'$INCLUDE: 'teleport.bi'
'$INCLUDE: 'climbing.bi'
'$INCLUDE: 'lifts.bi'

DECLARE SUB AllocXMS ()
DECLARE SUB DeallocXMS ()
DECLARE SUB DoInput ()
DECLARE SUB DoPlayerDead ()
DECLARE SUB DoTimers ()
DECLARE SUB EndGame ()
DECLARE SUB EndLevel (victory)
DECLARE SUB InitEngine ()
DECLARE SUB LoadPalette ()
DECLARE SUB MainLoop ()
DECLARE SUB PrepareOverheadMap ()
DECLARE SUB ReadParameters ()
DECLARE SUB ResetTimer (tmr)
DECLARE SUB TakeScreenshot ()
DECLARE FUNCTION FrameReady ()
DECLARE FUNCTION GameComplete ()
DECLARE FUNCTION GameOver ()
DECLARE FUNCTION LevelComplete ()

CONST enginever = 16

COMMON SHARED tileset$, levelcompleteflag, gamecompleteflag, gameoverflag


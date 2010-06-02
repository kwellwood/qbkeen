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
DECLARE SUB DoTimers ()
DECLARE SUB InitEngine ()
DECLARE SUB MainLoop ()
DECLARE SUB NextLevel ()
DECLARE SUB ReadParameters ()
DECLARE SUB ResetTimer (tmr)
DECLARE SUB SetPalette ()
DECLARE FUNCTION FrameReady ()
DECLARE FUNCTION LevelComplete ()

CONST enginever = 15

COMMON SHARED tileset$, levelcompleteflag

TYPE hues
 red AS INTEGER
 grn AS INTEGER
 blu AS INTEGER
END TYPE


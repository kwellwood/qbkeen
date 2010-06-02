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

CONST enginever = 14

COMMON SHARED tileset$

TYPE hues
 red AS INTEGER
 grn AS INTEGER
 blu AS INTEGER
END TYPE


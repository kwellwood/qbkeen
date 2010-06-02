DEFINT A-Z
'$DYNAMIC

DECLARE SUB DrawMenu ()
DECLARE SUB HandleMenu (k)
DECLARE SUB InitMenu ()
DECLARE SUB Intro ()
DECLARE SUB NewGame ()
DECLARE SUB SaveGame ()
DECLARE SUB LoadGame ()

CONST menusysver = 1
CONST main = 1, options = 2, save = 3, load = 4

COMMON SHARED menu, menutile&, selectorstartfrm&, selectorframes, menuopt
COMMON SHARED menux, menuy, menudelay!, selectordelay, selectionpixels


@echo off
echo.
echo Compiling...
echo ------------------------------------------------------------------------

echo * Building Core Objects *
echo TILES.BAS...    (Tiles system)
bc tiles.bas /e/x/o/t/c:512; > tiles.cmp
echo MAP.BAS...      (Map system)
bc map.bas /e/x/o/t/c:512; > map.cmp
echo GRAPHICS.BAS... (Graphics system)
bc graphics.bas /e/x/o/t/c:512; > graphics.cmp
echo RENDER.BAS...   (Render system)
bc render.bas /e/x/o/t/c:512; > render.cmp
echo PAKLIB.BAS...   (Archive routines)
bc paklib.bas /e/x/o/t/c:512; > paklib.cmp

echo * Checking For Errors *
CALL CheckErr coreobj.dat

echo * Building Core Library *
echo K7CORE.LIB:
echo  +TILES.OBJ...    (Tiles system)
lib k7core.lib +tiles; > tiles.cmp
echo  +MAP.OBJ...      (Map system)
lib k7core.lib +map; > map.cmp
echo  +GRAPHICS.OBJ... (Graphics system)
lib k7core.lib +graphics; > graphics.cmp
echo  +RENDER.OBJ...   (Render system)
lib k7core.lib +render; > render.cmp
echo  +PAKLIB.OBJ...   (Archive routines)
lib k7core.lib +paklib; > paklib.cmp

echo * Checking for Errors *
CALL CheckErr corelib.dat

echo * Building Objects *
echo K7.BAS...       (Main routines)
bc k7.bas /e/x/o/t/c:512; > k7.cmp
echo PHYSICS.BAS...  (Player movement)
bc physics.bas /e/x/o/t/c:512; > physics.cmp
echo MENU.BAS...     (Menu system)
bc menu.bas /e/x/o/t/c:512; > menu.cmp
echo SCORES.BAS...   (Display scoreboard)
bc scores.bas /e/x/o/t/c:512; > scores.cmp
echo ITEMS.BAS...    (Player bonuses)
bc items.bas /e/x/o/t/c:512; > items.cmp
echo WEAPONS.BAS...  (Player weapons)
bc weapons.bas /e/x/o/t/c:512; > weapons.cmp
echo SWITCHES.BAS... (Switches)
bc switches.bas /e/x/o/t/c:512; > switches.cmp
echo SOUND.BAS...    (Sound system)
bc sound.bas /e/x/o/t/c:512; > sound.cmp

echo * Linking Objects *
echo KEEN7.EXE...    (Main program)
link /ex/noe k7 physics menu scores items weapons switches sound,keen7,,dqb xms k7core paklib bcom45 brun45; > link.cmp

echo * Checking For Errors *
CALL CheckErr modules.dat

echo * Cleaning Up *
move keen7.exe ..\..\game > nul
del k7core.lib
del k7core.bak
del keen7.map
del *.obj
del *.cmp
echo ------------------------------------------------------------------------
echo Compiling complete.
echo.

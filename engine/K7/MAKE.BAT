@echo off
echo.
echo Compiling...
echo ------------------------------------------------------------------------

echo * Building Objects *
echo K7.BAS...       (Main routines)
bc k7.bas /e/x/o/t/c:512; > k7.cmp
echo PHYSICS.BAS...  (Player movement)
bc physics.bas /e/x/o/t/c:512; > physics.cmp
echo TILES.BAS...    (Tiles system)
bc tiles.bas /e/x/o/t/c:512; > tiles.cmp
echo GRAPHICS.BAS... (Graphics System)
bc graphics.bas /e/x/o/t/c:512; > graphics.cmp
echo MAP.BAS...      (Map System)
bc map.bas /e/x/o/t/c:512; > map.cmp
echo RENDER.BAS...   (Render System)
bc render.bas /e/x/o/t/c:512; > render.cmp
echo MENU.BAS...     (Menu System)
bc menu.bas /e/x/o/t/c:512; > menu.cmp
echo PAKLIB.BAS...   (Archive routines)
bc paklib.bas /e/x/o/t/c:512; > paklib.cmp

echo * Linking Objects *
echo KEEN7.EXE...    (Main program)
link /ex/noe k7 physics tiles graphics map render menu paklib,keen7,,paklib bcom45 brun45 xms dqb; > link.cmp

echo * Checking For Errors *
CALL CheckErr

echo * Cleaning Up *
move keen7.exe ..\..\game > nul
del keen7.map
del *.obj
del *.cmp
echo ------------------------------------------------------------------------
echo Compiling complete.
echo.

@echo off
echo.
echo Compiling...
echo ------------------------------------------------------------------------

echo * Building Core Objects *
echo PLAYER.BAS...   (Player movement)
bc player.bas /e/x/o/t/c:512; > player.cmp
echo TILES.BAS...    (Tiles system)
bc tiles.bas /e/x/o/t/c:512; > tiles.cmp
echo MAP.BAS...      (Map system)
bc map.bas /e/x/o/t/c:512; > map.cmp
echo RENDER.BAS...   (Render system)
bc render.bas /e/x/o/t/c:512; > render.cmp
echo MENU.BAS...     (Menu system)
bc menu.bas /e/x/o/t/c:512; > menu.cmp
echo SCORES.BAS...   (Scoreboard routines)
bc scores.bas /e/x/o/t/c:512; > scores.cmp
echo ITEMS.BAS...    (Items system)
bc items.bas /e/x/o/t/c:512; > items.cmp
echo TELEPORT.BAS... (Player teleporting)
bc teleport.bas /e/x/o/t/c:512; > teleport.cmp
echo WEAPONS.BAS...  (Player weapons)
bc weapons.bas /e/x/o/t/c:512; > weapons.cmp
echo SOUND.BAS...    (Sound system)
bc sound.bas /e/x/o/t/c:512; > sound.cmp
echo PAKLIB.BAS...   (Archive routines)
bc paklib.bas /e/x/o/t/c:512; > paklib.cmp

echo * Checking For Errors *
CALL CheckErr coreobj.dat

echo * Building Core Library *
echo K7CORE.LIB:
echo  +PLAYER.OBJ...   (Player movement)
lib k7core.lib +player; > player.cmp
echo  +TILES.OBJ...    (Tiles system)
lib k7core.lib +tiles; > tiles.cmp
echo  +MAP.OBJ...      (Map system)
lib k7core.lib +map; > map.cmp
echo  +RENDER.OBJ...   (Render system)
lib k7core.lib +render; > render.cmp
echo  +MENU.OBJ...     (Menu system)
lib k7core.lib +menu; > menu.cmp
echo  +SCORES.OBJ...   (Scoreboard feature)
lib k7core.lib +scores; > scores.cmp
echo  +ITEMS.OBJ...    (Item system)
lib k7core.lib +items; > items.cmp
echo  +TELEPORT.OBJ... (Player teleporting)
lib k7core.lib +teleport; > teleport.cmp
echo  +WEAPONS.OBJ...  (Player weapons)
lib k7core.lib +weapons; > weapons.cmp
echo  +SOUND.OBJ...    (Sound system)
lib k7core.lib +sound; > sound.cmp
echo  +PAKLIB.OBJ...   (Archive routines)
lib k7core.lib +paklib; > paklib.cmp

echo * Checking for Errors *
CALL CheckErr corelib.dat

rem =========================================================================

echo * Building Enemy Objects *
echo ENEMIES.BAS...  (Enemy system)
bc enemies.bas /e/x/o/t/c:512; > enemies.cmp
echo ENEMIES1.BAS... (Enemy AI)
bc enemies1.bas /e/x/o/t/c:512; > enemies1.cmp
echo ENEMIES2.BAS... (Enemy AI)
bc enemies2.bas /e/x/o/t/c:512; > enemies2.cmp

echo * Checking For Errors *
CALL CheckErr enemyobj.dat

echo * Building Enemy Library *
echo K7ENEMY.LIB:
echo  +ENEMIES.OBJ...  (Enemy system)
lib k7enemy.lib +enemies; > enemies.cmp
echo  +ENEMIES1.OBJ... (Enemy AI)
lib k7enemy.lib +enemies1; > enemies1.cmp
echo  +ENEMIES2.OBJ... (Enemy AI)
lib k7enemy.lib +enemies2; > enemies2.cmp

echo * Checking for Errors *
CALL CheckErr enemylib.dat

rem =========================================================================

echo * Building Objects *
echo K7.BAS...       (Main routines)
bc k7.bas /e/x/o/t/c:512; > k7.cmp
echo SWITCHES.BAS... (Switches)
bc switches.bas /e/x/o/t/c:512; > switches.cmp
echo CLIMBING.BAS... (Climbing physics)
bc climbing.bas /e/x/o/t/c:512; > climbing.cmp
echo LIFTS.BAS...    (Moving platforms)
bc lifts.bas /e/x/o/t/c:512; > lifts.cmp
echo DS4QBPP.BAS...  (DirectSound system)
bc ds4qbpp.bas /e/x/o/t/c:512; > ds4qbpp.cmp

echo * Linking Objects *
echo KEEN7.EXE...    (Main program)
link /ex/noe k7 switches enemies climbing lifts ds4qbpp,keen7,,k7core k7enemy dqb timer paklib bcom45 brun45; >link.cmp

echo * Checking For Errors *
CALL CheckErr modules.dat

echo * Cleaning Up *
move keen7.exe ..\..\game > nul
del k7core.lib
del k7core.bak
del k7enemy.lib
del k7enemy.bak
del keen7.map
del *.obj
del *.cmp
echo ------------------------------------------------------------------------
echo Compiling complete.
echo.

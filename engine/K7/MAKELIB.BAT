rem ----- BUILD OBJECTS FOR K7CORE.LIB -----
echo * Building Objects *
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
rem ----------------------------------------

rem ------- BUILD K7CORE.LIB LIBRARY -------
echo * Building Library *
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
rem ----------------------------------------

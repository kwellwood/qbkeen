'p = clippoint
'hx!,hy! = location of clippoint that hit

'if point 2 is inside the box and player is moving up
' 

ny! = INT((hy! - (INT(hy!) MOD ts)) - 1)
side = down
 
player(0).yv = 0
player(0).y = INT(ny! - (player(0).ysize / 2))
player(0).onground = 1


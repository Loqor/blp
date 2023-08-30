-- title:   Astroflora
-- author:  EnigmA (Loqor, MagicMan(?))
-- desc:    Astroflora is a space-themed retro botany game developed by EnigmA focused on collecting flora and fauna from around multiple planets, galaxies, and asteroids.
-- site:    https://loqor.github.io/ & https://magicman.github.io/
-- license: Apache License 2.0
-- version: 0.1
-- script:  lua

--##############################--TODO--##############################--
-- ttri() for rotating the temporary ship/later on the player around planets/asteroids/astral bodies/ships.
-- Make planet sprites or generate them with code.
-- Make asteroid sprites or generate them with code.
-- Make <astral body> sprites or generate them with code, you get the point.
-- Make a map for the inside of a ship where you can view achievements and what you've collected on your travels.
-- Create general gameplay (hey I used a different word than make :D).
-- [Comments started at: 0100 hours, US Central Time -=- Comments ended at: 0200 hours, US Central Time]





-- If I see more variables defined here constantly, I will personally beat your ass. Lookin' at you, Magic boy.
function BOOT()

  player = {
    x=116,
    y=64,
    movespeed=0.2,
    maxspeed = 5,
    maxaccel = 1,
    decelspeed = 0.98,
    turnfactor = 0.5,

    angle = 0,
    velocity = 0,
    angularvelocity = 0,
  }


  circlex = 70
  circley = 20
  circleradius = 50
  circlesides = 12
  planetsprite = makePlanet(circlex,circley,circleradius,circlesides,8,0,8,32)

  t=0
  cam={x=120,y=68}

  background = {}
  bgcolours = {
    3,0,1
  }

  stars = {}

  math.randomseed(tstamp())

  for x=1,80 do
    if background[x-1] and math.random(1,10) > 2 then
      preval = background[x-1]
      value = {math.random(
        preval[1]-10,
        preval[1]+10)*2,
        
        math.random(preval[2]-25,
        preval[2]+25)*2,

        math.random(5,30),
        
        bgcolours[math.random(1,3)]}
    else
      value = {math.random(0,120)*2,math.random(0,68)*2,math.random(10,40),
      bgcolours[1]}
    end

    table.insert(background, value)
  end

  for x = 1,70 do
    table.insert(stars, {math.random(1,120),math.random(1,68)})
  end
  starseed = math.random(1,100)
end




-- L function used for drawing and rotation, also unused for some reason :)))))))) :insert clown emoji here:.
function rspr(sx,sy,scale,angle,mx,my,mw,mh,key,useMap) --I promise I didn't steal this :(

  --  this is fixed , to make a textured quad
  --  X , Y , U , V
  local sv ={{-1,-1, 0,0},
             { 1,-1, 0.999,0},
             {-1,1,  0,0.999},
             { 1,1,  0.999,0.999}}

	local rp = {} --  rotated points storage

  --  the scale is mw ( map width ) * 4 * scale 
  --  mapwidth is * 4 because we actually want HALF width to center the image
  local scalex = (mw<<2) * scale
  local scaley = (mh<<2) * scale
  --  rotate the quad points
  for p=1,#sv do 
    -- apply scale
    local _sx = sv[p][1] * scalex 
		local _sy = sv[p][2] * scaley
    -- apply rotation
		local a = angle
		local rx = _sx * math.cos(a) - _sy * math.sin(a)
		local ry = _sx * math.sin(a) + _sy * math.cos(a)
    -- apply transform
    sv[p][1] = rx + sx
    sv[p][2] = ry + sy
    -- scale UV's 
    sv[p][3] = (mx<<3) + (sv[p][3] * (mw<<3))
    sv[p][4] = (my<<3) + (sv[p][4] * (mh<<3))
  end
  -- draw two triangles for the quad
  textri( sv[1][1],sv[1][2],
          sv[2][1],sv[2][2],
          sv[3][1],sv[3][2],
          sv[1][3],sv[1][4],
          sv[2][3],sv[2][4],
          sv[3][3],sv[3][4],
          useMap,key)

  textri( sv[2][1],sv[2][2],
          sv[3][1],sv[3][2],
          sv[4][1],sv[4][2],
          sv[2][3],sv[2][4],
          sv[3][3],sv[3][4],
          sv[4][3],sv[4][4],
          useMap,key)
end

-- But why? Why would you do that? Why would you do any of that? - JonTron | originally called Makeplanet(), bro (MagicMan(?)) was not playing with a full deck of cards.
-- This function for some reason draws a planet with multiple sprites in a line, AKA, a rectangle is conformed to the size of a triangle and put together with other triangles like a slice of pie
--to make it look like a circle. The radius, if defined with pretty much any value other than like a few ones that I found, will leave a large gap in the slices of the pie, which in this case
--is Galactus' grandma's favorite BULLSH*T PIE. We need sprite planets as well, or they can be generated with code, I don't care, I just want planets looking like spherical planets and not
--whatever the hell this weird 2D sliced up poor planet is.
function makePlanet(x,y,radius,sides,UVx,UVy,UVw,UVh)

  --div angle by 360 to get sides, basic maths
  local angletemp = math.rad(360/sides)
  local angle = angletemp

  --gets xy coordinates for the two outer verts. Its duplicated, hence the angle+angle bit. Again just transposes point based on radius to get distance
  local lx = radius * math.cos(angletemp) + radius
  local ly = radius * math.sin(angletemp) + radius
  local rx = radius * math.cos(angletemp+angletemp) + radius
  local ry = radius * math.sin(angletemp+angletemp) + radius


  --...What? Bro is not cooking.
  --8,0 -> 16,8

  local planet = {} -- Stores the necessary ttri() values.
  for e = 1,sides do
    local ax = x + radius + (lx-radius)*math.cos(angle)-(ly-radius)*math.sin(angle) --similar, but now corrects the offset left/right/up/down etc to correct point
    local ay = y + radius + (lx-radius)*math.sin(angle)+(ly-radius)*math.cos(angle) --also adds offset of x and y
    local aax = x + radius + (rx-radius)*math.cos(angle)-(ry-radius)*math.sin(angle) 
    local aay = y + radius + (rx-radius)*math.sin(angle)+(ry-radius)*math.cos(angle)
    radiusx = radius+x
    radiusy = radius+y
    --The UV directions are weird ok, but it works
    table.insert(planet, {ax, ay, aax, aay, radiusx, radiusy, UVx+UVw, UVy, UVx, UVy, UVx+(UVw/2), UVy+UVh}) -- Cheeky little table.insert() which is almost completely unnecessary.
    angle = angle+angletemp
  end
  
  return planet,radius
  --radius is needed for stuff, planet is only ran on generation, they should need to be recalculated, so we can just return its vert data
  
    
end


-- init() is goofy. End of story.
function init()
  --use BOOT, any global variable should be defined in BOOT beforehand
  --organisation pls
end


function newvelocity()
  

  player.angle = player.angle + player.angularvelocity
  if player.angle > 360 then
    player.angle = player.angle-360
  end

  --calculates new position
  --player uses an angle, direction movement system
  --left right is controlled by angular velocity

  player.x = player.velocity*math.cos(math.rad(player.angle)) +player.x

  player.y = player.velocity*-math.sin(math.rad(player.angle)) +player.y


  player.velocity = player.velocity * player.decelspeed
  player.angularvelocity = player.angularvelocity * 0.95

  player.turnfactor = 0.5

  --WIP easing shit, needs to be changed if can make better
  --no I won't explain :)
  player.turnfactor = math.abs((player.movespeed - 0.5) / (5 - 0.5)*3)
  player.movespeed = math.abs((player.velocity - 0.5) / (5 - 0.5) / 6)
  if player.movespeed > 5 then player.movespeed = 5 end
  if player.turnfactor > 2 then player.turnfactor = 2 end
end

-- Described in TIC() function because hehe.
function velocity()

  -- Leaving this here so I can implement gravity for the character later.

  --if math.abs(p.vy) > (speed) then
  --  if p.vy < 0 then p.vy = (speed) else p.vy = (speed) end
  --end

  -- Basic code that was mimicked from the velocity function in my old game (magic's old code which is kinda bad but it's okay for now).




  -- I'm not.. particularly sure why we're putting the velocity values in parenthesis, but hey, I don't really care, it's just parenthesis.
  p.x = p.x + (p.vx) -- Temporary ship's x position = Temporary ship's x position PLUS (parenthesis for some reason) Temporary ship's velocity in the x direction.
  p.y = p.y + (p.vy) -- Temporary ship's y position = Temporary ship's y position PLUS (parenthesis for some reason) Temporary ship's velocity in the y direction.

  p.vx= p.vx*p.dx -- Temporary ship's velocity in the x direction = Temporary ship's velocity in the x direction TIMES Temporary ship's deccelaration in the x direction.
  p.vy = p.vy*p.dy -- Temporary ship's velocity in the y direction = Temporary ship's velocity in the y direction TIMES Temporary ship's deccelaration in the y direction.
  if math.abs(p.vx) < (0.05) then p.vx = 0 end -- If the absolute value of the temporary ship's velocity in the x direction IS LESS THAN 
  --(parenthesis for some reason) 0.05 then temporary ship's velocity in the x direction = 0.
  if math.abs(p.vy) < (0.05) then p.vy = 0 end -- If the absolute value of the temporary ship's velocity in the y direction IS LESS THAN 
  --(parenthesis for some reason) 0.05 then temporary ship's velocity in the y direction = 0.
end


-- Goofy ahh movement script, described in the TIC() function because, ofc, hehe.
function flyShipAndMove()

  -- This is pretty much just basic movement code for a ship with accel and deccel. Can be applied to other
  --moving objects/entities/the player.

  -- Press A or Left Arrow to move to the left. Crazy, I know.
  if btn(2) or key(01) then
    player.angularvelocity = player.angularvelocity - player.turnfactor
  end

  -- Press D or Right Arrow to move to the right. Nuts, I'm aware.
  if btn(3) or key(04) then
    player.angularvelocity = player.angularvelocity + player.turnfactor
  end

  -- Press W or Up Arrow to move to up/forward. Insane, I understand.
  if btn(0) or key(23) and player.velocity > -player.maxspeed then
    player.velocity = player.velocity - player.movespeed
  end

  -- Press S or Bottom Arrow to move down/backward. Crikey, I gets it.
  if btn(1) or key(19) and player.velocity < player.maxspeed then
    player.velocity = player.velocity + 0.01
  end
end

-- Goofy ahh draw() function because sorting.
function draw()


    --moved to draw cus its nicer, draw = draw stuff.
    vbank(0)
    -- Set the border radius to the color value of the 13th color slot.
    poke(0x3FF8, 13)
    -- Clears the screen with the color value of the 4th color slot.
    cls(4)
    
    -- Set the vbank to 1 for the foreground; e.g., player, tiles, etc. and the like.
    vbank(1)
    
    -- Sets the mouse cursor to be the sprite in #4 of the sprite sheet.
    poke(0x03FFB, 4)
    -- Sets the transparency color for vbank(1).
    poke(0x3FF8, 0)
    -- Clears the screen with the color value of slot 0.
    cls(00)

    for _,val in pairs(background) do
      circ(table.unpack(val))
    end
    for _,val in pairs(stars) do
      local x = val[1] *2
      local y = val[2] *2

      if math.random(1,1000) > 1 then
        line(x,y-1,x,y+1,5)
        line(x-1,y,x+1,y,5)
      else
        pix(x,y,5)
      end
    end

  -- I wanna sort everything that needs to be drawn into this function
  --because it just makes sorting easier, especially if there are bugs.
  --DO NOT add redundant calls, especially with different names. No functions like
  --function draw(sprite) <and then use sprite here like an idiot> end
  --if we're gonna make it general like that, might as well just code this in Brainf**k.    
  --no


  -- Calls the makePlanet() function to draw the *walkable* planet with ttri(). Idea: instead of constantly using this (although we totally could to do completely circular worlds), 
  --just set the map to whichever side you're on so it *looks* like you're going around the planet. Also, atmospheric effects will be necessary as well as parallax shifting.
  for _,val in pairs(planetsprite) do -- I still don't personally understand why _,val works, but honestly I'll just learn tomorrow, I gotta study.. (this comment was written 6 minutes after the philosophical question comment was).
    ttri(table.unpack(val))
  end
  -- _,val works becuase lua tables uses a key,value system, the pairs is to link them so it alternates through both at once. 
  -- So _ = the key of the table (like 1,2,3,4,5 etc) and val = the actual info of the slot in that table
  -- the name can be anything obviously

  -- these need to be added to player, lazy smh
  sprix = 1
  spriy = 8
  angle = 0

  --spirx, spriy 0-(idk can't do maths, however many cols) for row / column
  --mapwidth / height for size to draw, so 1,1 is 1 sprite tile total
    rspr( player.y,
      player.x,          --  x,y
      1,      --  scale
      math.rad(player.angle),      --  angle
      (sprix*2),  --  mapX
      spriy*2,              --  mapY
      2,              --  mapWidth
      2,              --  mapHeight
      0,false)


  -- Draws the sprite for the mouse cursor.
  spr(4,gmouse().x,gmouse().y,0,1)
end

--init() -- Honestly stuff breaks if I don't have this here.
--IT breaks because you're... defining a function that runs once on boot when their is already a BOOT() function, use it

-- TIC-80 moment.
function TIC()

    -- Time function.
   

    -- Temporary camera stuff.
    cam.x=120-player.x
    cam.y=68-player.y

    -- Calls movement function, called flyShipAndMove() for now as that's what it's doing.
    flyShipAndMove()

    -- Refer to velocity() function comments.
    newvelocity()

    -- There were a lot of issues getting this shit to work properly, for instance, when I fixed it, the poke was the wrong
    --type of poke; e.g., "poke4(0x03FF8, 0)" when it should just be poke(). Plus, it was placed *after* the vbank(1) selection call,
    --therefore nullifying whatever it was trying to do in the first place due to the fact that vbank(1) doesn't use the 0x03FF8 memory address like vbank(0) does (spoilers: it's for transparency).
    -- Adding onto this, the cls() was incorrectly set, and wasn't clearing the screen after vbank(1), instead, clearing it after vbank(0), making the screen the color of vbank(1)'s palette, 
    --which is undesirable. My fixes definitely are temporary as how it looks as of this moment is really strange, but I will organize in moments with comments :p.





    -- Calls the draw function I created, it's done in the foreground after the clear screen of vbank(1), as to divide from the functions and important memory stuff.
    draw()

    -- Testing, draws the values of the temporary ship's position on screen: warning, uses fixed point numbers because it's goofy.
    --print(p.x, 32, 32)
    --print(p.y, 32, 40)
    print("x: "..player.x, 20, 32)
    print("y: "..player.y, 20, 40)
    print("angle: "..player.angle,20,48)
    print("T factor: "..player.turnfactor,20,56)
    print("Vel: "..player.movespeed,20,64)

    -- Exit the current game to console with "`"
    if key(44) then
      exit()
    end

    t=t+1
end

-- Mouse function ripped directly from my old game (magic's old code that *doesn't* suck, haha).
function gmouse()
	local m = {}
	m.x,m.y,m.left,m.middle,m.right,m.scrollx,m.scrolly = mouse()
	return m
end










-- I hate that this is here (the <TILES> and whatever's below it).

-- <TILES>
-- 001:4444444444444444a44aa44aa4aaa4aaaaaaaa2aa22aa2222222aa22aaa22a22
-- 002:6666655566665555666222556662225566622259666222596222555b6222555b
-- 003:55555666555555565555552622222226999999661199116611bb1166bbbbbb66
-- 004:0000000000059000000000000202505005029020000000000009500000000000
-- 016:5558855555888855555885555558855555588555555885555558855555588555
-- 017:2222aaaa2aa22a22aaaa222aaaa222aaa222a2aa22aaa22a2aaaaa222aaaaaa2
-- 018:622225556222bbb86666bbee66666bee66666111666661116666311166663330
-- 019:bbbbb66688886666448866664444bb664444ee66011166660133666600336666
-- 033:abaaaaaabaaaabaabaabaabababbaabbbbbbbbbbbbbbbbbbeeeeeeeeeeeeeeee
-- 034:0000000000000fff000eeeee00eeebbb00bbbbbb0eeeeeee0bbbbbbb022aaaab
-- 035:00000000fff00000eeeee000bbbeee00bbbbbb00eeeeeee0ebbbbbe0bb222bb0
-- 049:eeeeeeeeeeeeeeeeffffffffffffffffffffffffffffffffffffffffffffffff
-- 050:0aaaaa220bbbbbbb0eeeeeee00bbbbbb00bbbbbb000beeee00000fff00000000
-- 051:2223aaa0bbaaabb0ebbbbbe0eeeeee00bbbbbb00eeeeb000fff0000000000000
-- 096:0000055500005555000222550002225500022259000222590222555b0222555b
-- 097:55555000555555505555552022222220999999001199110011bb1100bbbbbb00
-- 112:022225550222bbb80000bbee00000bee00000111000001110000311100003330
-- 113:bbbbb00088880000448800004444bb004444ee00011100000133000000330000
-- 224:000000000000000000000000000000009999999999888999ded444d44d444ded
-- </TILES>

-- <SPRITES>
-- 000:0000055500005555000222550002225500022259000222590222555b0222555b
-- 001:55555000555555505555552022222220999999001199110011bb1100bbbbbb00
-- 002:000000050000005f0000002c0000002c0c000326060023230300232502522325
-- 003:50000000f5000000c2000000c2000000623000c0323200605232003052322520
-- 004:0666666060000006600000066000000660000006600000066000000606666660
-- 016:022225550222bbb80000bbee00000bee00000111000001110000311100003330
-- 017:bbbbb00088880000448800004444bb004444ee00011100000133000000330000
-- 018:05523322255231232522332002522300252220012552001f2033003c006c0003
-- 019:223325503213255202332252003225201002225261002552630033023000c600
-- 032:122244ddaa444ddd24444dd044488ddd244488d8aa4448d8122448d8112488dd
-- 033:00dd88ddddd84ddd8d44d88d4844d8444448d844244884441444442412244232
-- 034:000000000000000c0000000f00000c00000000ff00c60000000f66660c00ffff
-- 035:00000000c0000000f000000000c00000ff00000000006c006666f000ffff00c0
-- 048:122a223312211233112111231121331331223333331211333111133131133331
-- 049:1121432111111331121131313333311311331111111333331111333311113333
-- 050:fc600000ff6666660ffccccc000fffff00000000000000000000000000000000
-- 051:000006cf666666ffcccccff0fffff00000000000000000000000000000000000
-- </SPRITES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <TRACKS>
-- 000:100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </TRACKS>

-- <PALETTE>
-- 000:d1b187c77b58ae5d4079444a4b3d44ba91589274414d453977743bb3a555d2c9a58caba14b726e574852847875ab9b8e
-- 001:0000001f0e1c8331293e2137216c4bdc534b7664fed365c846af45e18d799a6348d6b97b9ec2e8a1d685e9d8a1f5f4eb
-- </PALETTE>


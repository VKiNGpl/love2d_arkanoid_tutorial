local ball = require "ball"
local platform = require "platform"
local bricks = require "bricks"
local walls = require "walls"
local collisions = require "collisions"
local levels = require "levels"

function love.load()
   level = levels.require_current_level()
   bricks.construct_level( level )
   walls.construct_walls()
   love.window.setTitle('Arkanoid')
end
 
function love.update( dt )
   ball.update( dt )
   platform.update( dt )
   bricks.update( dt )
   walls.update( dt )
   collisions.resolve_collisions( ball, platform, walls, bricks )
   levels.switch_to_next_level( bricks, ball )
end
 
function love.draw()
   ball.draw()
   platform.draw()
   bricks.draw()
   walls.draw()
   if levels.gamefinished then
      love.graphics.printf( "Congratulations!\n" ..
			       "You have finished the game!",
			    300, 250, 200, "center" )
   end
end

function love.keyreleased( key, code )
   if key == 'c' then
      bricks.clear_current_level_bricks()
   elseif key == 'escape' then
      love.event.quit()
   end    
end

function love.quit()
  print("Thanks for playing! Come back soon!")
end
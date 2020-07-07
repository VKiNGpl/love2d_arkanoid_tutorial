local balls = require "balls"
local platform = require "platform"
local bricks = require "bricks"
local bonuses = require "bonuses"
local walls = require "walls"
local side_panel = require "side_panel"
local collisions = require "collisions"
local levels = require "levels"

local game = {}

function game.load( prev_state, ... )
   walls.construct_walls()   
end

function game.enter( prev_state, ... )
   local args = ...
   if prev_state == "gamepaused" then
      music:play()
   end
   if prev_state == "gameover" or prev_state == "gamefinished" then
      side_panel.reset()
      music:seek(0)
   end
   if args and args.current_level then
      bricks.clear_current_level_bricks()
      bonuses.clear_current_level_bonuses()
      levels.current_level = args.current_level
      local level = levels.require_current_level()
      bricks.construct_level( level )
      balls.reset()
      platform.remove_bonuses_effects()
      walls.remove_bonuses_effects()
   end      
end

function game.update( dt )
   balls.update( dt, platform )
   platform.update( dt )
   bricks.update( dt )
   bonuses.update( dt )
   walls.update( dt )
   side_panel.update( dt )
   collisions.resolve_collisions( balls, platform,
				  walls, bricks,
				  bonuses, side_panel )
   side_panel.lives_display.add_life_if_score_reached(
      side_panel.score_display.score )
   game.check_no_more_balls( balls, side_panel.lives_display )
   game.switch_to_next_level( bricks, levels )
end

function game.draw()
   balls.draw()
   platform.draw()
   bricks.draw()
   bonuses.draw()
   walls.draw()
   side_panel.draw()
end

function game.keyreleased( key, code )
   if key == 'c' then
      bricks.clear_current_level_bricks()
   elseif key == ' ' then
      balls.launch_single_ball_from_platform()
   elseif  key == 'escape' then
      music:pause()
      gamestates.set_state(
	 "gamepaused",
	 { balls, platform, bricks, bonuses, walls, side_panel } )
   end
end

function game.mousereleased( x, y, button, istouch )
   if button == 'l' or button == 1 then
      balls.launch_single_ball_from_platform()
   elseif button == 'r' or button == 2 then
      music:pause()
      gamestates.set_state(
	 "gamepaused",
	 { balls, platform, bricks, bonuses, walls, side_panel } )
   end
end

function game.check_no_more_balls( balls, lives_display )
   if balls.no_more_balls then
      lives_display.lose_life()      
      if lives_display.lives < 0 then
	 gamestates.set_state( "gameover",
			       { balls, platform, bricks,
				 bonuses, walls, side_panel } )
      else
	 balls.reset()
	 platform.remove_bonuses_effects()
	 walls.remove_bonuses_effects()
      end
   end
end

function game.switch_to_next_level( bricks, levels )
   if bricks.no_more_bricks or platform.activated_next_level_bonus then
      bricks.clear_current_level_bricks()
      bonuses.clear_current_level_bonuses()
      if levels.current_level < #levels.sequence then
	 gamestates.set_state(
	    "game", { current_level = levels.current_level + 1 } )
      else
	 gamestates.set_state( "gamefinished" )
      end
   end
end

return game

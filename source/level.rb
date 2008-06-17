# Copyright (c) 2008 Joakim Kolsjö, Anders Asplund and Johan Larsson
# 
# This software is provided 'as-is', without any express or implied warranty.
# In no event will the authors be held liable for any damages arising from
# the use of this software.
# 
# Permission is granted to anyone to use this software for any purpose,
# including commercial applications, and to alter it and redistribute it
# freely, subject to the following restrictions:
# 
# 1. The origin of this software must not be misrepresented; you must
#    not claim that you wrote the original software. If you use this
#    software in a product, an acknowledgment in the product documentation
#    would be appreciated but is not required.
# 2. Altered source versions must be plainly marked as such, and must not
#    be misrepresented as being the original software.
# 3. This notice may not be removed or altered from any source distribution.

require 'RMagick2'
require File.dirname(__FILE__)  + '/rect.rb'
require File.dirname(__FILE__)  + '/flow.rb'

class Level
  include Flow
  
  attr_accessor :progress
  
  def initialize
    @window = Game.window
    @scale = @window.scale
    
    @water0 = Gosu::Image.new(@window, "data/sprites/water_01.png", true)
    @water1 = Gosu::Image.new(@window, "data/sprites/water_02.png", true)
    @ship = Gosu::Image.new(@window, "data/pirateship_level.png", true)
    @overlay = Gosu::Image.new(@window, "data/pirateship_level_overlay.png", true)
    @overlay2 = Gosu::Image.new(@window, "data/pirateship_level_mast.png", true)
    @collision_map = Magick::Image.read('data/pirateship_level_col.png').first
  
    #@start_area = Rect.new(360, 340, 930, 380)
    @progress = 0
    @last = 0
  end
  
  def draw  
    reset_cycle
      
    grid(40, 26) do |x, y|
			pos = ((y * 32)) - @window.camera_position % 64
			
			if cycle(true, false)			  
				@water0.draw(x * 32 * @scale, pos * @scale, 0, @scale, @scale)
			else
				@water1.draw(x * 32 * @scale, pos * @scale, 0, @scale, @scale)
			end
		end
		
		@ship.draw(128 * @scale, -@window.camera_position * @scale, 0, @scale, @scale)
  end
  
  def draw_overlay
    @overlay.draw(128 * @scale, -@window.camera_position * @scale, 0, @scale, @scale)
    @overlay2.draw(128 * @scale, -@window.camera_position * @scale, 0, @scale, @scale)    
  end
  
  def valid_position?(x, y)
    @collision_map.pixel_color(x - 128, + y).red != 0
  end
  
  def generate_spawn_position(monster)
    diff = 0
    diff = 300 if monster
    
    area = Rect.new(360, 300 - 30 + diff, 930,
                                 300 + 30 + diff*8)
    area.random_position
  end
  
  private
  
	def grid(width, height)
		0.upto(width) do |x|
			0.upto(height) do |y|
				yield x, y
			end
		end
	end  
end
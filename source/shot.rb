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

require File.dirname(__FILE__)  + '/sprite.rb'
require File.dirname(__FILE__)  + '/gameobject.rb'


class Shot  
  include GameObject
  
  attr_accessor :alive
  attr_reader :position, :player
          
  def self.life
    @@life
  end
  
  def self.life=(life)
    @@life = life
  end
  
  def self.speed=(speed)
    @@speed = speed
  end
          
  def initialize
    @alive = false
	end
	
	def fire_from(player)
    @alive = true
    @player = player        
    @rotation = @player.rotation
    @velocity = calculate_velocity(@rotation, @@speed)
        
    length = Math.sqrt(@velocity.x * @velocity.x + @velocity.y * @velocity.y)		
		direction = Vector.new(@velocity.x / length, @velocity.y / length)
		@position = Vector.new(@player.position.x + direction.x*32, @player.position.y + direction.y*32)
		
		@sprite = Sprite.new("bullet", -1)		
		@begin_time = Gosu::milliseconds
	end
  
  def update(frame_time)
		if Gosu::milliseconds - @begin_time < (@@life * 100)
			update_position(frame_time)			
			
			#@alive = false if @window.shot_hit_someone?(@source_player, @position)
		else
			@alive = false
		end
	end
	
	def draw
		@sprite.draw(@position, @rotation) if @alive
	end
	
	private
	
	def update_position(frame_time)		
		@position.x += frame_step(@velocity.x, frame_time)
		@position.y += frame_step(@velocity.y, frame_time)
				
		#@position.y = 800 if @position.y < 0
		#@position.y = 0 if @position.y > 800
		#@position.x = 1280 if @position.x < 0
		#@position.x = 0 if @position.x > 1280		
	end	
end

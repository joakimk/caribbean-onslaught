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
require File.dirname(__FILE__)  + '/status_bar.rb'

class Character      
  include GameObject
         
  attr_accessor :position, :rotation, :width, :height, :alive
  
  def initialize(sprite_base_name)
    @window = Game.window
    @animation_speed = 100
    @sprite_up = Sprite.new("#{sprite_base_name}_back", @animation_speed)
    @sprite_down = Sprite.new("#{sprite_base_name}_front", @animation_speed)
    @sprite_right = Sprite.new("#{sprite_base_name}_right", @animation_speed)
    @sprite_left = Sprite.new("#{sprite_base_name}_left", @animation_speed)
    @sprite_death = Sprite.new("#{sprite_base_name}_death", @animation_speed, true)
    @hp_bar = StatusBar.new
    
    @width = @sprite_up.width
    @height = @sprite_up.height
    
    # State
    @moving = false
    @alive = true
    @rotation = 90
    @max_speed = 120*2
    @speed = 0
    @acceleration = @max_speed * 2
    @position = Vector.new(0, 0)
    @velocity = Vector.new(0, 0)
    @max_hp = 100
    @hp = @max_hp    
    @hit_animations = []
  end
  
  def warp(position)
    @position = position
  end
  
  def draw    
    draw_hp_bar
  end
  
  def shot_hit(shot)
    @window.add_decal(Sprite.new('blood_splash', 125, true), @position)
  end
    
  def update(frame_time)  
    calculate_speed(frame_time)
    @velocity = calculate_velocity(@rotation, @speed)
    update_position(frame_time)     
    update_animation_speed       
    
    #@hit_animations.each do |sprite|
    #  @hit_animations.delete(sprite) if sprite.done
    #end
  end
  
  private
  
	def draw_hp_bar
		hp = (@hp.to_f/@max_hp)
		color = create_color((255 * (1 - hp)).to_i, (255 * hp).to_i, 0)
		@hp_bar.draw(@position, 32 + 6, hp, color)
	end		  
  
  def calculate_speed(frame_time)
    if @moving
      if @speed < @max_speed
        @speed += frame_step(@acceleration, frame_time)
      else
        @speed = @max_speed
      end              
    else
      if @speed > 0        
        @speed -= frame_step(@acceleration * 2, frame_time)
      else
        @speed = 0 
      end
    end                      
  end  
  
  def update_position(frame_time)    
		y = @position.y + frame_step(@velocity.y, frame_time)
	  x = @position.x + frame_step(@velocity.x, frame_time)
		  				  
		if within_screen(x, y) && valid_position?(x, y)
		  @position.x, @position.y = x, y		  
		end
  end  
  
  def valid_position?(x, y)
    height = @sprite_up.height
    width = @sprite_up.width
    
    @window.valid_position?(self, x, y, width, height)
  end
  
  def within_screen(x, y)
    y > @window.camera_position + 50 && y < (@window.camera_position + 800 - 50)
  end
    
  def update_animation_speed
    sprite.animation_speed = (@speed / @max_speed.to_f)  
  end  
  
  def sprite
    case @rotation
      when 0:
        @sprite_up
      when 90:
        @sprite_right
      when 180:
        @sprite_down
      when 270:
        @sprite_left
    end              
  end  
  
	def create_color(r, g, b)
		Gosu::Color.new(255, r, g, b)
	end    
end

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

require File.dirname(__FILE__)  + '/character.rb'

class Player < Character   
  attr_reader :name, :dead_and_animation_complete
   
  def initialize(input, name, character)
    super("pirate_#{character}")
    
    @dead_and_animation_complete = false
    @name = name
    @input = input
    @last_fire_time = 0
    @last_hit_anim_time = 0
    @last_time_score_time = 0
  end
    
  def draw
    sprite.draw(@position, 0) if @alive
    super
  end
    
  def update(frame_time)
    read_input(frame_time)  
    
    if !@alive && @sprite_death.done  
      @dead_and_animation_complete = true
    end
    
    if Gosu::milliseconds - @last_time_score_time > 1000
      @last_time_score_time = Gosu::milliseconds
      @window.add_score_for(self, 1) if @alive
    end
    
    super(frame_time)
  end
  
  def zombie_is_close(zombie, frame_time)   
    if @alive
      @hp -= frame_step(33, frame_time)
      if Gosu::milliseconds - @last_hit_anim_time > 1000
        @last_hit_anim_time = Gosu::milliseconds
        @window.add_decal(Sprite.new('blood_splash', 125, true), @position)
        zombie.animate_attack
      end
        
      if @hp <= 0
        @hp = 0
        @alive = false
        @sprite_death.reset    
        @window.notify_palyer_dead
        @window.add_decal(@sprite_death, @position)            
      end
    end
  end
  
  private
     
  def read_input(frame_time)    
    @moving = true
    
    if @input.up?
      @rotation = 0      
    elsif @input.right?
      @rotation = 90
    elsif @input.down?
      @rotation = 180
    elsif @input.left?
      @rotation = 270
    else    
      @moving = false  
    end
    
    if @input.fire?      
      if Gosu::milliseconds - @last_fire_time > (@window.fire_delay * 1000)      
        @last_fire_time = Gosu::milliseconds
        @window.fire_shot(self)
      end
    end
  end
end
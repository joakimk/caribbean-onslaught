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

class Zombie < Character    
  def initialize
    value = rand
    if rand < 0.65
      @type = :easy
      super("zombie_01")
    elsif rand < 0.85
      @type = :medium
      super("zombie_02")    
    else
      @type = :hard
      super("zombie_03")    
    end          
    
    @shift = 128
    
    @moving = false


    if @type == :easy    
      @max_speed = @max_speed / 3
    elsif @type == :medium    
      @max_hp = @max_hp * 1.5
      @hp = @max_hp
      @max_speed = @max_speed / 2.5
    else
      @max_hp = @max_hp * 2
      @hp = @max_hp
      @max_speed = @max_speed / 2      
    end
    
    @last_direction_change_time = 0
    
    @attack_right = Sprite.new('zombie_attack_right', 250, true)
    @attack_left = Sprite.new('zombie_attack_left', 250, true)
    @attack_up = Sprite.new('zombie_attack_back', 250, true)
    @attack_down = Sprite.new('zombie_attack_front', 250, true)
  end
    
  def draw       
    sprite.draw(@position, 0) if @alive        
    super
    
    # lack of time :)
    case @rotation
      when 0:
        @attack_up.draw(@position, 0) unless @attack_up.done
      when 90:
        @attack_right.draw(@position, 0) unless @attack_right.done
      when 180:
        @attack_down.draw(@position, 0) unless @attack_down.done
      when 270:
        @attack_left.draw(@position, 0) unless @attack_left.done
    end          
  end
    
  def animate_attack
    @attack_right.reset
    @attack_left.reset
    @attack_up.reset
    @attack_down.reset
  end
    
  def update(frame_time)   
    super(frame_time)
            
    if Gosu::milliseconds - @last_direction_change_time > 500
      @last_direction_change_time = Gosu::milliseconds
      
      # "AI"
      player, distance = @window.closest_player(@position)
      target = player.position
      
      if distance > 550
        @moving = false
      else
        @moving = true
      end
                  
      angle = Gosu::angle(@position.x, @position.y, target.x, target.y)
      angle += 360 if angle < 0
      
      case angle
        when 45...135:
          @rotation = 90
        when 136...225:
          @rotation = 180
        when 226...316:
          @rotation = 270
        when 317...360:
          @rotation = 0
        when 0...44:
          @rotation = 0
      end      
    end
  end
    
  def shot_hit(shot)
    super(shot)
    @hp -= 25
    
    if @hp <= 0
      @hp = 0
      @alive = false
      @sprite_death.reset 
      @window.add_decal(@sprite_death, @position)
      @window.play_splat
      @window.notify_zombie_dead(self)
      
      if @type == :easy                   
        @window.add_score_for(shot.player, 10)      
      elsif @type == :medium
        @window.add_score_for(shot.player, 20)
      else
        @window.add_score_for(shot.player, 40)
      end
    end
  end
end

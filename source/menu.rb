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

require File.dirname(__FILE__)  + '/input/gamepad_input.rb'
require File.dirname(__FILE__)  + '/input/keyboard_0_input.rb'
require File.dirname(__FILE__)  + '/input/keyboard_1_input.rb'

class Menu
  def initialize(button_pressed = false)
    @window = Game.window
    @scale = @window.scale
    @menu_selection = 0   
    @menu_inputs = [ GamePadInput.new, Keyboard0Input.new, Keyboard1Input.new ]
    @button_pressed = button_pressed

    @menu = Gosu::Image.new(@window, "../data/caribbean_onslaught_splash.png", true)
    @menu_sword = Sprite.new('swordmarker', -1)   
  end
  
  def draw
    @menu.draw(0, 0, 0, @scale, @scale)
    @menu_sword.draw(Vector.new(160, 430 + @menu_selection * 72), 0)
  end
  
  def update
    unless @button_pressed      
      @menu_inputs.each do |input|
        if input.up?
          if @menu_selection == 0
            @menu_selection = 3
          else
            @menu_selection -= 1
          end            
          @button_pressed = true
          break
        elsif input.down?
          if @menu_selection == 3
            @menu_selection = 0
          else 
            @menu_selection += 1
          end
          @button_pressed = true
          break
        elsif input.fire? || @window.button_down?(Gosu::Button::KbReturn)
          if @menu_selection <= 2          
            @window.start_game(@menu_selection + 1)
          else
            @window.close
          end
          
          @button_pressed = true            
          break
        end                                    
      end    
    end      
  end
  
  def button_released
    @button_pressed = false
  end  
end
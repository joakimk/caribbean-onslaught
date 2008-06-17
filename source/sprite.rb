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

class Sprite
  attr_accessor :animation_speed, :height, :width, :done
  
	def initialize(base_name, animation_delay = -1, only_once = false)
		@window = Game.window
		@scale = @window.scale		
		@animation_delay = animation_delay
		@animation_speed = 1.0
		@images = load_images(base_name)				
		@last_index = 0
		@last_image_time = Gosu::milliseconds
		@height = @images.first.height
		@width = @images.first.width
		@only_once = only_once
		@done = false
	end
	
	def draw(position, rotation)	  	  	  
		if @done || @animation_delay == -1 || @animation_speed == 0
			image = @images[@last_index]
		else
		  delay = @animation_delay / @animation_speed
			if Gosu::milliseconds - @last_image_time > delay
				@last_image_time = Gosu::milliseconds
				@last_index += 1
				
				if @last_index == @images.size
				  if @only_once
				    @done = true
				    @last_index -= 1
				  else
					  @last_index = 0
					end
				end
			end
			
			image = @images[@last_index]								
		end
		
		image.draw_rot(position.x.to_i * @scale, (position.y.to_i - @window.camera_position) * @scale,
									 0, rotation, 0.5, 0.5, @scale, @scale)
	end
  
  def reset
    @done = false
		@last_index = 0
		@last_image_time = Gosu::milliseconds       
  end  
  
	private
	
	def load_images(base_name)
		images = []
		Dir.foreach("data/sprites") do |file|
			if file.include?(base_name)
				images << Gosu::Image.new(@window, "data/sprites/#{file}", true)
			end
		end		
				
		# Character animation 3 + repeat (could be improved)
		if images.length == 3 && base_name != "blood_splash" # Hack... :(
		  images << images[1] 
		end
		
		images
	end
end

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

class FrameCounter
	def initialize(text_renderer)
		@text_renderer = text_renderer
		@last_check = Gosu::milliseconds
		@frames = 0
	end
	
	def draw
		@frames += 1
		if Gosu::milliseconds - @last_check > 500									
			@fps = @frames * 2
			@frames = 0
			@last_check = Gosu::milliseconds
		end
		
		@text_renderer.draw("FPS: #{@fps}", 10, 760, 0xffffffff)
	end
end

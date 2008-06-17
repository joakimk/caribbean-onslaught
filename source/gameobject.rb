# Copyright (c) 2008 Joakim Kolsj�, Anders Asplund and Johan Larsson
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

require File.dirname(__FILE__)  + '/vector.rb'

module GameObject
	def calculate_velocity(rotation, speed)
		radians = (rotation * Math::PI / 180)
		velocity = Vector.new(speed * Math.sin(radians),
		                        -(speed * Math.cos(radians)))
		velocity
	end  
	
	def frame_step(value, frame_time)
		(value / 25.0) * (frame_time / 40.0)
	end	
end
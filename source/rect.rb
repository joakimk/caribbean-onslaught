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

require File.dirname(__FILE__)  + '/vector.rb'

class Rect
  attr_accessor :x0, :y0, :x1, :y1
  
  def initialize(x0, y0, x1, y1)
    @x0, @y0, @x1, @y1 = x0, y0, x1, y1
  end

  def in_area?(position)
    position.x > @x0 && position.x < @x1 && position.y > @y0 && position.y < @y1
  end
  
  def random_position
    x = @x0 + (@x1 - @x0) * rand
    y = @y0 + (@y1 - @y0) * rand
    Vector.new(x.to_i, y.to_i)
  end
end

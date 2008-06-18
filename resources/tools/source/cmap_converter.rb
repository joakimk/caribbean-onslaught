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

class CmapConverter  
  def convert(source, target)
    @collision_map = Magick::Image.read(source).first
    w = @collision_map.columns.to_f       
    h = @collision_map.rows
    
    puts "Converting #{source} into #{target}"
    
    last_position = -1
        
    out = File.new(target, 'w')
    0.upto(w-1) do |x|
      0.upto(h-1) do |y|
        out.print @collision_map.pixel_color(x, y).red == 0 ? '0' : '1'        
      end
      out.puts
      
      position = ((x / w) * 100).to_i
      if position != last_position
        last_position = position
        print "#{position}% "
        STDOUT.flush
      end
    end
    out.close
    
    puts "Done."
  end    
end

CmapConverter.new.convert("../../graphics/pirateship_level_col.png",
                          "../../../data/pirateship_level.cmap")

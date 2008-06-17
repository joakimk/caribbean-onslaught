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

require File.dirname(__FILE__)  + '/text_renderer.rb'

class Score
	attr_accessor :scores
	
	def initialize(text_renderer, size)
		@text_renderer = text_renderer
				
		@scores = []						 
		0.upto(size - 1) do |i|
			@scores[i] = 0
		end
	end
	
	def draw(players, x = 0, y = 0, winner = nil)
	  draw_text("Game over!", x + 10, y - 64) if winner
	  
		draw_text("Score:", x + 10, y)
		players.each_with_index do |p, i|
			draw_text("#{p.name}", x + 10 + 50, y + 32 + 30 * i)
			draw_text("#{@scores[i]}", x + 128 + 50, y + 32 + 30 * i)
		end	 

		if winner
		  sorted = players.sort do |a, b|
		    @scores[players.index(a)] <=> @scores[players.index(b)]
		  end
		  		  		  
		  draw_text("Winner: #{sorted.reverse.first.name}", x + 10, y + 32 + 30 * (players.size + 1))
		  
		  draw_text("Press any key.", x + 10, y + 32 + 30 * (players.size + 3))		  
		end
	end
	
	private
	
	def draw_text(text, x, y)
		@text_renderer.draw(text, x, y, 0xffffff00)
	end
end

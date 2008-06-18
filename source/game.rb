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

begin
  require 'rubygems'
rescue LoadError
end

require 'gosu'

require File.dirname(__FILE__)  + '/settings.rb'
require File.dirname(__FILE__)  + '/version.rb'
require File.dirname(__FILE__)  + '/player.rb'
require File.dirname(__FILE__)  + '/zombie.rb'
require File.dirname(__FILE__)  + '/menu.rb'
require File.dirname(__FILE__)  + '/level.rb'
require File.dirname(__FILE__)  + '/shot.rb'
require File.dirname(__FILE__)  + '/score.rb'
require File.dirname(__FILE__)  + '/text_renderer.rb'
require File.dirname(__FILE__)  + '/frame_counter.rb'

class Game < Gosu::Window
	attr_reader :scale, :camera_position, :fire_delay
		
  def initialize
    @@instance = self
    @settings = Settings.new('../settings.yml')            
    super(@settings.width, @settings.height, @settings.fullscreen)
    
    self.caption = "Caribbean Onslaught v#{$VERSION}"
      	
    @scale = @settings.height.to_f / 800    
            
    start_menu
    @sound_shot = Gosu::Sample.new(self, '../data/sounds/gun.wav')
    @sound_splat = Gosu::Sample.new(self, '../data/sounds/splat.wav')
    @sound_hit = Gosu::Sample.new(self, '../data/sounds/hit.wav')
  end
  
  def start_score
    @mode = :score
  end
  
  def start_menu(button_pressed = false)
    @camera_position = 0        
    @mode = :menu
    @menu = Menu.new(button_pressed)
  end
  
  def start_game(number_of_players)
    @mode = :loading_game
    
    @text_renderer = TextRenderer.new
    @loading_char = Sprite.new('pirate_jack_front', 150)
    
    Thread.new do
      @old_camera_position = 0
      @camera_moving_to_other_players = false
      @rate = 0
      
      @camera_position = 300            
                 
      @decals = []
                        
      @players = []
      @settings.players.each_with_index do |player, i|
        break if i == number_of_players
        
        @players << Player.new(player[:input].new, player[:name], player[:character])
      end
            
      @level = Level.new            
  		@score = Score.new(@text_renderer, @players.size)
  		@fps = FrameCounter.new(@text_renderer)
      
      @characters = @players
            
      @players.each do |player| 
        player.warp valid_spawn_position_for(player)
      end  
      
      @zombies = []
      20.times do
        zombie = Zombie.new
        @zombies << zombie
        zombie.warp valid_spawn_position_for(zombie, true)
      end

      @characters = @zombies + @players
      
      # Shots
      @fire_delay = 0.2
      Shot.life = 7
      Shot.speed = 500
      number_of_shots = ((Shot.life / @fire_delay) * @players.size).to_i
      
      @shot_buffer = []
      number_of_shots.times do
        @shot_buffer << Shot.new
      end
              
      @active_shots = []    
    
      @last_frame = Gosu::milliseconds      
          
      @mode = :game   
    end        
  end
    
  def draw		
    if @mode == :menu
      @menu.draw
    elsif @mode == :loading_game          
      @text_renderer.draw('Loading game...', 550, 400, 0xffffffff)
      @loading_char.draw(Vector.new(660, 800), 0)
    elsif @mode == :score
      @score.draw(@players, 525, 350, true)
    elsif @mode == :game                		
  		@level.draw
  		@fps.draw
  		@score.draw(@players)		
  		  				 
      @decals.each { |decal| decal[:sprite].draw(decal[:position], 0) }  		  				 
  		  				  		
  		@characters.sort! { |first, second|
  		    if !first.alive
  		      if !second.alive
  		        first.position.y <=> second.position.y  
  		      else
  		        -1
  		      end
  		    elsif !second.alive
  		      1
  		    else
  		      first.position.y <=> second.position.y
  		    end
  		}
  		
  		@characters.each { |caracter| caracter.draw }		
  				
  		@active_shots.each { |shot| shot.draw }
  		
  		@level.draw_overlay
  	end
  end
         
  def update
    if @mode == :menu
      @menu.update      
    elsif @mode == :game
    	frame_time = (Gosu::milliseconds - @last_frame)
    	@last_frame = Gosu::milliseconds
    	  	  	
    	update_players(frame_time)
    	update_zombies(frame_time)
    	update_shots(frame_time)
    	update_zombiehits(frame_time)
    	
    	someone_alive = false
    	@players.each do |player|
    	  if player.alive
    	    someone_alive = true
    	    break
    	  end
    	end
    	
    	unless someone_alive
    	  start_score 
    	else
    	  @camera_position = calc_camera_position(frame_time)
        pan_camera_when_a_player_dies(frame_time)     
    	end
    end
    
  	close if button_down? Gosu::Button::KbEscape
  end
  
	def frame_step(value, frame_time) #TEMP
		(value / 25.0) * (frame_time / 40.0)
	end	    
    
  def button_up(id)
    @menu.button_released if @mode == :menu
  end    
    
  def button_down(id)
    start_menu(true) if @mode == :score    
#    self.caption = id.to_s
  end

  def fire_shot(player)
    shot = @shot_buffer.first
    if shot == nil
      puts 'ERROR: ran out of shots :)'
    else      
      @sound_shot.play(0.5, 2)
      shot.fire_from(player)
      @shot_buffer.delete(shot)
      @active_shots << shot
    end
  end
  
  def add_decal(sprite, position)
    @decals << { :sprite => sprite, :position => position.clone }
    if @decals.size > 50
      @decals.delete_at(0)
    end
  end
  
  def add_score_for(player, score)
    index = @players.index(player)    
    @score.scores[index] += score
  end
    
  def valid_position?(source_caracter, x, y, width = nil, height = nil)
    @characters.each do |character|
      unless character === source_caracter
        next unless character.alive
        
        if Gosu::distance(x, y,
                  character.position.x, character.position.y) < 25
          return false
        end
      end
    end
    
    width, height = source_caracter.width, source_caracter.height
    
    0.upto(width) do |xx|
      return false unless @level.valid_position?(x + xx - (width / 2),
                                                 y + (height / 2))
    end
    
    true    
  end
  
  def valid_spawn_position_for(character, monster = false)
    while true
      new_pos = @level.generate_spawn_position(monster)
      if valid_position?(character, new_pos.x, new_pos.y)
        return new_pos
      end
    end      
  end  
  
  def closest_player(position)
    min = 10000
    temp = nil
    @players.each do |player|
      next unless player.alive
      
#      dist = distance(player.position, position)
      dist = Math.sqrt(((player.position.x - position.x)*(player.position.x - position.x)) + ((player.position.y - position.y)*(player.position.y - position.y)))
      if dist < min
        min = dist 
        temp = player
      end
    end
    
    return temp, min
  end
    
	def self.window
	  @@instance
	end  
	
	def notify_palyer_dead
    unless @camera_moving_to_other_players
      @camera_moving_to_other_players = true
    end
  end
  
  def notify_zombie_dead(zombie)
    @zombies.delete(zombie)    
    new_zombie = Zombie.new
        
    while true
      valid_pos = valid_spawn_position_for(new_zombie, true)
      player, distance = closest_player(valid_pos)
      
      if distance > 500
        new_zombie.warp valid_pos
        #add_decal(Sprite.new('summon', 250, true), new_zombie.position)
        break
      end            
    end
    
    @zombies << new_zombie    
    @characters = @zombies + @players
  end

  def play_splat
    @sound_splat.play(1, 2)
  end	
  
  def play_hit
    @sound_hit.play(0.25, 2)
  end
	
  private

  def update_players(frame_time)
    @players.each do |player|
      player.update(frame_time)
    end
  end
  
  def update_zombies(frame_time)
  	@zombies.each do |zombie|
  	  zombie.update(frame_time)
  	end    
  end
     
  def update_shots(frame_time)
  	@active_shots.each do |shot|
  	  shot.update(frame_time)
  	     	     	    	    	    	  
  	  if shot.alive
  	    @characters.each do |character|
  	      position = character.position
  	      distance = Gosu::distance(shot.position.x, shot.position.y, position.x, position.y)
  	      if distance < 25
  	        if character.alive
  	          character.shot_hit(shot) 
  	          play_hit
  	          deactivate(shot)    
  	        end
  	      end
  	    end   	    
  	  else
  	    deactivate(shot)
  	  end
  	end    
  end     
  
  def update_zombiehits(frame_time)
    @zombies.each do |zombie|
      next unless zombie.alive
      
      @players.each do |player|
        dist = Gosu::distance(zombie.position.x, zombie.position.y, player.position.x, player.position.y)
        if dist < 65
          player.zombie_is_close(zombie, frame_time)
        end
      end
    end        
  end
  
  def pan_camera_when_a_player_dies(frame_time)
	  unless @camera_moving_to_other_players
	    @old_camera_position = @camera_position 
	    @rate = 0
	  else    	    
	    @rate = frame_step(500, frame_time)
	    d = interpolation_direction
	    @old_camera_position += d * @rate    	        	   
	    
	    @old_camera_position = @camera_position if d != interpolation_direction
	    
	    dist = (@camera_position - @old_camera_position).abs
	    @camera_moving_to_other_players = false if dist < 5
	        	    
	    @camera_position = @old_camera_position        
	  end
  end
  
  def interpolation_direction
    @old_camera_position > @camera_position ? -1 : 1
  end
        
  def deactivate(shot)
    @active_shots.delete(shot)  	      	    
    @shot_buffer << shot    
  end
            
  def calc_camera_position(frame_time)
  	cords = []
  	@players.each do |player|
  		cords << player.position.y if player.alive #dead_and_animation_complete
  	end
              	  	  	  	  	  	  	  	  	
  	((cords.max + cords.min) / 2.0).to_i - 400
  end
  
  def distance(p0, p1)
    Gosu::distance(p0.x, p0.y, p1.x, p1.y)
  end  
end

Game.new.show

@echo off
cd bin
ruby ../source/register_game_path.rb > register_game_path.reg
regedit /S register_game_path.reg
del register_game_path.reg
ruby ../source/game.rb

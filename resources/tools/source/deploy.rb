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

require 'time'
require 'find'

class Deploy
  def self.delete_svn(path)
    Find.find(path) do |path|
      if path.include? ".svn"
        FileUtils.rm_rf(path)
      end
    end
  end
  
  def self.do_commands(commands)
    system(commands.join(';'))
  end
  
  def self.run  
    base_name = "CaribbeanOnslaught"
    name = "#{base_name}_#{Time.now.strftime('%Y-%m-%d_%H%S')}"
    
    copy_and_clean_resources = [
      'cd ../..',
      "mkdir -p ../Release/#{name}",
      "cp -rf * ../Release/#{name}",
      "cd ../Release",
      "rm -rf #{name}/resources",
      "rm -rf #{name}/.eprj"
    ]
        
    add_default_settings = [
      "cd ../../../Release",
      "mv #{name}/settings.yml.example #{name}/settings.yml"
    ]
  
    create_archive = [
      "cd ../../../Release",
      "tar cfz #{name}.tar.gz #{name}",
      "rm -rf #{name}"
    ]  
    
    do_commands copy_and_clean_resources
    do_commands add_default_settings  
    delete_svn("../../../Release/#{name}")
    do_commands create_archive
  
    do_commands [ "wc -c ../../../Release/#{name}.tar.gz"]
  end
end

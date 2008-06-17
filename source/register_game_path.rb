game_dir = Dir.pwd.gsub(/\//, '\\\\\\\\')

out = <<REG_TEMPLATE
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\\SOFTWARE\\ImageMagick]

[HKEY_LOCAL_MACHINE\\SOFTWARE\\ImageMagick\\6.4.1]

[HKEY_LOCAL_MACHINE\\SOFTWARE\\ImageMagick\\6.4.1\\Q:8]
"ConfigurePath"="#{game_dir}"
"LibPath"="#{game_dir}"
"CoderModulesPath"="#{game_dir}"
REG_TEMPLATE

puts out

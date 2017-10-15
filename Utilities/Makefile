


all: docs fk_lib.lua

docs: 
	@cat 0_project.lua event_management.lua humidity_temperature.lua lighting.lua sourcetriggers.lua timers.lua time.lua  utils.lua weatherinfo.lua > ../lib/bhall.lua
	@ldoc ../lib/bhall.lua -d ../Docs/
	@rm ../lib/bhall.lua

fk_lib.lua: 0_project.lua event_management.lua time.lua humidity_temperature.lua lighting.lua sourcetriggers.lua timers.lua utils.lua weatherinfo.lua clearlib
	@echo "Compressing files into the fk_lib.lua single file library"
	@cat 0_project.lua event_management.lua  humidity_temperature.lua lighting.lua sourcetriggers.lua timers.lua time.lua utils.lua weatherinfo.lua |perl -nae 's/--.*\n//;s/\n//;s/^end;/end;/;s/[\t ]+/ /;g;s/function /\nfunction /g;s/(zwavemeSceneTableVerbose|zwavemeSceneTable|nodonSceneTableVerbose|nodonSceneTable)/\n$$1/g;print' > ../lib/fk_lib.lua

clearlib:
	@echo "Removing old version of compressed library file"
	@rm -f ../lib/fk_lib.lua

test:
	@echo "Running all test cases using Lua Testy"
	@testy.lua *.lua

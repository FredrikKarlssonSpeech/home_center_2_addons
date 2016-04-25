


all: docs fk_lib.lua

docs:

fk_lib.lua: datetime.lua sourcetriggers.lua clearlib
	@echo "Compressing (datetime|sourcetriggers|utils).lua files into the fk_lib.lua single file"
	@cat datetime.lua sourcetriggers.lua utils.lua|perl -nae 's/--.*\n//;s/\n//;s/^end;/end;/;s/[\t ]+/ /;g;s/function /\nfunction /g;s/(zwavemeSceneTableVerbose|zwavemeSceneTable|nodonSceneTableVerbose|nodonSceneTable)/\n$$1/g;print' > ../lib/fk_lib.lua

clearlib:
	@echo "Removing old version of compressed library file"
	@rm -f ../lib/fk_lib.lua

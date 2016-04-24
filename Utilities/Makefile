


all: docs fk_lib.lua

docs:

fk_lib.lua: datetime.lua sourcetriggers.lua
	@echo "Compressing (datetime|sourcetriggers).lua files into the fk_lib.lua single file"
	@cat datetime.lua sourcetriggers.lua |perl -nae 's/--.*\n//;s/\n//;s/^end;/end;/;s/[\t ]+/ /;g;s/function /\nfunction /g;s/(zwavemeSceneTableVerbose|zwavemeSceneTable|nodonSceneTableVerbose|nodonSceneTable)/\n$1/g;print' > fk_lib.lua

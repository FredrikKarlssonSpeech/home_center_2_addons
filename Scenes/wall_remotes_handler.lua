--[[
%% properties
396 sceneActivation
%% events
%% globals
--]]

-- LIBRARY
nodonSceneTableVerbose = {
    [10]="Button 1 Single Press",
    [20]="Button 2 Single Press",
    [30]="Button 3 Single Press",
    [40]="Button 4 Single Press",
    [13]="Button 1 Double Press",
    [23]="Button 2 Double Press",
    [33]="Button 3 Double Press",
    [43]="Button 4 Double Press",
    [12]="Button 1 Hold Press",
    [22]="Button 2 Hold Press",
    [32]="Button 3 Hold Press",
    [42]="Button 4 Hold Press",
    [11]="Button 1 Hold Released",
    [21]="Button 2 Hold Released",
    [31]="Button 3 Hold Released",
    [41]="Button 4 Hold Released"
};

function buttonPressed(id,descriptionstring,descriptiontable)
  local dtab = descriptiontable or nodonSceneTableVerbose;
  local inDesc = tostring(descriptionstring) ;
  local scene = tonumber(fibaro:getValue(id, "sceneActivation"));
  local desc = tostring(dtab[scene]);
  return(inDesc == desc);
end;

function runIf(shouldRun, toRun, sleepSeconds )
  local delay = sleepSeconds or 0;
  if (type(toRun) == "function" and shouldRun ) then
    toRun();
  elseif ( type(toRun) == "table"  and shouldRun ) then
    for k,v in pairs(toRun) do
        v = tonumber(v);
        if ( fibaro:isSceneEnabled(v)) then
          fibaro:startScene(v);
        else
          fibaro:debug("Not running disabled scene ID:".. tostring(k));
        end;
    end;
  end;
  fibaro:sleep(delay*1000);
end;

--- SETUP AND RUN

function toggleAC()
  local acOn = tonumber(fibaro:getValue(369, "value"));
  if(acOn == 1) then
    fibaro:startScene(64) -- run turn AC off scene
  else
    fibaro:startScene(63) -- run turn AC on head 25 scene
  end;
end;

local deviceId = 396

local windowsOffScene = 98;
local windowsOnScene = 99;
local externalOnScene = 81;
local externalOffScene = 82;
local houseOFF = 100;
local fasadOff = {windowsOffScene, externalOffScene};
local fasadOn = {windowsOnScene, externalOnScene};

--fibaro:debug("Got scene activation ".. fibaro:getValue(deviceId, "sceneActivation"))

runIf(buttonPressed(deviceId,"Button 2 Single Press",nodonSceneTableVerbose),fasadOn,0);
runIf(buttonPressed(deviceId,"Button 4 Single Press",nodonSceneTableVerbose),fasadOff,0);
runIf(buttonPressed(deviceId,"Button 4 Double Press",nodonSceneTableVerbose),houseOFF,0);
runIf(buttonPressed(deviceId,"Button 2 Double Press",nodonSceneTableVerbose),toggleAC,0);

-- fibaro:debug("Passed scene activation handlers")

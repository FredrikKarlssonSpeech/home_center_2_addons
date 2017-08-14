--[[
%% properties
553 sceneActivation
%% events
%% globals
--]]



local keyId = tonumber(fibaro:getValue(553, "sceneActivation"));
-- truncate to make all kinds of presses similar
-- This way of doing truncation makes it easy to change the code later though
keyId = math.floor(keyId / 10) * 10;
-- some scene id:s
local windowsOffScene = 98;
local windowsOnScene = 99;
local externalOnScene = 81;
local externalOffScene = 82;
local heater = 193;

-- Now start processing keys
if (keyId == 10 ) then
  fibaro:debug("Button 1 clicked");
  fibaro:call(heater,"turnOn")
elseif (keyId == 20 ) then
  fibaro:debug("Button 2 clicked");
  fibaro:startScene(windowsOnScene);
elseif (keyId == 30 ) then
  fibaro:debug("Button 3 clicked");
  fibaro:call(heater,"turnOff")
elseif (keyId == 40 ) then
  fibaro:debug("Button 4 clicked");
  fibaro:startScene(windowsOnScene);
end;

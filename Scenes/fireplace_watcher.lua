--[[
%% properties
269 value
82 value
%% events
%% globals
--]]

if (fibaro:countScenes() > 1) then
  fibaro:abort();
end

local fireplaceTemp = tonumber(fibaro:getValue(269, "value"));
local roomTemp = tonumber(fibaro:getValue(82, "value"));
local tempDiff = fireplaceTemp - roomTemp;

fibaro:debug("Fireplace temp is ".. fireplaceTemp .. "°C degrees and room temperature is ".. roomTemp.. "°C, so the temperature difference is ".. tempDiff.. "°C.")

if (tempDiff >= 4 ) then
    fibaro:setGlobal("Fireplace", "Fire");
else 
    fibaro:setGlobal("Fireplace", "No fire");
end;

fibaro:sleep(10*60*1000);

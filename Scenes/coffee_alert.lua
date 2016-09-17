--[[
%% properties
281 power
%% events
%% globals
--]]

-- ska uppdateras
-- Varabelns nivåer
-- On
-- Making coffee
-- Rinsing
-- Off


if (fibaro:countScenes() > 1) then
  fibaro:abort();
end

local consumption = tonumber(fibaro:getValue(281, "power"));
local prev = tostring(fibaro:getGlobal("Coffe_mashine"));
local lastModified =  fibaro:getGlobalModificationTime("Coffe_mashine");
local timeElapsedMinutes = (os.time() - lastModified) /60;
  
fibaro:debug("Coffe mashine current consumption is "..consumption.. "W");

-- Check state by current power consumption and adjust variable according to logic
if (consumption > 700 and prev == "Off" ) then
  -- we have seen the startup sequence
  fibaro:setGlobal("Coffe_mashine", "On");
elseif (consumption > 700 and (prev == "On"  or prev == "Making coffee") ) then
  -- here we are making coffee
  fibaro:setGlobal("Coffe_mashine", "Making coffee");
elseif (consumption < 700 and consumption > 100 and (prev == "On"  or prev == "Making coffee")) then
    -- here we are rinsing the system
    fibaro:setGlobal("Coffe_mashine", "Rinsing");
elseif (consumption < 100 and (prev == "Rinsing" or timeElapsedMinutes > 60)) then
    -- here we are seeing low power consumption
    -- if this is preceeded by "rinsing", then we can conclude that the machine is off
    -- if there has been a long delay since last state change, then the machine is off
    -- * maybe due to manually turning it off, 
    -- * or just an off and on, which does not trigger rinsing.
    fibaro:setGlobal("Coffe_mashine", "Off");
end;
-- Check every 30 seconds

fibaro:sleep(30*1000);

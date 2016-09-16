--[[
%% properties
279 power
%% events
%% globals
--]]

if (fibaro:countScenes() > 1) then
  fibaro:abort();
end

local consumption = tonumber(fibaro:getValue(279, "power"));
local prev = tostring(fibaro:getGlobal("Washing"));
  
fibaro:debug("Current consumption is"..consumption.. "W");

-- Check state by current power consumption
if (consumption < 50 ) then
  fibaro:setGlobal("Washing", "Not running");
else
  fibaro:setGlobal("Washing", "Running");
end;
-- Check every 10 minutes
fibaro:sleep(5*60*1000);
local curr = tostring(fibaro:getGlobal("Washing"));
-- Check whether the state has changed!
-- If it has, then do something about is, depending on the nature of the change!
-- This provides a nice separation of logic. Could have easilly gone into the prev if clause.
if ( curr ~= prev) then
    if prev == "Running" then
        -- In this case, the washing was running, but is not any more
        fibaro:debug("Washing done!");
    else
        fibaro:debug("Washing started...");
    end;
end;


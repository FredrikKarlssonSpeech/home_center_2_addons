--[[
%% properties
279 power
%% events
%% globals
--]]

if (fibaro:countScenes() > 1) then
  fibaro:abort();
end;

local consumption = tonumber(fibaro:getValue(279, "power"));
local prev = tostring(fibaro:getGlobal("Dishwasher"));
  
fibaro:debug("Dishwasher current consumption is"..consumption.. "W");

-- Check state by current power consumption
if (consumption < 50 ) then
  fibaro:setGlobal("Dishwasher", "Not running");
else
  fibaro:setGlobal("Dishwasher", "Running");
end;
-- Check every 10 minutes
fibaro:sleep(5*60*1000);
local curr = tostring(fibaro:getGlobal("Dishwasher"));
-- Check whether the state has changed!
-- If it has, then do something about is, depending on the nature of the change!
-- This provides a nice separation of logic. Could have easilly gone into the prev if clause.
if ( curr ~= prev) then
    if prev == "Running" then
        -- In this case, the washing was running, but is not any more
        fibaro:debug("Dishwasher done!");
    else
        fibaro:debug("Dishwasher started...");
    end;
end;

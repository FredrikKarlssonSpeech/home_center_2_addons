--[[
%% properties
%% events
%% globals
--]]


-- stop homeplugs in order.

-- First, the router
fibaro:call(328, "turnOff")
-- Second, the TV upstairs
fibaro:call(249, "turnOff")
-- Third, the TV downstairs
--fibaro:call(436, "turnOff")
-- Fifth, the NAS 
fibaro:call(441, "turnOff")
-- Wait for 15 seconds
fibaro:sleep(15*1000);

-- restart homeplugs in order

-- First, the router
fibaro:call(328, "turnOn")
fibaro:sleep(1000);
-- Second, the TV upstairs
fibaro:call(249, "turnOn")
fibaro:sleep(1000);
-- Third, the TV downstairs
--fibaro:call(436, "turnOn")
fibaro:sleep(1000);
-- Fifth, the NAS 
fibaro:call(441, "turnOn")
fibaro:sleep(1000);

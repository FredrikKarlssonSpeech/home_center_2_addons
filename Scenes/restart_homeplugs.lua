--[[
%% properties
%% events
%% globals
--]]


-- stop homeplugs in order.

-- First, the router

fibaro:debug("Stänger av routerns HomePlug");
fibaro:call(328, "turnOff")
-- Second, the TV upstairs
fibaro:debug("Stänger av HomePlug för TVn uppe");
fibaro:call(249, "turnOff")
-- Third, the TV downstairs
fibaro:debug("Stänger av HomePlug för TVn nere");
fibaro:call(436, "turnOff")
-- Fifth, the NAS
fibaro:debug("Stänger av HomePlug för NAS");
fibaro:call(519, "turnOff")
-- Sixth, Isas TV
fibaro:debug("Stänger av HomePlug för Isas TV");
fibaro:call(292, "turnOff")

-- Wait for 15 seconds
fibaro:sleep(30*1000);

-- restart homeplugs in order

-- First, the router
fibaro:debug("Startar routerns HomePlug");
fibaro:call(328, "turnOn")
fibaro:sleep(1000);
-- Second, the TV upstairs
fibaro:debug("Startar HomePlug för TVn uppe");
fibaro:call(249, "turnOn")
fibaro:sleep(1000);
-- Third, the TV downstairs
fibaro:debug("Startar HomePlug för TVn nere");
fibaro:call(436, "turnOn")
fibaro:sleep(1000);
-- Fifth, the NAS
fibaro:debug("Startar HomePlug för NAS");
fibaro:call(519, "turnOn")
fibaro:sleep(1000);
-- Sixth, Isas TV
fibaro:debug("Startar HomePlug för Isas TV");
fibaro:call(292, "turnOn")

--[[
%% properties
%% events
%% globals
--]]

fibaro:debug("Tänder gårdsbelysningen")
fibaro:call(447, "turnOn")
fibaro:debug("Tänder belysning i uterummet")
fibaro:call(497, "turnOn")

--[[
%% properties
%% events
%% globals
--]]

fibaro:debug("Släcker gårdsbelysningen")
fibaro:call(447, "turnOff")
fibaro:debug("Släcker belysning i uterummet")
fibaro:call(497, "turnOff")

--[[
%% properties
%% events
%% globals
--]]


fibaro:call(268, "turnOff") -- Släck dimmern nere
fibaro:call(407, "turnOff") -- Släck höger vägglampa
fibaro:call(408, "turnOff") -- Släck vänster vägglampa

fibaro:call(214, "turnOff") -- Släck badrummet nere

fibaro:call(314, "turnOff") -- Släck taket tvättstugan nere
fibaro:call(316, "turnOff") -- Släck lilla lampan tvättstugan

fibaro:call(264, "turnOff") -- Släck Alex

fibaro:call(251, "turnOff") -- Släck Vårt sovrum


fibaro:call(57, "turnOff") -- Släck taklampan uppe
fibaro:call(581, "turnOff") -- Släck över soffan
fibaro:call(508, "turnOff") -- Släck trappen

fibaro:call(310, "turnOff") -- Släck Theos sovrum

fibaro:call(306, "turnOff") -- Släck Isas sovrum

fibaro:call(62, "turnOff") -- Släck badrummet uppe

-- Se till att fläkten nere inte är igång också
fibaro:call(494, "turnOff") -- Fläkten i vardagsrummet

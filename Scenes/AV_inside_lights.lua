--[[
%% properties
%% events
%% globals
--]]

-- Vardagsrummet nere
fibaro:call(724, "turnOff") -- Släck dimmern vid soffan nere
fibaro:call(407, "turnOff") -- Släck höger vägglampa
fibaro:call(408, "turnOff") -- Släck vänster vägglampa
fibaro:call(821, "turnOff") -- Släck lampan vid matbordet
-- Se till att fläkten nere inte är igång också
fibaro:call(494, "turnOff") -- Fläkten i vardagsrummet

fibaro:call(619, "turnOff") -- Släck badrummet nere
-- Tvättstugan
fibaro:call(314, "turnOff") -- Släck taket tvättstugan nere
fibaro:call(316, "turnOff") -- Släck lilla lampan tvättstugan

-- Köket
fibaro:call(796, "turnOff") -- köksbordet
fibaro:call(811, "turnOff") -- taklamporna
fibaro:call(816, "turnOff") -- spotar köksbänk
fibaro:call(806, "turnOff") -- spotar öppningen

-- Alex rum
fibaro:call(772, "turnOff") -- Släck Alex

-- Vårt rum
fibaro:call(728, "turnOff") -- Släck Vårt sovrum

fibaro:call(646, "turnOff") -- lilla förrådet


-- VArdagsrummet uppe
fibaro:call(57, "turnOff") -- Släck taklampan uppe
fibaro:call(780, "turnOff") -- Släck över soffan
fibaro:call(508, "turnOff") -- Släck trappen

fibaro:call(593, "turnOff") -- Släck Theos sovrum

fibaro:call(597, "turnOff") -- Släck Isas sovrum

fibaro:call(659, "turnOff") -- Släck badrummet uppe 

fibaro:call(719, "turnOff") -- Belysning i skrivarförrådet

-- Garaget

fibaro:call(28, "turnOff") -- Taklampan
fibaro:call(449, "turnOff") -- arbetsbänken
fibaro:call(451, "turnOff") -- förrådet





--[[
%% autostart
%% properties
%% events
%% globals
--]]



local currentDate = os.date("*t");
local startSource = fibaro:getSourceTrigger();
local setpoint = fibaro:getValue(47, "value")
local temp = fibaro:getValue(48, "value")
if (
(
 ( ((currentDate.wday >= 2 and currentDate.wday <= 6) and string.format("%02d", currentDate.hour) .. ":" .. string.format("%02d", currentDate.min) == "06:00")
 or
 ((currentDate.wday == 2 or currentDate.wday == 3 or currentDate.wday == 4 or currentDate.wday == 5 or currentDate.wday == 6) and string.format("%02d", currentDate.hour) .. ":" .. string.format("%02d", currentDate.min) == "14:30") )
 )
and
-- Setpoint < sensor temperature
temp < setpoint
 or
 startSource["type"] == "other"
)
then
    fibaro:call(49, "setMode", "1");
    fibaro:call(50, "setFanMode", "1");
end




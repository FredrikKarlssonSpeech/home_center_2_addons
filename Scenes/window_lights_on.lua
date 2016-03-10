--[[
%% autostart
%% properties
54 sceneActivation
%% events
%% globals
--]]


local currentDate = os.date("*t");
local startSource = fibaro:getSourceTrigger();
if (
 ( currentDate.wday >= 2 and currentDate.wday <= 6 and (string.format("%02d", currentDate.hour) .. ":" .. string.format("%02d", currentDate.min)) == "06:25" )
or
 ( (currentDate.wday == 1 or currentDate.wday == 7) and (string.format("%02d", currentDate.hour) .. ":" .. string.format("%02d", currentDate.min) ) == "07:00" )
or
 ( os.date("%H:%M", os.time()+30*60) == fibaro:getValue(1, "sunsetHour") )
or
 ( tonumber(fibaro:getValue(54, "sceneActivation")) == 20 )
or (startSource["type"] == "other")
)
then
    fibaro:call(43, "turnOn");
    fibaro:call(21, "setValue", "78");
    fibaro:call(58, "turnOn");
    fibaro:call(24, "setValue", "60");
end
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
  tonumber(fibaro:getValue(54, "sceneActivation")) == 40
 or
 (currentDate.wday >= 2 and currentDate.wday <= 6 and (string.format("%02d", currentDate.hour) .. ":" .. string.format("%02d", currentDate.min) ) == "08:00")
 or
 ((currentDate.wday == 1 or currentDate.wday == 7) and (string.format("%02d", currentDate.hour) .. ":" .. string.format("%02d", currentDate.min)) == "09:00")
or
startSource["type"] == "other"
or
(string.format("%02d", currentDate.hour) .. ":" .. string.format("%02d", currentDate.min) == "23:30")
)
then
    fibaro:call(24, "turnOff");
    fibaro:call(24, "setValue", "1");
    fibaro:call(21, "setValue", "0");
    fibaro:call(56, "turnOff");
    fibaro:call(58, "turnOff");
    fibaro:call(60, "setValue", "0");
    fibaro:call(43, "turnOff");
end


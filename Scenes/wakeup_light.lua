--[[
%% autostart
%% properties
%% events
%% globals
--]]

local currentDate = os.date("*t");
local startSource = fibaro:getSourceTrigger();
local lightDevice = 24;
if (
 (currentDate.wday >= 2 and currentDate.wday <= 6 and (string.format("%02d", currentDate.hour) .. ":" .. string.format("%02d", currentDate.min)) == "06:15")
 or
 (startSource["type"] == "other" )
)
then
    fibaro:call(24, "setValue", "0");
    for setting = 10, 60,10 do
        fibaro:sleep(3*60*1000)
        fibaro:call(24, "setValue", setting);
    end
end

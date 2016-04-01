--[[
%% properties
%% globals
--]]

-- This structure does not work for timers set to 23:59 - 00:01 as the date will then be different possibly from the date gotten from the os.date representation of current time.


local startSource = fibaro:getSourceTrigger();
if (

startSource["type"] == "other"

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
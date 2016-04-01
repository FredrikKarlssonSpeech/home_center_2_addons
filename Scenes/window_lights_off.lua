--[[
%% properties
54 sceneActivation
%% events
%% globals
--]]

-- This structure does not work for timers set to 23:59 - 00:01 as the date will then be different possibly from the date gotten from the os.date representation of current time.

local currentDate = os.date("*t");
local acceptWindow = 2* 60 ; -- 2 minutes. os.difftime returns number of seconds
local sleepAfter = acceptWindow ;

local eveningTriggerTime = currentDate;
eveningTriggerTime["hour"] = 23;
eveningTriggerTime["min"] = 30;
local weekMorningTriggerTime = currentDate;
weekMorningTriggerTime["hour"] = 8;
weekMorningTriggerTime["min"] = 0;
local weekendMorningTriggerTime = currentDate;
weekendMorningTriggerTime["hour"] = 9;
weekendMorningTriggerTime["min"] = 0;

local startSource = fibaro:getSourceTrigger();
if (
  (tonumber(fibaro:getValue(54, "sceneActivation")) == 40)
 or
 (currentDate.wday >= 2 and currentDate.wday <= 6 and (math.abs(os.difftime(os.time(currentDate),os.time(weekMorningTriggerTime) ) ) < acceptWindow ) )
 or
 (currentDate.wday >= 2 and currentDate.wday <= 6 and (math.abs(os.difftime(os.time(currentDate),os.time(weekendMorningTriggerTime) ) ) < acceptWindow))
or
(startSource["type"] == "other")
or
(math.abs(os.difftime(os.time(currentDate),os.time(eveningTriggerTime) ) ) < acceptWindow)
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

fibaro:sleep(sleepAfter);


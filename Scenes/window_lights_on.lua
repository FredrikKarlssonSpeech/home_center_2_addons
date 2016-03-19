--[[
%% properties
54 sceneActivation
%% globals
--]]


local currentDate = os.date("*t");
local acceptWindow = 2* 60 ; -- 2 minutes : os.difftime returns seconds.
local sleepAfter = acceptWindow ;

local weekMorningTriggerTime = currentDate;
weekMorningTriggerTime["hour"] = 6;
weekMorningTriggerTime["min"] = 30;
local weekendMorningTriggerTime = currentDate;
weekendMorningTriggerTime["hour"] = 8;
weekendMorningTriggerTime["min"] = 0;

local startSource = fibaro:getSourceTrigger();
if (
  (tonumber(fibaro:getValue(54, "sceneActivation")) == 20)
 or
 (currentDate.wday >= 2 and currentDate.wday <= 6 and (math.abs(os.difftime(os.time(currentDate),os.time(weekMorningTriggerTime) ) ) < acceptWindow ) )
 or
 (currentDate.wday >= 2 and currentDate.wday <= 6 and (math.abs(os.difftime(os.time(currentDate),os.time(weekendMorningTriggerTime) ) ) < acceptWindow))
or
(startSource["type"] == "other")
)
then
    fibaro:call(43, "turnOn");
    fibaro:call(21, "setValue", "78");
    fibaro:call(58, "turnOn");
    fibaro:call(24, "setValue", "60");
end
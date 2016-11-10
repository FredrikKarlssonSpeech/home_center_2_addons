--[[
%% properties
3 Temperature
3 Humidity
3 Wind
3 WeatherConditionConverted
%% events
%% globals
--]]

local startSource = fibaro:getSourceTrigger();
if (
 ( tonumber(fibaro:getValue(3, "Temperature")) == tonumber(0)  or  tonumber(fibaro:getValue(3, "Humidity")) == tonumber(0)  or  tonumber(fibaro:getValue(3, "Wind")) == tonumber(0)  or  fibaro:getValue(3, "WeatherConditionConverted") == "clear"  and  fibaro:getValue(3, "WeatherConditionConverted") == "cloudy"  or  fibaro:getValue(3, "WeatherConditionConverted") == "rain"  or  fibaro:getValue(3, "WeatherConditionConverted") == "snow"  or  fibaro:getValue(3, "WeatherConditionConverted") == "storm"  and  fibaro:getValue(3, "WeatherConditionConverted") == "fog" )
or
startSource["type"] == "other"
)
then
    fibaro:startScene(16);
end


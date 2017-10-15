

--- A function that lets you access the outside temperature reported by the remote weather service set up for the Home Center 2.
-- @return The function returns the temperature as a number. If the function could not find a temperature value due to some error in the service, a 'nil' value is returned.



function getOutSideTemperature()
	local function isEmpty(s)
  		return s == nil or s == '';
	end;
	temp = tonumber(fibaro:getValue(3, "Temperature"));
	if(isEmpty(temp)) then
		return(nil);
	end;
	return(temp);
end;

--- A function that lets you access the outside humidity reported by the remote weather service set up for the Home Center 2.
-- @return The function returns the temperature as a number. If the function could not find a temperature value due to some error in the service, a 'nil' value is returned.

function getOutSideHumidity()
	local function isEmpty(s)
  		return s == nil or s == '';
	end;
	temp = tonumber(fibaro:getValue(3, "Temperature"));
	if(isEmpty(temp)) then
		return(nil);
	end;
	return(temp);
end;

--- A function that checks whether weather conditions are "clear".
-- @treturn boolean 'true' if the weather is clear, 'false' if not 

function weatherIsClear()
	cond = lower(tostring(fibaro:getValue(3, "WeatherConditionConverted")));
	return (cond == "clear")
end;

--- A function that checks whether weather conditions are "cloudy".
-- @treturn boolean 'true' if the weather is cloudy, 'false' if not 

function weatherIsCloudy()
	cond = lower(tostring(fibaro:getValue(3, "WeatherConditionConverted")));
	return (cond == "cloudy")
end;

--- A function that checks whether it is currently raining.
-- @treturn boolean 'true' if it is raining, 'false' if not 

function isRainyWeather()
	cond = lower(tostring(fibaro:getValue(3, "WeatherConditionConverted")));
	return (cond == "rainy")
end;


--- A function that checks it is currently snowing.
-- @treturn boolean 'true' if it is snowing, 'false' if not 

function isSnowing()
	cond = lower(tostring(fibaro:getValue(3, "WeatherConditionConverted")));
	return (cond == "snow")
end;


--- A function that checks whether there is a storm outside.
-- @treturn boolean 'true' if a storm is reported, 'false' if not 

function isStorming()
	cond = lower(tostring(fibaro:getValue(3, "WeatherConditionConverted")));
	return (cond == "storm")
end;


--- A function that checks whether there is a fog outside.
-- @treturn boolean 'true' if a fog is reported by the weather service, 'false' if not 

function isFog()
	cond = lower(tostring(fibaro:getValue(3, "WeatherConditionConverted")));
	return (cond == "fog")
end;
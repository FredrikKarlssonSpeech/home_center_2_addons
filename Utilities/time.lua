--- Functions that manages the defined time of day.
-- @section timeofday


--- A function that checks whether it is daytime or not
-- This function checks the "TimeOfDay" global variable, and expects that the answer is "Day" if true.
-- @treturn bool An indication whether it currently is daytime or not.

function isDaytime()
	local stat = tostring(fibaro:getGlobalValue("TimeOfDay"));
	return(sting.lower(stat) == "day");
end;

--- A function that checks whether it is nighttime or not
-- This function checks the "TimeOfDay" global variable, and expects that the answer is "Night" if true.
-- @treturn bool An indication whether it currently is nighttime or not.

function isNighttime()
	local stat = tostring(fibaro:getGlobalValue("TimeOfDay"));
	return(sting.lower(stat) == "night");
end;

--- A function that checks whether it is morning or not
-- This function checks the "TimeOfDay" global variable, and expects that the answer is "Morning" if true.
-- @treturn bool An indication whether it currently is morning or not.

function isMorning()
	local stat = tostring(fibaro:getGlobalValue("TimeOfDay"));
	return(sting.lower(stat) == "morning");
end;

--- A function that checks whether it is morning or not
-- This function checks the "TimeOfDay" global variable, and expects that the answer is "Evening" if true.
-- @treturn bool An indication whether it currently is evening or not.

function isEvening()
	local stat = tostring(fibaro:getGlobalValue("TimeOfDay"));
	return(sting.lower(stat) == "evening");
end;
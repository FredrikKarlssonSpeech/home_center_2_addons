--- Functions that manages the defined time of day.
-- @section timeofday

--- An example time of day scheme that may be used as a default
-- or altered to fit the indivdual's need.
DEFAULT_TIME_OF_DAY = {
	{["days"]={2,3,4,5,6},["time"]="06:30",["tod"]="Morning"},
	{["days"]={1,7},["time"]="06:30",["tod"]="Morning"},
	{["days"]={2,3,4,5,6},["time"]="08:00",["tod"]="Day"},
	{["days"]={1,7},["time"]="10:00",["tod"]="Day"},
	{["days"]={1,2,3,4,5,6,7},["time"]="18:00",["tod"]="Evening"},
	{["days"]={2,3,4,5,6},["time"]="23:30",["tod"]="Night"},
	{["days"]={1,7},["time"]="23:59",["tod"]="Night"}
};

function setTimeOfDay(todStructure)
	local todStr = todStructure or DEFAULT_TIME_OF_DAY;
	local wday = os.date("*t")["wday"];
	for k,str in pairs(todStr) do
		if tableValueExists(str["days"],wday) and afterTime(str["time"],0) then
			fibaro:debug("Setting TimeOfDay to '".. str["tod"] .. "'")
			fibaro:getGlobalValue("TimeOfDay",str["tod"]);
			return(true);
		end;
	end;
	return(false);
end;

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


--- A utility function that returns the time today defined as the time when Morning starts.
-- @treturn string The time in text format (e.g. "06:30") that has been defined by the day and time structure that you supplied to @{\setTimeOfDay}.
-- @see setTimeOfDay

function wakeupTimeToday()
	local todStr = todStructure or DEFAULT_TIME_OF_DAY;
	local wday = os.date("*t")["wday"];
	for k,str in pairs(todStr) do
		if tableValueExists(str["days"],wday) and str["tod"] == "Morning" then
			return(str["time"]);
		end;
	end;
end;

--- A utility function that returns the time today defined when Nighttime is defined to start.
-- @treturn string The time in text format (e.g. "23:30") that has been defined by the day and time structure that you supplied to @{\setTimeOfDay}.
-- @see setTimeOfDay

function nightTimeToday()
	local todStr = todStructure or DEFAULT_TIME_OF_DAY;
	local wday = os.date("*t")["wday"];
	for k,str in pairs(todStr) do
		if tableValueExists(str["days"],wday) and str["tod"] == "Night" then
			return(str["time"]);
		end;
	end;
end;

--- A utility function that returns the time today defined when Evening is defined to start.
-- @treturn string The time in text format (e.g. "18:30") that has been defined by the day and time structure that you supplied to @{\setTimeOfDay}.
-- @see setTimeOfDay

function eveningStartsToday()
	local todStr = todStructure or DEFAULT_TIME_OF_DAY;
	local wday = os.date("*t")["wday"];
	for k,str in pairs(todStr) do
		if tableValueExists(str["days"],wday) and str["tod"] == "Evening" then
			return(str["time"]);
		end;
	end;
end;

--- A utility function that returns the time today defined when Daytime is defined to start.
-- @treturn string The time in text format (e.g. "18:30") that has been defined by the day and time structure that you supplied to @{\setTimeOfDay}.
-- @see setTimeOfDay

function daytimeStartsToday()
	local todStr = todStructure or DEFAULT_TIME_OF_DAY;
	local wday = os.date("*t")["wday"];
	for k,str in pairs(todStr) do
		if tableValueExists(str["days"],wday) and str["tod"] == "Day" then
			return(str["time"]);
		end;
	end;
end;

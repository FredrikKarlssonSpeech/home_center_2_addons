--- Functions that manage or query the state of the home or its occupants.
-- @section state


--- A function that checks whether the house is AWAY state.
-- This function checks the "PresentState" global variable, and expects that the answer is "Away" if true.
-- @treturn bool An indication whether the house is in away state or not.

function isInAwayMode()
	local stat = tostring(fibaro:getGlobalValue("PresentState"));
	return(sting.lower(stat) == "away");
end;

--- A function that checks whether the house is "Home" state.
-- This function checks the "PresentState" global variable, and expects that the answer is "Home" if true.
-- @treturn bool An indication whether the occupants are in the house or not.

function isAtHomeMode()
	local stat = tostring(fibaro:getGlobalValue("PresentState"));
	return(sting.lower(stat) == "home");
end;

--- A function that checks whether the house is "Sleeping" state.
-- This function checks the "PresentState" global variable, and expects that the answer is "Sleeping" if true.
-- @treturn bool An indication whether the occupants should be sleeping or not.

function isInSleepingMode()
	local stat = tostring(fibaro:getGlobalValue("PresentState"));
	return(sting.lower(stat) == "sleeping");
end;


--- A function that checks whether the house is "Holiday" state.
-- This function checks the "PresentState" global variable, and expects that the answer is "Holiday" if true.
-- @treturn bool An indication whether the house is set to "Holiday" mode or not.

function isInSleepingMode()
	local stat = tostring(fibaro:getGlobalValue("PresentState"));
	return(sting.lower(stat) == "holiday");
end;

--- A function that checks whether the occupants of the house are sleeping or not.
-- This function checks the "SleepState" global variable, and expects that the answer is "Sleeping" if true.
-- @treturn bool An indication whether the occupants are sleeping or not.

function occupantsAreSleeping()
	local stat = tostring(fibaro:getGlobalValue("SleepState"));
	return(sting.lower(stat) == "sleeping");
end;

--- A function that checks whether the occupants of the house are awake or not.
-- This function checks the "SleepState" global variable, and expects that the answer is "Awake" if true.
-- @treturn bool An indication whether the occupants are awake or not.

function someoneIsAwake()
	local stat = tostring(fibaro:getGlobalValue("SleepState"));
	return(sting.lower(stat) == "awake");
end;
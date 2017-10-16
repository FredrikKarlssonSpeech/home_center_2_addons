--- Functions that manage or query the state of the home or its occupants.
-- @section state


--- A function that checks that important state keeping variables are set up propertly.
-- If an erroneous value is detected, this function aborts the currently running script.
-- As this function will abort scripts in which it is called, the function has no return value.

function checkStateVariableIntegrity()
	-- Check that "PresentState" is set to a valid value.
	local stat = string.lower(tostring(fibaro:getGlobalValue("PresentState")));
	if (stat ~= "away" and stat ~= "home" and stat ~= "sleeping" and stat ~= "holiday") then
		fibaro:debug("The variable 'PresentState' does not contain a valid value: '".. stat .. "'. Aborting.");
		fibaro:abort();
	end;

	-- Check that "SleepState" is set to a valid value.
	local stat = string.lower(tostring(fibaro:getGlobalValue("SleepState")));
	if (stat ~= "sleeping" and stat ~= "awake") then
		fibaro:debug("The variable 'SleepState' does not contain a valid value: '".. stat .. "'. Aborting.");
		fibaro:abort();
	end;

end;

--- A function that checks whether the house is AWAY state.
-- This function checks the "PresentState" global variable, and expects that the answer is "Away" if true.
-- @treturn bool An indication whether the house is in away state or not.

function isInAwayMode()
	local stat = tostring(fibaro:getGlobalValue("PresentState"));
	return(sting.lower(stat) == "away");
end;

--- A function that sets the house in "Away" state.
-- The function also makes sure that the variable is actually set correctly. If it was unable to set the intended state. this funcion will abot the currently running script.
-- @treturn bool In case the action was completed, the function returns 'true'.

function setAwayMode()
	fibaro:getGlobak("PresentState","Away");
	-- Chech state
	local stat = tostring(fibaro:getGlobalValue("PresentState"));
	if(sting.lower(stat) ~= "away") then
		fibaro:abort();
	end;
	return(true);
end;

--- A function that checks whether the house is "Home" state.
-- This function checks the "PresentState" global variable, and expects that the answer is "Home" if true.
-- @treturn bool An indication whether the occupants are in the house or not.

function isAtHomeMode()
	local stat = tostring(fibaro:getGlobalValue("PresentState"));
	return(sting.lower(stat) == "home");
end;

--- A function that sets the house in "Home" state.
-- The function also makes sure that the variable is actually set correctly. If it was unable to set the intended state. this funcion will abot the currently running script.
-- @treturn bool In case the action was completed, the function returns 'true'.

function setHomeMode()
	fibaro:getGlobak("PresentState","Home");
	-- Chech state
	local stat = tostring(fibaro:getGlobalValue("PresentState"));
	if(sting.lower(stat) ~= "home") then
		fibaro:abort();
	end;
	return(true);
end;

--- A function that checks whether the house is "Sleeping" state.
-- This function checks the "PresentState" global variable, and expects that the answer is "Sleeping" if true.
-- @treturn bool An indication whether the occupants should be sleeping or not.

function isInSleepingMode()
	local stat = tostring(fibaro:getGlobalValue("PresentState"));
	return(sting.lower(stat) == "sleeping");
end;

--- A function that sets the house in "Sleeping" state.
-- The function also makes sure that the variable is actually set correctly. If it was unable to set the intended state. this funcion will abot the currently running script.
-- @treturn bool In case the action was completed, the function returns 'true'.

function setSleepingMode()
	fibaro:getGlobak("PresentState","Sleeping");
	-- Chech state
	local stat = tostring(fibaro:getGlobalValue("PresentState"));
	if(sting.lower(stat) ~= "sleeping") then
		fibaro:abort();
	end;
	return(true);
end;

--- A function that checks whether the house is "Holiday" state.
-- This function checks the "PresentState" global variable, and expects that the answer is "Holiday" if true.
-- @treturn bool An indication whether the house is set to "Holiday" mode or not.

function isInHolidayMode()
	local stat = tostring(fibaro:getGlobalValue("PresentState"));
	return(sting.lower(stat) == "holiday");
end;

--- A function that sets the house in "Holiday" state.
-- The function also makes sure that the variable is actually set correctly. If it was unable to set the intended state. this funcion will abot the currently running script.
-- @treturn bool In case the action was completed, the function returns 'true'.

function setHolidayMode()
	fibaro:getGlobak("PresentState","Sleeping");
	-- Chech state
	local stat = tostring(fibaro:getGlobalValue("PresentState"));
	if(sting.lower(stat) ~= "holiday") then
		fibaro:abort();
	end;
	return(true);
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
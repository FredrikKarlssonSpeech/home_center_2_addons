
--- These functions manages setting and querying the variable that keeps a record of whether the sun is up or not 
-- @sunlight

--- This function sets the global variable in which the state of the sun is kept
-- @tparam[opt=0] number offset an offset that should be applied to sunset and sunrise times
-- @tparam[opt="23:30"] string latestSunset the latest time where the "SunState" should be changed to "Sun down".

function setSunState(offset,latestSunset)
	local offset = offset or 0;
	local latestSunset = latestSunset or "23:30";
	local sunsetHour = earliest(stringTimeAdjust( tostring(fibaro:getValue(1, "sunsetHour")), offset ),latestSunset);
	local sunriseHour = fibaro:getValue(1, "sunriseHour");
	local nowSet = fibaro:getGlobalValue("SunState");
	if afterTime(sunriseHour, offset) and beforeTime(sunsetHour, -offset) then
		local toSet = "Sun up";
	else
		local toSet = "Sun down";
	end;

	if nowSet ~= toSet then
		-- Of course, this global variable needs to be provided by the user.
		fibaro:setGlobal("SunState",toSet);
	end;
end;

--- A small function that checks whether the sun is set
-- @tparma boolean The answer to the question "Is the sun currently down?"
function sunIsDown()
	local stat = tostring(fibaro:getGlobalValue("SunState"));
	return(sting.lower(stat) == "sun down");
end;


--- A small function that checks whether the sun is up
-- @tparma boolean The answer to the question "Is the sun currently up?"
function sunIsUp()
	local stat = tostring(fibaro:getGlobalValue("SunState"));
	return(sting.lower(stat) == "sun up");
end;

--- These functions makes it easier for you to know the current week day or part of the week
-- @section weekPart

--- This function sets a global variable indicating the part of week (weekday or weekend) today and tomorrow.
-- This function demands the variables "PartOfWeekToday" and "PartOfWeekTomorrow" to have been set up by the user.

function setPartOfWeek()
	local setPartToday = tostring(fibaro:getGlobal("PartOfWeekToday"));
	local setPartTomorrow = tostring(fibaro:getGlobal("PartOfWeekTomorrow"));
	if isWeekDay() and setPartToday ~= "Weekday" then;
		fibaro:setGlobal("PartOfWeekToday","Weekday");
	else
		fibaro:setGlobal("PartOfWeekToday","Weekend");
	end;

	if isWeekDayTomorrow() and setPartTomorrow ~= "Weekday" then
		fibaro:setGlobal("PartOfWeekTomorrow","Weekday");
	else
		fibaro:setGlobal("PartOfWeekTomorrow","Weekend");
	end;
end;

--- A function that indicates whether today is one of the weekdays named in the given list.
-- A call 'isDayofWeek({"Mon","Tues"})' will return true on Wednesdays and Tuesdays, but not other days.
-- @tparam {string} dayList A list of names of weekdays in a long (e.g. "Friday") or short (e.g. "Fri") format.
-- @treturn boolean A boolean (true /false) indicating whether the short name of today is given in the list.
-- @usage print(isDayOfWeek{"Sun"})
-- -- This will print "true" on Sundays, but not on other weekdays

function isDayOfWeek (dayList)
    local today = os.date("%a",os.time());
    local longToday = os.date("%A",os.time());
    for i, v in ipairs(dayList) do
        if today == v or longToday == v then
            return(true);
        end;
    end;
    return(false);
end;

--- Simple function that returns true if today is a weekday.
-- A weekday is defined as Monday-Friday.
-- @treturn boolean A boolean (true/false)

function isWeekDay ()
    local today = tonumber(os.date("%w",os.time()));
    -- Please note that this specification is 0-6 range, sunday=0
    return (not (today == 0 or today == 6));
end;

-- Simple function that returns true if tomorrow is a weekday.
-- A weekday is defined as Monday-Friday.
-- @treturn boolean A boolean (true/false)

function isWeekDayTomorrow ()
    local today = tonumber(os.date("%w",os.time()));
    -- Please note that this specification is 0-6 range, sunday=0
    return (not (today == 5 or today == 6));
end;

--- Simple function that returns true if today is part of the weekend.
-- A weekday is defined as Saturday or Sunday
-- @treturn boolean A boolean (true/false)


function isWeekEnd ()
    local today = tonumber(os.date("%w",os.time()));
    return (today == 0 or today == 6);
end;

--- Simple function that returns true if tomorrow is part of the weekend.
-- A weekday is defined as Saturday or Sunday
-- @treturn boolean A boolean (true/false)


function isWeekEndTomorrow ()
    local today = tonumber(os.date("%w",os.time()));
    return (today == 5 or today == 6);
end;
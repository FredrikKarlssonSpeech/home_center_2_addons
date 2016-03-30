--[[
%% properties
%% events
%% globals
--]]


--- A function that creates a os.date table from the time of sunset the same day.
-- Provided that the function is not called exactly at midnight, the function will return a table that mathces the output of an os.date("*t")
-- call made exactly the minute corresponding to the sunset hour.
-- @param time A text representation (e.g. "08:10") of the time of today to concert to a os.date date table. Allowed formats are "HH", "HH:MM" or "HH:MM:SS". "HH" is a short form for "HH:00" and "HH:MM" is a short for "HH:MM:00".
-- @return a table with year, month,day, hour min, sec and isdst fields.
-- @see os.date

function timestringToTable (time)
    local dateTable = os.date("*t");
    -- Get an iterator that extracts date fields
    local g =  string.gmatch(time, "%d+");

    local hour = g() ;
    local minute = g() or 0;
    local second = g() or 0;
    -- Insert sunset inforation istead
    dateTable["hour"] = hour;
    dateTable["min"] = minute;
    dateTable["sec"] = second;
    return(dateTable)
end


-- Utility function that computes the number of seconds since Epoch from a date and time table in the form given by os.date
-- @param t A time specification table with the fields year, month, day, hour, min, sec, and isdst.
-- @return An integer inficating the Epoch time stamp corresponding to the date and time given in the table.

function tableToEpochtime (t)
    local now = os.date("*t");
    local outTime = os.time{year=t.year or now.year, month=t.month or now.month,day=t.day or now.day,hour=t.hour or now.hour,min=t.min or now.min,sec=t.sec or now.sec,isdst=t.isdst or now.isdst};
    return(outTime);
end

--- A function that tests whether the current time is within a specified time window from a given time.
-- In order to work well with the output of fibaro:call(1,"sunsetHour") and similar use cases, time is specified in the
-- form of a string ("08:10" for ten minutes past eight in the morning) in a 24 hour clock format, and an offset (in minutes).
-- When called as isTime("08:10",0,10) the function will return 'true' from 08:09:50 to 08:10:10, and 'false' outside of this time range.
-- Please note that the function will return true every time it is checked within the time range, so the calling function
-- needs to make sure that there is an appropriate delay between checks.
--
-- A call isTime("08:10",45,10) will return 'true' from 08:54:50 to 08:55:10, and 'false' earlier or later than this.
-- @param timeString The textual specification of the time to test against (e.g. "08:10").
-- @param offsetMinues The number of minutes to add to the 'timeString' time.
-- @param secondsWindo The size of the time window (in secons) in which the function will return 'true'. A zero (0) will cause the function to return 'true' only at 08:10:00 (and not 08:10:01) when called as isTime("08:10",0,0) so calls like that should be avoided.
-- @return A boolean (true or false) indicating whether the current time is within the specificed time range.

function isTime (timeString, offsetMinutes, secondsWindow)
    local timeTable = timestringToTable(timeString);
    local timeEpoch = tableToEpochtime (timeTable);
    local timeWithOffset = timeEpoch + (offsetMinutes * 60);
    local now = os.time();
    return ( math.abs(timeWithOffset - now) <= secondsWindow )
end

--- A function that checks whether the current time is within a range given as two text strings.
-- This function is often more convenient than 'isTime' as you don't have to calculate the time and offset yourself.
-- Please note that the function will return true every time it is checked within the time range, so the calling function
-- needs to make sure that there is an appropriate delay between checks.
--
-- @param startTimeString a time specification in the form of "HH:MM" (e.g. "08:10") indicating the start of the time range.
-- @param endTimeString a time specification in the form of HH:MM (e.g. "08:10") indicating the end of the time range.
-- @return A boolean (true or false) indicating whether the current time is within the specificed time range.

function isInTimeRange (startTimeString, endTimeString)
    local startTimeTable = timestringToTable(startTimeString);
    local endTimeTable = timestringToTable(endTimeString);
    local startTimeEpoch = tableToEpochtime (startTimeTable);
    local endTimeEpoch = tableToEpochtime (endTimeTable);
    local now = os.time();
    return ( (startTime <= now ) and (endTime >= now))
end

--- A function that indicates whether today is one of the weekdays named in the given list.
-- The function accepts short version of the weekday names.
-- A call 'isDayofWeek({"Mon","Tues"})' will return true on Wednesdays and Tuesdays, but not other days.
-- @param dayList A list of short names of weekdays.
-- @return A boolean (true /false) indicating whether the short name of today is given in the list.

function isDayofWeek (dayList)
    local today = os.date("%a",os.time());
--    fibaro:debug(tostring(today));
    for i, v in ipairs(dayList) do
        if today == v then
            return(true);
        end
    end
    return(false);
end

--- Simple function that returns true if today is a weekday.
-- A weekday is defined as Monday-Friday.
-- @return A boolean (true/false)

function isWeekDay ()
    local today = os.date("%w",os.time());
    return (not (today == 0 or today == 6));
end

--- Simple function that returns true if today is part of the weekend.
-- A weekday is defined as Saturday or Sunday
-- @return A boolean (true/false)


function isWeekEnd ()
    local today = os.date("%w",os.time());
    return (today == 0 or today == 6);
end



--- A function that lets you specify date and time through a table
-- The table should use only fields that are returned by a call to os.time, i.e. a subset of year, month, day, hour, min, sec, wday, yday, isdst.
-- @param dateTable A time specification. For instance, {day=6,hour=15} returns 'true' on Sundays at 3 pm, {year=2016,month=2, hour=9} will return 'true' every day in February 2016 at 9 am, and 'false' at any time where parts of specification is not met.
-- @return A boolean (true/false) indicating the complete match of the table against current time and date.
-- @see os.time
-- @usage datetimeTableTrue({month=2,minute=2})
-- -- # will return true every other minute in february.


function datetimeTableTrue (dateTable)
    local nowTodayTable = os.date("*t");
    for k,v in pairs(dateTable) do
        if not (nowTodayTable[k] == dateTable[k]) then
            return(false);
        end
    end
    return(true);
end

--print(tostring(datetimeTableTrue({year=2016,hour=9})))

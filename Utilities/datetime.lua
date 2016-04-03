--- A module that fascilitates specification of times when Fibaro lua scenes should run.


--- A function that creates a @{os.date} table from the time of sunset the same day.
-- Provided that the function is not called exactly at midnight, the function will return a table that mathces the output of an os.date("*t")
-- call made exactly the minute corresponding to the sunset hour.
-- @tparam string time A text representation (e.g. "08:10") of the time of today to concert to a @{os.date} date table. Allowed formats are "HH", "HH:MM" or "HH:MM:SS". "HH" is a short form for "HH:00" and "HH:MM" is a short for "HH:MM:00".
-- @treturn table A table with year, month,day, hour min, sec and isdst fields.
-- @see os.date
-- @usage
-- print(tostring(timestringToTable("08:10")))
-- -- Will return 'true' when between 08:10  and 08:59
-- print(tostring(timestringToTable("08")))
-- -- Will return 'true' the entire hour
-- print(tostring(timestringToTable("08:10:10")))
-- -- Will return 'true' exactly at the indicated second

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
-- @tparam table t A time specification table with the fields year, month, day, hour, min, sec, and isdst.
-- @treturn number An integer inficating the Epoch time stamp corresponding to the date and time given in the table.

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
-- @tparam string timeString The textual specification of the time to test against (e.g. "08:10").
-- @tparam number offsetMinutes The number of minutes to add to the 'timeString' time.
-- @tparam number secondsWindow The size of the time window (in secons) in which the function will return 'true'. A zero (0) will cause the function to return 'true' only at 08:10:00 (and not 08:10:01) when called as isTime("08:10",0,0) so calls like that should be avoided.
-- @treturn boolean A boolean (true or false) indicating whether the current time is within the specificed time range.


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
-- @tparam string startTimeString a time specification in the form of "HH:MM" (e.g. "08:10") indicating the start of the time range.
-- @tparam string endTimeString a time specification in the form of HH:MM (e.g. "08:10") indicating the end of the time range.
-- @treturn boolean A boolean (true or false) indicating whether the current time is within the specificed time range.

function isInTimeRange (startTimeString, endTimeString)
    local startTimeTable = timestringToTable(startTimeString);
    local endTimeTable = timestringToTable(endTimeString);
    local startTimeEpoch = tableToEpochtime (startTimeTable);
    local endTimeEpoch = tableToEpochtime (endTimeTable);
    local now = os.time();
    return ( (startTime <= now ) and (endTime >= now))
end

--- A function that indicates whether today is one of the weekdays named in the given list.
-- A call 'isDayofWeek({"Mon","Tues"})' will return true on Wednesdays and Tuesdays, but not other days.
-- @tparam {string} dayList A list of names of weekdays in a long (e.g. "Friday") or short (e.g. "Fri") format.
-- @treturn boolean A boolean (true /false) indicating whether the short name of today is given in the list.

function isDayOfWeek (dayList)
    local today = os.date("%a",os.time());
    local longToday = os.date("%A",os.time());
--    fibaro:debug(tostring(today));
    for i, v in ipairs(dayList) do
        if today == v or longToday == v then
            return(true);
        end
    end
    return(false);
end

--- Simple function that returns true if today is a weekday.
-- A weekday is defined as Monday-Friday.
-- @treturn boolean A boolean (true/false)

function isWeekDay ()
    local today = os.date("%w",os.time());
    -- Please note that this specification is 0-6 range, sunday=0
    return (not (today == 0 or today == 6));
end

--- Simple function that returns true if today is part of the weekend.
-- A weekday is defined as Saturday or Sunday
-- @treturn boolean A boolean (true/false)


function isWeekEnd ()
    local today = os.date("%w",os.time());
    return (today == 0 or today == 6);
end

--- Check whether current time is before a specified time.
-- The function is designed to work well in a chain of checks, and therefore also makes sure that
-- time is not before the start of the day.
-- @tparam string time A time specification string, e.g. "08", "08:10" or "08:10:10"
-- If not specified, seconds is assumed to be 00, so that "08:10" is equivalent to giving "08:10:00"
-- as an argument. Thus, this function will then return 'true' up until "08:09:59" .
-- @treturn boolean A truth value (true/false)
-- @see os.time

function beforeTime(time)
    local timeEpoch = tableToEpochtime(timestringToTable(time));
    local startOfDay = tableToEpochtime(timestringToTable("00:00"));
    local now = os.time();
    return( (now < timeEpoch) and (now >= startOfDay ))
end

--- Check whether current time is after a specified time.
-- The function is designed to work well in a chain of checks, and therefore also makes sure that
-- time is not after the end of the day.
-- @tparam string time A time specification string, e.g. "08", "08:10" or "08:10:10".
-- If not specified, seconds is assumed to be 00, so that "08:10" is equivalent to giving "08:10:00"
-- as an argument. Thus, this function will then return 'true' from "08:10:01" and onwards.
-- @treturn boolean A truth value (true/false)
-- @see os.time

function afterTime(time)

    local timeEpoch = tableToEpochtime(timestringToTable(time));
    print(timeEpoch)
    local endOfDay = tableToEpochtime(timestringToTable("23:59:59"));
    local now = os.time();
    return( (now > timeEpoch) and (now <= endOfDay ))
end

--- A function that lets you specify date and time in a very flexible way through a table
-- The table should use only fields that are returned by a call to @{os.time} (year, month, day, hour, min, sec), 'wday' (1-7 scale, Sunday is 1) or 'yday' (day within the year, Jan 1st is 1).
-- @tparam table dateTable A table giving a time specification.  For instance, {day=6,hour=15} returns 'true' on Sundays at 3 pm, {year=2016,month=2, hour=9} will return 'true' every day in February 2016 at 9 am, and 'false' at any time where parts of specification is not met. In each field, a table may be given, in which case any one of the options given will be accepted.
-- @treturn boolean A boolean (true/false) indicating the complete match of the table against current time and date.
-- @see os.time
-- @usage datetimeTableTrue({month=2,minute=2})
-- -- # will return 'true' every other minute in february.
-- datetimeTableTrue({wday=2,yday=2})
-- -- # will return 'true' when tested on the January 2nd, if it is a Monday.
-- datetimeTableTrue({month=1,day=14,hour=6, minute=30})
-- -- Will return 'true' when I wake up on my birthday
-- datetimeTableTrue({month=1,day={14,15,16},hour=6, minute={0,30}})
-- -- Will return 'true' on the 14th,15th or 16th of January at 6:00 or 6:30.


function datetimeTableTrue (dateTable)
    local nowTodayTable = os.date("*t");
    local scorekeeper = false;
    for k,v in pairs(dateTable) do
        -- Here I intentionally disregard the boolean isdst value, as the dateTable time specification should always be "true" time
        if type (v) == "number" then
            if not (nowTodayTable[k] == dateTable[k]) then
                return(false);
            end
        elseif type (v) == "table" then
            -- Here the logic is different. We cannot return 'false' until we have checked all elements in the list.
            for ki, vi in pairs(v) do
                if (nowTodayTable[k] == v[ki]) then
                    scorekeeper = true;
                end
            end
            if not scorekeeper then
                return(false)
            end
            scorekeeper = false;
        else
            if not debug == nil then
                fibaro:debug("List of options in a field in the table should only contain numbers")
            else
                error("List of options in a field in the table should only contain numbers")
            end
        end
    end
    return(true);
end

--print(tostring(datetimeTableTrue({year=2016,hour=9})))

-- local tab = {a=1,b={1,2}};

--- Function that simplifies running a scene on a timer and specify the delay needed.
-- The basic structure of the function is that it takes a truth value indicating whether the scene should run.
-- The idea is that this truth value should be the result of a series of time or source evaluations combined
-- into one evaluation by 'and' and 'or' joiners, possibly with nesting.
-- The function @{myTimer} will then evaluate the function supplied as the second argument, if the first argument is evaluated to 'true'.
-- After running the function constituting the scene, a delay may be imposed.
-- @tparam boolean shouldRun A truth value. If evaluated to 'true', then the function will be run and the delay imposed.
-- @tparam function functionToRun The function summarising the actions of the scene.
-- @tparam number delaySeconds The number of seconds delay that should be imposed after having performed the scene.
-- @usage
-- function f () fibaro:call(12,"powerON") end
-- -- A very simple scene
-- myTimer ( notCurrentlyRunning() and isTime("08:10",0,20) and isDayOfWeek("Mon","Tues"), f, 2*60)
-- -- This call will turn on switch 12 when tested from 08:09:40 to 08:10:20 on Mondays and Tuesdays
-- -- and then sleep for 2 minutes in order to ensure that the scene is not run constantly,
-- -- or more than once, as the 2 minutes delay combined with the call to @{notCurrentlyRunning} makes
-- -- sure that it is not evaluated again within the 20 seconds time window allowed by the call to @{isTime}.

function myTimer(shouldRun, functionToRun, delaySeconds )
    if shouldRun then
        functionToRun()
        fibaro:sleep(delaySeconds*1000)
    end
end

--- A function that determines whether the heater of a car should be turned on.
-- The determination is base on the time when you want to leave, the temperature outside and an optional value indicating whether the heater is on already or not.
-- @tparam string readyTime A time specification where the cars should be ready, e.g. "07:30" for half past 7 in the morning.
-- @tparam number tempOutside The temperature outside or inside the car (if available).
-- @tparam boolean eco Should eco settings be used? If not, the car motor health will be considered more important.
-- @tparam boolean heaterON An optional value indicating whether the heater is already started or not. This may be used to flexibly check whether the heater has been started already, perhaps from a global variable, so that that traffic on the z-wave network may be minimized. If not speficied, it defaults to false.
-- @treturn boolean A truth value (true/false).

function timeToStartCarHeater (readyTime, tempOutside, eco, heaterON)
    local timeEpoch = tableToEpochtime(timestringToTable(readyTime));
    local now = os.time();
    local heaterStarted = heaterON or false;
    local startTime = timeEpoch;
    if (eco) then
        if (tempOutside <= -15) then
            -- 2 Hours before time
            startTime = timeEpoch - (3600*2)
        elseif (tempOutside <= -10) then
            -- 1 Hour before time
            startTime = timeEpoch - (3600*1)
        elseif (tempOutside <= 0) then
            -- 1 Hours before time
            startTime = timeEpoch - (3600*1)
        elseif (tempOutside <= 10) then
            -- 0.5 Hours before time
            startTime = timeEpoch - (3600*0.5)
        else
            -- if not <=10 degrees C, do not start the heater.
            return(false);
        end
    else
        if (tempOutside <= -20) then
            -- 3 Hours before time
            startTime = timeEpoch - (3600*3)
        elseif (tempOutside <= -10) then
            -- 2 Hours before time
            startTime = timeEpoch - (3600*2)
        elseif (tempOutside <= 0) then
            -- 1 Hours before time
            startTime = timeEpoch - (3600*1)
        elseif (tempOutside <= 10) then
            -- 1Hours before time
            startTime = timeEpoch - (3600*1)
        else
            -- if not <=10 degrees C, do not start the heater.
            return(false);
        end
    end
    -- Now calculate whether the heater should start NOW
    return ( (not heaterON) and (startTime <= now) and (now <= timeEpoch))
end


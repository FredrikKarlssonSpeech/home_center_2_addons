--[[
%% properties
%% events
%% globals
--]]

--- A function that creates a os.date table from the time of sunset the same day.
-- Provided that the function is not called exactly at midnight, the function will return a table that mathces the output of an os.date("*t")
-- call made exactly the minute corresponding to the sunset hour.
-- @return a table with year, month,day, hour min, sec and isdst fields.

function tableFromTime (time)
    -- Get an iterator that extracts date fields
    local g =  string.gmatch(time, "%d+");

    local hour = g();
    local minute = g() ;
    local sunsetDateTable = os.date("*t");
    -- Insert sunset inforation istead
    sunsetDateTable["hour"] = hour;
    sunsetDateTable["min"] = minute;
    return(sunsetDateTable)
end

function sunsetTodayTable ()
    local sunsetHour = fibaro:getValue(1,'sunsetHour');
    return(tableFromTime(sunsetHour))
end

function tableToOSTime (t)
    local now = os.date("*t");
    local outTime = os.time{year=t.year or now.year, month=t.month or now.month,day=t.day or now.day,hour=t.hour or now.hour,min=t.min or now.min,sec=t.sec or now.sec,isdst=t.isdst or now.isdst};
    return(outTime);
end

function sunsetDiff()
    local now = os.time();
    local st = sunsetTodayTable();
--    local sun = os.time{year=st.year, month=st.month,day=st.day,hour=st.hour,min=st.min,sec=st.sec,isdst=st.isdst};
    local sun = tableToOSTime(st);
    return ( os.difftime(sun,now) )
end


function isWinthinSunsetTimewindow (seconds)
    local sunsetDateTable = sunsetTodayTable()
    local ret = false
    if math.abs(os.difftime(os.time(), os.time(sunsetDateTable)) <= seconds) then
        ret= true
    end
    return (ret);
end

function printTable (t)
    for k, v in pairs(t) do
        fibaro:debug(k.." ".. tostring(v))
    end
end

--[[
%% properties
251 value
%% events
%% globals
--]]

local takState = tonumber(fibaro:getValue(251, "value"));
local sunsetHour = tostring(fibaro:getValue(1, "sunsetHour"));

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
    return(dateTable);
end;

function tableToEpochtime (t)
    local now = os.date("*t");
    local outTime = os.time{year=t.year or now.year, month=t.month or now.month,day=t.day or now.day,hour=t.hour or now.hour,min=t.min or now.min,sec=t.sec or now.sec,isdst=t.isdst or now.isdst};
    return(outTime);
end;

function afterTime(time)
    local timeEpoch = tableToEpochtime(timestringToTable(time));
    local endOfDay = tableToEpochtime(timestringToTable("23:59:59"));
    local now = os.time();
    return( (now > timeEpoch) and (now <= endOfDay ));
end;

function beforeTime(time)
    local timeEpoch = tableToEpochtime(timestringToTable(time));
    local startOfDay = tableToEpochtime(timestringToTable("00:00"));
    local now = os.time();
    return( (now < timeEpoch) and (now >= startOfDay ));
end;




if (takState == 0) then
    fibaro:debug(" 0 - Got state "..takState);
    -- turned off
    if (afterTime(sunsetHour) and beforeTime("22:00")) then
    
        fibaro:call(346, "setValue", "30");
    end;
else
    fibaro:debug(" 1 - Got state "..takState);
    fibaro:call(346, "setValue", "0")  
end;
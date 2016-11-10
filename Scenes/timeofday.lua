--[[
%% properties
%% events
%% globals
--]]

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



function isTime (timeString, offsetMinutes, secondsWindow)
    local timeTable = timestringToTable(timeString);
    local timeEpoch = tableToEpochtime (timeTable);
    local timeWithOffset = timeEpoch + (offsetMinutes * 60);
    local now = os.time();
    return ( math.abs(timeWithOffset - now) <= secondsWindow );
end;

function myTimer(shouldRun, functionToRun, sleepSeconds )
    local delay = sleepSeconds or 60;
    if (fibaro:countScenes() > 1 and shouldRun ) then
        functionToRun();
        fibaro:sleep(delay*1000);
    end;
end;

function isInTimeRange (startTimeString, endTimeString)
    local startTimeTable = timestringToTable(startTimeString);
    local endTimeTable = timestringToTable(endTimeString);
    local startTimeEpoch = tableToEpochtime (startTimeTable);
    local endTimeEpoch = tableToEpochtime (endTimeTable);
    local now = os.time();
    return ( (startTimeEpoch <= now ) and (endTimeEpoch >= now));
end;

function afterTime(time)
    local timeEpoch = tableToEpochtime(timestringToTable(time));
    local endOfDay = tableToEpochtime(timestringToTable("23:59:59"));
    local now = os.time();
    return( (now > timeEpoch) and (now <= endOfDay ));
end;

function setMorning()
    fibaro:setGlobal("TimeOfDay", "Morning");
    fibaro:debug("Setting morning");
end;

function setDay()
    fibaro:setGlobal("TimeOfDay", "Day");
    fibaro:debug("Setting daytime");
end;

function setEvening()
    fibaro:setGlobal("TimeOfDay", "Evening");
    fibaro:debug("Setting evening");
end;

function setNight()
    fibaro:setGlobal("TimeOfDay", "Night");
    fibaro:debug("Setting nightime");
end;

myTimer(isInTimeRange("06:30","08:00"),setMorning);

myTimer(isInTimeRange("08:00","18:00"),setDay);

myTimer(isInTimeRange("18:00","23:30"),setEvening);

myTimer(afterTime("23:30"),setNight);


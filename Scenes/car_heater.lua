--[[
%% autostart
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
    return(dateTable)
end

function tableToEpochtime (t)
    local now = os.date("*t");
    local outTime = os.time{year=t.year or now.year, month=t.month or now.month,day=t.day or now.day,hour=t.hour or now.hour,min=t.min or now.min,sec=t.sec or now.sec,isdst=t.isdst or now.isdst};
    return(outTime);
end


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

function startedManually ()
    local startSource = fibaro:getSourceTrigger();
    return( startSource["type"] == "other")
end

function startedByDevice ()
    local startSource = fibaro:getSourceTrigger();
    -- startSource ={type="property",deviceID="11",propertyName="tet"}
    if startSource["type"] == "property" then
        return ({deviceID=startSource["deviceID"], propertyName=startSource["propertyName"]})
    else
        return false
    end
end

function isTime (timeString, offsetMinutes, secondsWindow)
    local timeTable = timestringToTable(timeString);
    local timeEpoch = tableToEpochtime (timeTable);
    local timeWithOffset = timeEpoch + (offsetMinutes * 60);
    local now = os.time();
    return ( math.abs(timeWithOffset - now) <= secondsWindow )
end

function isWeekDay ()
    local today = tonumber(os.date("%w",os.time()));
    -- Please note that this specification is 0-6 range, sunday=0
    return (not (today == 0 or today == 6));
end;

function isWeekEnd ()
    local today = tonumber(os.date("%w",os.time()));
    return (today == 0 or today == 6);
end;

function myTimer(shouldRun, functionToRun)
    if ( shouldRun ) then
        functionToRun();
    end;
end;

-- Main


function myFunc()
    fibaro:call(193,"turnOn")
end


if (startedManually() ) then
    myFunc();
elseif (fibaro:countScenes() < 2) then
    local tempOutside = -1;
    local heaterON = false;
    while (true) do
        tempOutside = tonumber(fibaro:getValue(3, "Temperature"));
        --if (fibaro:getValue(193, "value") == 1) then heaterON = true else heaterON = false end;
        myTimer( timeToStartCarHeater("07:10", tempOutside, heaterON ) and  isWeekDay() ,myFunc);
        myTimer( timeToStartCarHeater("10:00", tempOutside, heaterON ) and  isWeekEnd() ,myFunc);
        myTimer( timeToStartCarHeater("17:30", tempOutside, heaterON ) and  isDayOfWeek{"Sun"} ,myFunc);
        fibaro:sleep(60*1000);
    end;
end;

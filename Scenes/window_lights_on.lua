--[[
%% autostart
%% properties
54 sceneActivation
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


function beforeTime(time)
    local timeEpoch = tableToEpochtime(timestringToTable(time));
    local startOfDay = tableToEpochtime(timestringToTable("00:00"));
    local now = os.time();
    return( (now < timeEpoch) and (now >= startOfDay ));
end

function myTimer(shouldRun, functionToRun)
    if ( shouldRun ) then
        functionToRun();
    end;
end;

function isWeekEnd ()
    local today = tonumber(os.date("%w",os.time()));
    return (today == 0 or today == 6);
end

function isWeekDay ()
    local today = tonumber(os.date("%w",os.time()));
    -- Please note that this specification is 0-6 range, sunday=0
    return (not (today == 0 or today == 6));
end
-- Main


function myFunc ()
    fibaro:call(43, "turnOn");
    fibaro:call(21, "setValue", "78");
    fibaro:call(58, "turnOn");
    fibaro:call(24, "setValue", "60");
end


if (startedManually() ) then
    myFunc();
    fibaro:debug(tostring(fibaro:getValue(1, "sunsetHour")));
elseif ( startedByDevice () ) then
    local info = startedByDevice();
    local scene = tonumber(fibaro:getValue(info["deviceID"], "sceneActivation"));
    if (scene == 20) then
        myFunc();
    end;
elseif (fibaro:countScenes() < 2) then
    local sunsetHour = "19:00";
    while (true) do

        sunsetHour = tostring(fibaro:getValue(1, "sunsetHour"));
        --fibaro:debug("Sunset hour = ".. sunsetHour);
        myTimer( isTime(sunsetHour,-30,180) and beforeTime("23:59"),myFunc);
        myTimer( isTime("06:30",0,180) and  isWeekDay() ,myFunc);
        myTimer( isTime("07:30",0,180) and  isWeekEnd() ,myFunc);
        fibaro:sleep(60*1000);
    end;
end;
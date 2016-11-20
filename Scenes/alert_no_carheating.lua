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

function onButUnplugged(id,threshold)
    local t = threshold or 15;
    local state = tonumber(fibaro:getValue(id, "value"));
    local pow = tonumber(fibaro:getValue(id, "power"));

    return(state == 1 and pow > t);
end;
-- Main


function sendNotice ()

    fibaro:call(76, "sendDefinedPushNotification", "141");
    fibaro:call(365, "sendDefinedPushNotification", "141");
end;



if (fibaro:countScenes() < 2) then

    while (true) do

        myTimer( isTime("06:30",0,60) and  isWeekDay() and onButUnplugged(193,20),sendNotice);
        myTimer( isTime("10:00",0,60) and  isWeekEnd() and onButUnplugged(193,20),sendNotice);
        fibaro:sleep(60*1000);
    end;
end;




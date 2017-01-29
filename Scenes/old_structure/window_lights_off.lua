--[[
%% autostart
%% properties
54 sceneActivation
396 sceneActivation
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
-- Main


function myFunc ()

    fibaro:call(375, "turnOff") -- Dimmer vårt rum
    fibaro:call(375, "setValue", "0") -- Dimmer vårt rum

    fibaro:call(323, "turnOff")
    fibaro:call(323, "setValue", "0") -- Fönster uppe
    fibaro:call(21, "setValue", "0") -- fönster köket nere

    fibaro:call(288, "turnOff") -- Gröna lampan
    fibaro:sleep(15*60*1000);
    fibaro:call(447, "turnOff") -- innergårdens belysning
--    fibaro:call(472, "turnOff") -- julbelysningen uppe plugg
--    fibaro:call(474, "turnOff") -- julbelysningen nere plugg
  fibaro:call(497, "turnOff") -- uttagen i uterummet
end;


if (startedManually() ) then
    myFunc();
    fibaro:debug(tostring(fibaro:getValue(1, "sunsetHour")));
elseif ( startedByDevice () ) then
    local info = startedByDevice();
    local scene = tonumber(fibaro:getValue(info["deviceID"], "sceneActivation"));
    if (scene == 40) then
        myFunc();
    end;
elseif (fibaro:countScenes() < 2) then
    local sunsetHour = "19:00";
    while (true) do

        sunriseHour = tostring(fibaro:getValue(1, "sunriseHour"));
        --fibaro:debug("Sunset hour = ".. sunsetHour);
        myTimer( isTime(sunriseHour,30,180) ,myFunc);
        myTimer( isTime("07:30",0,180) and  isWeekDay() ,myFunc);
        myTimer( isTime("10:30",0,180) and  isWeekEnd() ,myFunc);
        fibaro:sleep(60*1000);
    end;
end;

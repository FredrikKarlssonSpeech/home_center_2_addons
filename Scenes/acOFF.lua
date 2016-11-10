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


function acOFF()
    fibaro:call(49, "setMode", "Off")

    fibaro:sleep(10*1000);
    fibaro:call(341, "turnOff")
end


if (startedManually() ) then
    acOFF();
elseif (fibaro:countScenes() < 2) then
    local state =0;
    while (true) do
        state = tonumber(fibaro:getValue(341, "value");
        -- Turn off an hour later
        myTimer( isTime("16:00", 0, 10*60 ) and  (state == 1),acOFF);




        fibaro:sleep(10*60*1000);
    end;
end;



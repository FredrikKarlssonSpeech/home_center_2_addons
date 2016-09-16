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


function acONHeat22()
    fibaro:call(341, "turnOn")
    fibaro:sleep(5*1000);
    fibaro:call(49, "setMode", "Heat")
    fibaro:call(47, "setThermostatSetpoint", "22", "Heating")
    fibaro:call(50, "setFanMode", "Auto low speed")
    fibaro:call(47, "setSetpointMode", "Heating")
end

function acONDry()
    fibaro:call(341, "turnOn")
    fibaro:sleep(5*1000);
    fibaro:call(49, "setMode", "Dry Air")
    fibaro:call(47, "setThermostatSetpoint", "22", "Dry air")
    fibaro:call(50, "setFanMode", "Auto low speed")
    fibaro:call(47, "setSetpointMode", "Dry Air")
end

function acOFF()
    fibaro:call(49, "setMode", "Off")

    fibaro:sleep(5*1000);
    fibaro:call(341, "turnOff")
end


if (startedManually() ) then
    myFunc();
elseif (fibaro:countScenes() < 2) then
    local tempOutside = -1;
    local eco = false;
    local heaterON = false;
    while (true) do
        tempOutside = tonumber(fibaro:getValue(3, "Temperature"));
        --if (fibaro:getValue(193, "value") == 1) then heaterON = true else heaterON = false end;
        myTimer( isTime("15:00", 0, 10*60 ) and  isWeekDay() and (tempOutside <= -5), acONHeat22);
        -- Turn off an hour later
        myTimer( isTime("16:00", 0, 10*60 ) and  isWeekDay(),acOFF);


        fibaro:sleep(10*60*1000);
    end;
end;



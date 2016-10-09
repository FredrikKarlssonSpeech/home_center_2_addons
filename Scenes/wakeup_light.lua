--[[
%% autostart
%% properties
%% events
%% globals
--]]

local dimmerID = 375;

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

function myTimer(shouldRun, functionToRun)
    if ( shouldRun ) then
        functionToRun();
    end;
end;

function startLevelChangeWithDur(dimmerID,startLevel,stopLevel,durationSeconds,delayBetweenSteps)
    local currentLevel = startLevel;
    local timeStepSeconds = delayBetweenSteps or 2;
    local deltaPerSecond = (stopLevel - startLevel) / durationSeconds *timeStepSeconds; 
    local newLevel = currentLevel + deltaPerSecond;
    local currentLevelFromDevice = 0;

    fibaro:debug("STARTING light increase");
    repeat
        fibaro:debug("Setting level value ".. newLevel);
        fibaro:call(dimmerID,"setValue",newLevel);
        currentLevel = newLevel;
        -- wait for timeStepSeconds seconds
        fibaro:sleep(timeStepSeconds* 1000);
        -- check actual setting of the device now
    --    currentLevelFromDevice = tonumber(fibaro:getValue(dimmerID, "value"));
        newLevel = currentLevel + deltaPerSecond;
        -- continue only if the level to be set is smaller or equal to the stop level
        -- AND the level has not been manually decreased in the waiting period
    until ( newLevel > stopLevel )
  -- or ( currentLevelFromDevice < currentLevel );

    fibaro:debug("DONE light increase");
end;

-- Main

function wakeup ()
    startLevelChangeWithDur(dimmerID,0,30,5*60);
end

function shutoff ()
    fibaro:call(dimmerID, "setValue", "0");
    fibaro:call(dimmerID, "turnOff");
end

if (startedManually() ) then
    wakeup();
elseif (fibaro:countScenes() < 2) then
    while (true) do

        myTimer( isTime("06:25",0,180) and  isWeekDay() ,wakeup);
        myTimer( isTime("07:15",0,180) and  isWeekDay(),shutoff);
        myTimer( isTime("21:30",0,180),shutoff);
        fibaro:sleep(60*1000);
    end;
end;


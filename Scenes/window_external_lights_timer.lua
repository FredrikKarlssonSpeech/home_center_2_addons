--[[
%% autostart
%% properties
%% globals
--]]

if (fibaro:countScenes() > 1) then
  fibaro:abort()
end;


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


function runIf(shouldRun, toRun, sleepSeconds )
  local delay = sleepSeconds or 60;
  if (type(toRun) == "function" and shouldRun ) then
    toRun();
  elseif ( type(toRun) == "table"  and shouldRun ) then
    for k,v in pairs(toRun) do
        k = tonumber(k);
        if ( fibaro:isSceneEnabled(k)) then
          fibaro:startScene(k);
        else
          fibaro:debug("Not running disabled scene ID:".. tostring(k));
        end;
    end;
  end;
  --fibaro:sleep(delay*1000);
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

function isInTimeRange (startTimeString, endTimeString)
    local startTimeTable = timestringToTable(startTimeString);
    local endTimeTable = timestringToTable(endTimeString);
    local startTimeEpoch = tableToEpochtime (startTimeTable);
    local endTimeEpoch = tableToEpochtime (endTimeTable);
    local newEndTimeTable = endTimeTable;
    -- allow for end time being in the upcoming day, but before startTime then
    if (endTimeEpoch < startTimeEpoch) then
        endTimeEpoch = endTimeEpoch + 24*3600;  -- add 24 hours
        -- Now, we make a new table object, to find out whether the DST status of the new end time is
        newEndTimeTable = os.date("*t",endTimeEpoch);
    end;
        -- Now, we adjust for Daylight saving time effects
    if (startTimeTable.isdst == false and newEndTimeTable.isdst == true) then
        -- In this case, start time is Not summer, and end time is in summer time
        -- which means that we are going from spring into summer
        -- then advance the clock one more hour from the end time
        endTimeEpoch = endTimeEpoch + 3600;
    elseif (startTimeTable.isdst == true and newEndTimeTable.isdst == false) then
        -- Here, we are coming into fall (from summer)
        -- then remove one hour from the time end time
         endTimeEpoch = endTimeEpoch - 3600;
    end;
    local now = os.time();
    return ( (startTimeEpoch <= now ) and (endTimeEpoch >= now));
end;

function beforeTime(time, offset)
    local timeEpoch = tableToEpochtime(timestringToTable(time));
    local startOfDay = tableToEpochtime(timestringToTable("00:00"));
    local off = offset or 0;
    timeEpoch = timeEpoch + off;
    local now = os.time();
    return( (now < timeEpoch) and (now >= startOfDay ));
end;

-- Main

local windowsOffScene = 98;
local windowsOnScene = 99;
local externalOnScene = 81;
local externalOffScene = 82;
local fasadOff = {windowsOffScene, externalOffScene};
local fasadOn = {windowsOnScene, externalOnScene}


while (true) do
  -- window lights
  sunriseHour = tostring(fibaro:getValue(1, "sunriseHour"));
  sunsetHour = tostring(fibaro:getValue(1, "sunsetHour"));

  -- window lights OFF
  runIf(isTime("07:30",0,180) and  isWeekDay() ,fasadOff);
  runIf(isTime("10:30",0,180) and  isWeekEnd() ,fasadOff);
  runIf(isTime(sunriseHour,30,180), fasadOff );

  -- window lights ON
  runIf(isTime(sunsetHour,-30,180) ,fasadOn);
  -- and timeIsInRange ("06:30", "23:00")
  runIf(isTime("06:30",0,180) and  isWeekDay() and beforeTime(sunriseHour,-30),fasadOn);
  runIf(isTime("07:30",0,180) and  isWeekEnd() and beforeTime(sunriseHour,-30),fasadOn);

  fibaro:sleep(60*1000);
end;
